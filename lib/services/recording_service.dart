import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/app_constants.dart';
import '../core/error/exceptions.dart';

/// Service for realtime audio recording + Socket.IO transcription.
class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Timer? _durationTimer;
  int _duration = 0;
  bool _isRecording = false;
  bool _isPaused = false;

  io.Socket? _socket;
  StreamSubscription<Uint8List>? _audioStreamSubscription;

  String _committedTranscript = '';
  String _partialTranscript = '';
  int _audioChunkCount = 0;

  void _debugLog(String message) {
    if (kDebugMode) {
      log(message, name: 'RecordingService');
    }
  }

  /// Check and request microphone permission
  Future<PermissionStatus> requestPermission() async {
    final status = await Permission.microphone.request();
    _debugLog('requestPermission -> $status');
    return status;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    _debugLog('hasPermission status=$status');
    return status.isGranted;
  }

  String _socketOriginFromBackendUrl(String backendUrl) {
    final uri = Uri.parse(backendUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  RecordConfig _buildRecordConfig() {
    if (Platform.isIOS) {
      // Primary iOS attempt; additional fallbacks are tried if this fails.
      return const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
      );
    }

    return const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  List<RecordConfig> _buildIosFallbackConfigs() {
    return const [
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 48000,
        numChannels: 1,
      ),
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      ),
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
      // Some iOS routes only support stereo capture reliably.
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 48000,
        numChannels: 2,
      ),
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 2,
      ),
    ];
  }

  String _recordConfigLabel(RecordConfig config) {
    return 'encoder=${config.encoder} sampleRate=${config.sampleRate} channels=${config.numChannels}';
  }

  Future<Stream<Uint8List>> _startRecorderStreamWithFallbacks() async {
    final primaryConfig = _buildRecordConfig();
    final attemptedLabels = <String>[];

    final configs = <RecordConfig>[
      primaryConfig,
      if (Platform.isIOS) ..._buildIosFallbackConfigs(),
    ];

    Object? lastError;

    for (final config in configs) {
      final label = _recordConfigLabel(config);
      attemptedLabels.add(label);
      try {
        _debugLog('Starting recorder stream with config: $label');
        final stream = await _recorder.startStream(config);
        _debugLog('Recorder stream started with config: $label');
        return stream;
      } catch (e) {
        lastError = e;
        _debugLog('Recorder stream failed with config [$label]: $e');
      }
    }

    throw RecordingException(
      message:
          'Failed to start recording on this iOS audio route. '
          'Tried configs: ${attemptedLabels.join(' | ')}. '
          'Last error: ${lastError.toString()}',
    );
  }

  Future<io.Socket> _connectSocket() async {
    final backendUrl = dotenv.env['BACKEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      throw RecordingException(message: 'BACKEND_URL is not configured');
    }

    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) {
      throw RecordingException(message: 'Not authenticated');
    }

    final origin = _socketOriginFromBackendUrl(backendUrl);
    _debugLog('Connecting socket to $origin/api/socket.io');
    final socket = io.io(
      origin,
      io.OptionBuilder()
          .setPath('/api/socket.io')
          // Flutter mobile works reliably with websocket transport.
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setTimeout(20000)
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    final connected = Completer<void>();
    socket.onConnect((_) {
      _debugLog('Socket connected id=${socket.id}');
      if (!connected.isCompleted) connected.complete();
    });
    socket.onConnectError((error) {
      _debugLog('Socket connect error: $error');
      if (!connected.isCompleted) {
        connected.completeError(
          RecordingException(message: 'Socket connection failed: $error'),
        );
      }
    });
    socket.onError((error) {
      _debugLog('Socket error: $error');
      if (!connected.isCompleted) {
        connected.completeError(
          RecordingException(message: 'Socket error: $error'),
        );
      }
    });

    socket.connect();
    _debugLog('socket.connect() called');
    await connected.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () =>
          throw RecordingException(message: 'Socket connection timed out'),
    );

    return socket;
  }

  Future<void> _startScribeSession(io.Socket socket) async {
    _committedTranscript = '';
    _partialTranscript = '';

    final ready = Completer<void>();

    socket.on('scribe:partial', (payload) {
      final map = payload is Map ? payload : <String, dynamic>{};
      _partialTranscript = (map['text'] ?? '').toString();
      if (_partialTranscript.isNotEmpty) {
        _debugLog('scribe:partial len=${_partialTranscript.length}');
      }
    });
    socket.on('scribe:committed', (payload) {
      final map = payload is Map ? payload : <String, dynamic>{};
      final piece = (map['text'] ?? '').toString().trim();
      if (piece.isNotEmpty) {
        _committedTranscript = _committedTranscript.isEmpty
            ? piece
            : '$_committedTranscript $piece';
      }
      _partialTranscript = '';
      _debugLog(
        'scribe:committed totalCommittedLen=${_committedTranscript.length}',
      );
    });

    socket.once('scribe:ready', (_) {
      _debugLog('scribe:ready received');
      if (!ready.isCompleted) ready.complete();
    });
    socket.once('scribe:error', (payload) {
      final map = payload is Map ? payload : <String, dynamic>{};
      final message = (map['message'] ?? 'Scribe failed to start').toString();
      _debugLog('scribe:error while starting: $message');
      if (!ready.isCompleted) {
        ready.completeError(RecordingException(message: message));
      }
    });

    socket.emit('scribe:start');
    _debugLog('scribe:start emitted');
    await ready.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () =>
          throw RecordingException(message: 'Scribe session start timed out'),
    );
  }

  /// Start recording and streaming PCM16 data to Scribe backend.
  Future<void> startRecording({
    Function(int duration)? onDurationUpdate,
  }) async {
    try {
      _debugLog(
        'startRecording called isRecording=$_isRecording isPaused=$_isPaused',
      );
      if (_isRecording) {
        throw RecordingException(message: 'Recording already in progress');
      }

      if (!await hasPermission()) {
        final status = await requestPermission();
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            throw PermissionException(
              message:
                  'Microphone permission is permanently denied. Enable it in iOS Settings -> Privacy -> Microphone -> this app, then try again.',
            );
          }
          if (status.isRestricted) {
            throw PermissionException(
              message:
                  'Microphone permission is restricted by iOS settings (cannot be requested from the app).',
            );
          }
          throw PermissionException(
            message:
                'Microphone permission denied. If prompted, choose "Allow"; otherwise enable it in iOS Settings -> Privacy -> Microphone -> this app.',
          );
        }
      }

      if (!await _recorder.hasPermission()) {
        throw PermissionException(message: 'Microphone permission not granted');
      }
      _debugLog('Recorder permission confirmed');

      _socket = await _connectSocket();
      await _startScribeSession(_socket!);
      _audioChunkCount = 0;

      final audioStream = await _startRecorderStreamWithFallbacks();

      _audioStreamSubscription = audioStream.listen((chunk) {
        if (_isPaused || _socket == null || !_socket!.connected) return;
        _audioChunkCount++;
        _socket!.emit('scribe:audio', {'audioBase64': base64Encode(chunk)});
      });

      _isRecording = true;
      _isPaused = false;
      _duration = 0;

      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration++;
        onDurationUpdate?.call(_duration);
      });
      _debugLog('Recording started successfully');
    } catch (e) {
      _debugLog('startRecording failed: $e');
      await cancelRecording();
      if (e is PermissionException || e is RecordingException) {
        rethrow;
      }
      throw RecordingException(
        message: 'Failed to start recording: ${e.toString()}',
      );
    }
  }

  String _buildTranscript() {
    final committed = _committedTranscript.trim();
    final partial = _partialTranscript.trim();
    return [committed, partial].where((e) => e.isNotEmpty).join(' ').trim();
  }

  Future<void> _stopSocketSession() async {
    final socket = _socket;
    if (socket == null) return;

    final stopped = Completer<void>();
    socket.once('scribe:stopped', (_) {
      _debugLog('scribe:stopped received');
      if (!stopped.isCompleted) stopped.complete();
    });

    socket.emit('scribe:commit');
    socket.emit('scribe:stop');
    _debugLog('scribe:commit and scribe:stop emitted');

    try {
      await stopped.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      // Best effort shutdown; still disconnect socket below.
    }

    socket.dispose();
    _socket = null;
    _debugLog('Socket disposed');
  }

  /// Stop recording and return final transcript from realtime stream.
  Future<String> stopRecording() async {
    try {
      _debugLog(
        'stopRecording called isRecording=$_isRecording chunks=$_audioChunkCount',
      );
      if (!_isRecording) {
        throw RecordingException(message: 'No active recording');
      }

      _durationTimer?.cancel();
      _durationTimer = null;
      _isRecording = false;
      _isPaused = false;

      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      await _recorder.stop();
      _debugLog('Recorder stopped');
      await _stopSocketSession();

      final transcript = _buildTranscript();
      log('Realtime transcript length: ${transcript.length}');

      if (transcript.isEmpty) {
        throw RecordingException(
          message: 'No transcript received. Please record again.',
        );
      }

      return transcript;
    } catch (e) {
      _debugLog('stopRecording failed: $e');
      _isRecording = false;
      _isPaused = false;
      if (e is RecordingException) {
        rethrow;
      }
      throw RecordingException(
        message: 'Failed to stop recording: ${e.toString()}',
      );
    }
  }

  /// Pause recording stream (keeps Scribe session open).
  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) {
      throw RecordingException(
        message: 'No active recording or already paused',
      );
    }
    _durationTimer?.cancel();
    _isPaused = true;
    _debugLog('pauseRecording -> paused');
  }

  /// Resume recording stream.
  Future<void> resumeRecording({
    Function(int duration)? onDurationUpdate,
  }) async {
    if (!_isRecording || !_isPaused) {
      throw RecordingException(message: 'Recording is not paused');
    }

    _isPaused = false;
    _debugLog('resumeRecording -> resumed');
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _duration++;
      onDurationUpdate?.call(_duration);
    });
  }

  /// Cancel current recording and cleanup resources.
  Future<void> cancelRecording() async {
    _debugLog(
      'cancelRecording called isRecording=$_isRecording isPaused=$_isPaused',
    );
    _durationTimer?.cancel();
    _durationTimer = null;

    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;

    try {
      if (_isRecording) {
        await _recorder.stop();
        _debugLog('Recorder stopped during cancel');
      }
    } catch (_) {
      // Ignore recorder stop errors on cancellation.
    }

    await _stopSocketSession();

    _isRecording = false;
    _isPaused = false;
    _duration = 0;
    _committedTranscript = '';
    _partialTranscript = '';
    _audioChunkCount = 0;
    _debugLog('cancelRecording cleanup complete');
  }

  /// Get current recording duration in seconds
  int get duration => _duration;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Check if currently paused
  bool get isPaused => _isPaused;

  /// Dispose resources
  void dispose() {
    _debugLog('dispose called');
    _durationTimer?.cancel();
    _audioStreamSubscription?.cancel();
    _socket?.dispose();
    _recorder.dispose();
  }
}

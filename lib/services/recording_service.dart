import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../core/error/exceptions.dart';
import '../core/constants/app_constants.dart';

/// Service for audio recording functionality
class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _durationTimer;
  int _duration = 0;
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPaused = false;

  /// Check and request microphone permission
  Future<PermissionStatus> requestPermission() async {
    return Permission.microphone.request();
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Start recording audio
  Future<void> startRecording({
    Function(int duration)? onDurationUpdate,
  }) async {
    try {
      // Check permission
      if (!await hasPermission()) {
        final status = await requestPermission();
        if (!status.isGranted) {
          // iOS will not show the permission prompt again if user selected "Don’t Allow"
          // (or the app is restricted). In that case, the correct fix is enabling it in
          // Settings -> Privacy -> Microphone -> <Your App>.
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

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath =
          '${directory.path}/recording_$timestamp${AppConstants.audioFileExtension}';

      // Start recording
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: AppConstants.audioSampleRate,
          ),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        _isPaused = false;
        _duration = 0;

        // Start duration timer
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration++;
          onDurationUpdate?.call(_duration);
        });
      } else {
        throw PermissionException(message: 'Microphone permission not granted');
      }
    } catch (e) {
      if (e is PermissionException || e is RecordingException) {
        rethrow;
      }
      throw RecordingException(
        message: 'Failed to start recording: ${e.toString()}',
      );
    }
  }

  /// Stop recording and return the audio file path
  Future<String> stopRecording() async {
    try {
      if (!_isRecording) {
        throw RecordingException(message: 'No active recording');
      }

      _durationTimer?.cancel();
      _durationTimer = null;

      final path = await _recorder.stop();
      _isRecording = false;
      _isPaused = false;

      if (path == null) {
        throw RecordingException(message: 'Failed to stop recording');
      }

      return path;
    } catch (e) {
      _isRecording = false;
      if (e is RecordingException) {
        rethrow;
      }
      throw RecordingException(
        message: 'Failed to stop recording: ${e.toString()}',
      );
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      if (!_isRecording || _isPaused) {
        throw RecordingException(
          message: 'No active recording or already paused',
        );
      }

      await _recorder.pause();
      _durationTimer?.cancel();
      _isPaused = true;
    } catch (e) {
      throw RecordingException(
        message: 'Failed to pause recording: ${e.toString()}',
      );
    }
  }

  /// Resume recording
  Future<void> resumeRecording({
    Function(int duration)? onDurationUpdate,
  }) async {
    try {
      if (!_isRecording || !_isPaused) {
        throw RecordingException(message: 'Recording is not paused');
      }

      await _recorder.resume();
      _isPaused = false;

      // Restart duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration++;
        onDurationUpdate?.call(_duration);
      });
    } catch (e) {
      throw RecordingException(
        message: 'Failed to resume recording: ${e.toString()}',
      );
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;

      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
      }

      // Delete the recording file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
      }

      _duration = 0;
    } catch (e) {
      // Ignore errors during cancellation
    }
  }

  /// Get current recording duration in seconds
  int get duration => _duration;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Check if currently paused
  bool get isPaused => _isPaused;

  /// Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Dispose resources
  void dispose() {
    _durationTimer?.cancel();
    _recorder.dispose();
  }
}

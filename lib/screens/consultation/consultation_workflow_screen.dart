import 'dart:convert';
import 'dart:developer';
import 'package:aura/screens/consultation/final_recording_view.dart';
import 'package:aura/screens/consultation/tasks_and_labs_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/notification/notification_cubit.dart';
import '../../../core/constants/consultation_status.dart';
import '../../../core/utils/consultation_status_utils.dart';
import '../../../services/recording_service.dart';
import '../../../features/consultation/consultation_cubit.dart';
import '../../../features/consultation/consultation_state.dart';
import '../../../models/consultation_model.dart';
import 'initial_recording_view.dart';
import 'patient_extraction_progress_view.dart';
import 'documentation_view.dart';
import 'ai_processing_view.dart';
import '../widgets/app_bar_logo_title.dart';

/// Main consultation recording screen that manages the consultation workflow
class ConsultationWorkflowScreen extends StatefulWidget {
  final String? consultationId;
  final ConsultationStatus initialStatus;
  final String initialPatientName;

  const ConsultationWorkflowScreen({
    super.key,
    this.consultationId,
    this.initialStatus = ConsultationStatus.initialConsult,
    this.initialPatientName = 'New Patient',
  });

  @override
  State<ConsultationWorkflowScreen> createState() =>
      _ConsultationWorkflowScreenState();
}

class _ConsultationWorkflowScreenState
    extends State<ConsultationWorkflowScreen> {
  late ConsultationStatus _currentStatus;
  late String _patientName;
  final RecordingService _recordingService = RecordingService();
  int _recordingDuration = 0;
  Map<String, dynamic>? _extractedPatientInfo;
  String? _currentConsultationId;
  String? _transcript;
  List<dynamic> _generatedTasks = [];
  LabAnalysisModel? _labAnalysis;
  DocumentationModel? _documentation;
  String _priority = 'medium';
  bool _isEmergency = false;
  String _notes = '';
  bool _isLoading = false;
  bool _isPaused = false;
  bool _labUploadCompleted = false;
  bool _labUploadSuccessCalled = false;
  final TextEditingController _manualTranscriptController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _patientName = widget.initialPatientName;
    _currentConsultationId = widget.consultationId;

    // Load consultation data if ID is provided
    if (_currentConsultationId != null) {
      _loadConsultationData();
    }
  }

  @override
  void dispose() {
    _recordingService.dispose();
    _manualTranscriptController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultationData() async {
    if (_currentConsultationId == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<ConsultationCubit>().loadConsultation(
        _currentConsultationId!,
      );

      final state = context.read<ConsultationCubit>().state;
      final consultation = state.currentConsultation;

      if (consultation != null) {
        setState(() {
          _patientName = consultation.patientName ?? widget.initialPatientName;
          _transcript = consultation.transcript;
          _generatedTasks = consultation.aiAnalysis?.tasks ?? [];
          _labAnalysis = consultation.aiAnalysis?.labAnalysis;
          _documentation = consultation.aiAnalysis?.documentation;
          _currentStatus = consultation.status;
          _priority = consultation.priority;
          _isEmergency = consultation.isEmergency;
          _notes = consultation.notes ?? '';
          _extractedPatientInfo ??= {};
          if (consultation.aiAnalysis?.breed != null) {
            _extractedPatientInfo = {
              ...?_extractedPatientInfo,
              'breed': consultation.aiAnalysis!.breed,
            };
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading consultation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _getTotalSteps() {
    return 4;
  }

  Future<void> _refreshAfterEditConsultation() async {
    if (_currentConsultationId == null) return;
    await context.read<ConsultationCubit>().loadConsultation(
      _currentConsultationId!,
    );
    if (!mounted) return;
    final consultation = context
        .read<ConsultationCubit>()
        .state
        .currentConsultation;
    if (consultation != null) {
      setState(() {
        _patientName = consultation.patientName ?? _patientName;
        _priority = consultation.priority;
        _isEmergency = consultation.isEmergency;
        _notes = consultation.notes ?? '';
        if (consultation.aiAnalysis?.breed != null) {
          _extractedPatientInfo = {
            ...?_extractedPatientInfo,
            'breed': consultation.aiAnalysis!.breed,
          };
        }
      });
    }
  }

  Future<void> _handleStartRecording() async {
    try {
      await _recordingService.startRecording(
        onDurationUpdate: (duration) {
          setState(() {
            _recordingDuration = duration;
            _isPaused = _recordingService.isPaused;
          });
        },
      );
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePauseRecording() async {
    try {
      await _recordingService.pauseRecording();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error pausing recording: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleResumeRecording() async {
    try {
      await _recordingService.resumeRecording(
        onDurationUpdate: (duration) {
          setState(() {
            _recordingDuration = duration;
            _isPaused = _recordingService.isPaused;
          });
        },
      );
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resuming recording: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleManualSubmit() async {
    final manualTranscript = _manualTranscriptController.text.trim();
    if (manualTranscript.isEmpty) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Process based on current status
      if (_currentStatus == ConsultationStatus.initialConsult) {
        setState(() {
          _transcript = manualTranscript;
        });
        await _processInitialConsultation(manualTranscript);
      } else if (_currentStatus == ConsultationStatus.finalConsult) {
        setState(() {});
        await _processFinalConsultation(manualTranscript);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing transcript: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleStopRecording() async {
    try {
      setState(() => _isLoading = true);

      // Stop recording and get audio file path
      final audioFilePath = await _recordingService.stopRecording();
      log('Audio file path: $audioFilePath');

      // Transcribe audio
      final transcript = await context
          .read<ConsultationCubit>()
          .transcribeAudio(audioFilePath);

      if (transcript == null || transcript.isEmpty) {
        throw Exception('Failed to transcribe audio');
      }

      setState(() {
        _transcript = transcript;
        _isLoading = false;
      });

      // Process based on current status
      if (_currentStatus == ConsultationStatus.initialConsult) {
        await _processInitialConsultation(transcript);
      } else if (_currentStatus == ConsultationStatus.finalConsult) {
        await _processFinalConsultation(transcript);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processInitialConsultation(String transcript) async {
    try {
      setState(() {
        _currentStatus = ConsultationStatus.patientExtraction;
        _isLoading = true;
      });

      // Generate tasks and patient name in parallel
      final tasksResult = await context.read<ConsultationCubit>().generateTasks(
        transcript,
      );
      final patientInfoResult = await context
          .read<ConsultationCubit>()
          .generatePatientName(transcript);

      if (tasksResult == null || patientInfoResult == null) {
        throw Exception('Failed to generate tasks or patient info');
      }

      // Extract patient name
      String patientName =
          patientInfoResult['patientName'] as String? ??
          patientInfoResult['name'] as String? ??
          'Unknown Patient';

      // Clean patient name if it contains JSON
      if (patientName.contains('```json')) {
        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(patientName);
          if (jsonMatch != null) {
            final parsed = jsonDecode(jsonMatch.group(0)!);
            patientName = parsed['name'] ?? patientName;
          }
        } catch (e) {
          // Ignore parsing errors
        }
      }

      // Extract tasks
      final tasks =
          tasksResult['tasks']?['tasks'] as List<dynamic>? ??
          tasksResult['tasks'] as List<dynamic>? ??
          [];

      // Extract patient info
      final breed = patientInfoResult['breed'] as String? ?? 'Mixed Breed';

      setState(() {
        _patientName = patientName;
        _generatedTasks = tasks;
        _extractedPatientInfo = {
          'name': patientName,
          'breed': breed,
          ...patientInfoResult,
        };
      });

      // Create or update consultation
      await _createOrUpdateConsultation(
        transcript: transcript,
        patientName: patientName,
        breed: breed,
        tasks: tasks,
      );

      setState(() {
        _currentStatus = ConsultationStatus.initialComplete;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing consultation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processFinalConsultation(String transcript) async {
    try {
      setState(() {
        _currentStatus = ConsultationStatus.processing;
        _isLoading = true;
      });

      if (_currentConsultationId == null) {
        throw Exception('No consultation ID available');
      }

      // Update consultation with final transcript
      await context.read<ConsultationCubit>().updateConsultation(
        _currentConsultationId!,
        {
          'aiAnalysis': {'finalTranscript': transcript},
        },
      );

      // Generate documentation
      final documentation = await context
          .read<ConsultationCubit>()
          .generateDocumentation(
            initialTranscript: _transcript ?? '',
            finalTranscript: transcript,
            labAnalysis: _labAnalysis?.toJson(),
            patientInfo: {
              'name': _patientName,
              'breed': _extractedPatientInfo?['breed'] ?? 'Mixed Breed',
            },
            consultationId: _currentConsultationId,
          );

      if (documentation != null) {
        // Parse documentation to DocumentationModel
        DocumentationModel? docModel;
        try {
          final docData = documentation['documentation'] ?? documentation;
          docModel = DocumentationModel.fromJson(docData);
        } catch (e) {
          log('Error parsing documentation: $e');
        }

        // Update consultation with documentation
        await context.read<ConsultationCubit>().updateConsultation(
          _currentConsultationId!,
          {
            'status': ConsultationStatus.finalComplete.apiValue,
            'endTime': DateTime.now().toIso8601String(),
            'aiAnalysis': {
              'documentation': documentation['documentation'] ?? documentation,
              'finalTranscript': transcript,
            },
          },
        );

        setState(() {
          _documentation = docModel;
          _currentStatus = ConsultationStatus.complete;
          _isLoading = false;
        });
        // Refresh notification badge immediately after completing consultation
        getIt<NotificationCubit>().refreshUnreadNotifications();
      } else {
        throw Exception('Failed to generate documentation');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing consultation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createOrUpdateConsultation({
    required String transcript,
    required String patientName,
    required String breed,
    required List<dynamic> tasks,
  }) async {
    try {
      if (_currentConsultationId == null) {
        // Create new consultation with aiAnalysis so backend can create temporary patient
        // This matches the web version's approach
        final aiAnalysis = AIAnalysisModel(
          patientName: patientName,
          breed: breed,
          tasks: tasks.map((task) {
            // Convert dynamic task to TaskModel if needed
            if (task is Map<String, dynamic>) {
              final taskText =
                  task['task'] as String? ??
                  task['description'] as String? ??
                  task['title'] as String? ??
                  task.toString();
              return TaskModel(
                title: taskText,
                description: task['description'] as String?,
                completed: task['completed'] as bool? ?? false,
              );
            } else {
              return TaskModel(
                title: task.toString(),
                description: null,
                completed: false,
              );
            }
          }).toList(),
        );

        final consultation = await context
            .read<ConsultationCubit>()
            .createConsultation(
              status: ConsultationStatus.initialConsult,
              startTime: DateTime.now(),
              aiAnalysis: aiAnalysis,
            );

        if (consultation != null) {
          _currentConsultationId = consultation.id;

          // Update with transcript and complete AI analysis
          await context.read<ConsultationCubit>().updateConsultation(
            consultation.id,
            {
              'status': ConsultationStatus.initialComplete.apiValue,
              'patientName': patientName,
              'transcript': transcript,
              'aiAnalysis': {
                'patientName': patientName,
                'breed': breed,
                'tasks': tasks,
              },
            },
          );
        }
      } else {
        // Update existing consultation
        await context.read<ConsultationCubit>().updateConsultation(
          _currentConsultationId!,
          {
            'status': ConsultationStatus.initialComplete.apiValue,
            'patientName': patientName,
            'transcript': transcript,
            'aiAnalysis': {
              'patientName': patientName,
              'breed': breed,
              'tasks': tasks,
            },
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving consultation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleLabUploadComplete() {
    // Keep user on TasksLabsView while upload runs; don't switch to labAnalysis yet
    setState(() {
      _isLoading = true;
    });
  }

  Future<void> _handleLabUploadSuccess(String imageUrl) async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _labUploadSuccessCalled = true;
      });

      // imageUrl is already the uploaded URL from backend
      // If URL is relative, make it absolute for analysis
      String fullImageUrl = imageUrl;
      if (imageUrl.startsWith('/uploads/')) {
        // For production, use the API domain
        // For now, we'll use the local path and let the backend handle it
        fullImageUrl = imageUrl;
      }

      // Analyze the lab with the uploaded image URL
      final analysisResult = await context.read<ConsultationCubit>().analyzeLab(
        fullImageUrl,
      );

      if (!mounted) return;

      if (analysisResult != null) {
        // Extract analysis from response if nested
        final analysisData = analysisResult['analysis'] ?? analysisResult;

        // Convert to LabAnalysisModel
        try {
          final Map<String, dynamic> jsonData =
              analysisData is Map<String, dynamic>
              ? analysisData
              : analysisResult;

          final labAnalysisModel = LabAnalysisModel.fromJson(jsonData);

          setState(() {
            _labAnalysis = labAnalysisModel;
          });

          // Update consultation with lab analysis
          if (_currentConsultationId != null) {
            await context.read<ConsultationCubit>().updateConsultation(
              _currentConsultationId!,
              {
                'aiAnalysis': {'labAnalysis': _labAnalysis!.toJson()},
              },
            );
          }
        } catch (e) {
          log('Error parsing lab analysis: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error parsing lab analysis: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _labUploadSuccessCalled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing lab: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleContinueToFinal() {
    setState(() {
      _currentStatus = ConsultationStatus.finalConsult;
      _recordingDuration = 0;
      _manualTranscriptController
          .clear(); // Clear manual transcript for final consult
    });
  }

  void _handleNavigateToTasksLabs() {
    setState(() {
      _currentStatus = ConsultationStatus.initialComplete;
    });
  }

  void _handleNavigateToInitialRecording() {
    setState(() {
      _currentStatus = ConsultationStatus.initialConsult;
    });
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentStatus == ConsultationStatus.patientExtraction) {
      return PatientExtractionProgressView(
        stepInfo: ConsultationStatusUtils.getCurrentStepInfo(_currentStatus),
        totalSteps: _getTotalSteps(),
      );
    }

    final stepInfo = ConsultationStatusUtils.getCurrentStepInfo(_currentStatus);

    // Recording Interface: initial consult uses RecordingView, final consult uses dedicated view
    if (_currentStatus == ConsultationStatus.initialConsult) {
      return BlocBuilder<ConsultationCubit, ConsultationState>(
        builder: (context, state) {
          return InitialRecordingView(
            consultationStatus: _currentStatus,
            patientName: _patientName,
            recordingDuration: _recordingDuration,
            isRecording: _recordingService.isRecording,
            isPaused: _isPaused,
            stepInfo: stepInfo,
            totalSteps: _getTotalSteps(),
            manualTranscriptController: _manualTranscriptController,
            onStartRecording: _handleStartRecording,
            onStopRecording: _handleStopRecording,
            onPauseRecording: _handlePauseRecording,
            onResumeRecording: _handleResumeRecording,
            onManualSubmit: _handleManualSubmit,
            onBack: _handleBack,
          );
        },
      );
    }
    if (_currentStatus == ConsultationStatus.finalConsult) {
      return BlocBuilder<ConsultationCubit, ConsultationState>(
        builder: (context, state) {
          return FinalRecordingView(
            patientName: _patientName,
            recordingDuration: _recordingDuration,
            isRecording: _recordingService.isRecording,
            isPaused: _isPaused,
            stepInfo: stepInfo,
            totalSteps: _getTotalSteps(),
            manualTranscriptController: _manualTranscriptController,
            onStartRecording: _handleStartRecording,
            onStopRecording: _handleStopRecording,
            onPauseRecording: _handlePauseRecording,
            onResumeRecording: _handleResumeRecording,
            onManualSubmit: _handleManualSubmit,
            onBack: _handleBack,
            onNavigateToTasksLabs: _handleNavigateToTasksLabs,
            onNavigateToInitialRecording: _handleNavigateToInitialRecording,
          );
        },
      );
    }

    // Patient Extraction Processing
    if (_currentStatus == ConsultationStatus.patientExtraction) {
      return PatientExtractionProgressView(
        stepInfo: stepInfo,
        totalSteps: _getTotalSteps(),
      );
    }

    // Patient Review
    // if (_currentStatus == ConsultationStatus.patientReview &&
    //     _extractedPatientInfo != null) {
    //   return PatientInfoReviewView(
    //     extractedPatientInfo: _extractedPatientInfo!,
    //     stepInfo: stepInfo,
    //     totalSteps: _getTotalSteps(),
    //     onComplete: _handlePatientReviewComplete,
    //   );
    // }

    // Tasks & Labs Step (includes Upload Lab Result card per Figma)

    if (_currentStatus == ConsultationStatus.initialComplete) {
      return BlocListener<ConsultationCubit, ConsultationState>(
        listenWhen: (prev, curr) =>
            prev.isProcessingAI &&
            !curr.isProcessingAI &&
            _labUploadSuccessCalled,
        listener: (context, state) {
          setState(() {
            _labUploadCompleted = true;
            _labUploadSuccessCalled = false;
          });
        },
        child: TasksAndLabsView(
          patientName: _patientName,
          extractedPatientInfo: _extractedPatientInfo,
          generatedTasks: _generatedTasks,
          stepInfo: stepInfo,
          totalSteps: _getTotalSteps(),
          onContinue: _handleContinueToFinal,
          onUploadComplete: _handleLabUploadComplete,
          onUploadSuccess: _handleLabUploadSuccess,
          labUploadCompleted: _labUploadCompleted,
          consultationId: _currentConsultationId,
          initialPriority: _priority,
          initialIsEmergency: _isEmergency,
          initialNotes: _notes,
          onConsultationUpdated: _refreshAfterEditConsultation,
        ),
      );
    }

    // Final Processing
    if (_currentStatus == ConsultationStatus.processing) {
      return BlocBuilder<ConsultationCubit, ConsultationState>(
        builder: (context, state) {
          // If processing is complete, show completion
          if (!state.isProcessingAI &&
              _currentStatus == ConsultationStatus.processing) {
            // Processing is done, but we're still in processing state
            // The _processFinalConsultation will handle the completion
            return AIProcessingProgressView(
              stepInfo: stepInfo,
              totalSteps: _getTotalSteps(),
              onComplete: () {
                // This will be called when processing animation completes
                // But actual processing is handled in _processFinalConsultation
              },
            );
          }

          return AIProcessingProgressView(
            stepInfo: stepInfo,
            totalSteps: _getTotalSteps(),
            onComplete: () {
              // Animation complete, but processing is handled in _processFinalConsultation
            },
          );
        },
      );
    }

    // Complete state - show SOAP note
    if (_currentStatus == ConsultationStatus.complete) {
      return DocumentationView(
        documentation: _documentation,
        patientName: _patientName,
        onBack: () => Navigator.of(context).pop(),
        onNavigateToTasksLabs: _handleNavigateToTasksLabs,
        onNavigateToInitialRecording: _handleNavigateToInitialRecording,
        onSave: (soapData) async {
          if (_currentConsultationId != null) {
            try {
              // Update consultation with edited SOAP note
              await context.read<ConsultationCubit>().updateConsultation(
                _currentConsultationId!,
                {
                  'aiAnalysis': {
                    'documentation': {
                      'soapNote': soapData.toJson(),
                      'clientHandout': _documentation?.clientHandout?.toJson(),
                      'billing': _documentation?.billing?.toJson(),
                    },
                  },
                },
              );

              // Update local state
              setState(() {
                _documentation = DocumentationModel(
                  soapNote: soapData,
                  clientHandout: _documentation?.clientHandout,
                  billing: _documentation?.billing,
                );
              });
              getIt<NotificationCubit>().refreshUnreadNotifications();
            } catch (e) {
              log('Error saving SOAP note: $e');
              rethrow;
            }
          }
        },
        onSaveHandout: (handoutData) async {
          if (_currentConsultationId != null) {
            try {
              // Update consultation with edited client handout
              await context.read<ConsultationCubit>().updateConsultation(
                _currentConsultationId!,
                {
                  'aiAnalysis': {
                    'documentation': {
                      'soapNote': _documentation?.soapNote?.toJson(),
                      'clientHandout': handoutData.toJson(),
                      'billing': _documentation?.billing?.toJson(),
                    },
                  },
                },
              );

              // Update local state
              setState(() {
                _documentation = DocumentationModel(
                  soapNote: _documentation?.soapNote,
                  clientHandout: handoutData,
                  billing: _documentation?.billing,
                );
              });
              getIt<NotificationCubit>().refreshUnreadNotifications();
            } catch (e) {
              log('Error saving client handout: $e');
              rethrow;
            }
          }
        },
      );
    }

    // Default fallback
    return Scaffold(
      appBar: AppBar(
        title: const AppBarLogoTitle(),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing consultation workflow...'),
          ],
        ),
      ),
    );
  }
}

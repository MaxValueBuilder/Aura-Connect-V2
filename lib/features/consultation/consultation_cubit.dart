import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/consultation_model.dart';
import '../../services/consultation_service.dart';
import '../../core/constants/consultation_status.dart';
import 'consultation_state.dart';

/// Consultation Cubit for managing consultation state
class ConsultationCubit extends Cubit<ConsultationState> {
  final ConsultationService _consultationService;

  ConsultationCubit(this._consultationService)
    : super(const ConsultationState());

  /// Load all consultations
  Future<void> loadConsultations({
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
    bool refresh = false,
  }) async {
    try {
      emit(
        state.copyWith(
          isLoadingConsultations: true,
          status: refresh ? ConsultationStatusState.loading : state.status,
          errorMessage: '',
        ),
      );

      final result = await _consultationService.getConsultations(
        page: page,
        limit: limit,
        status: status,
        priority: priority,
      );

      final consultations = (result['consultations'] as List<ConsultationModel>)
          .cast<ConsultationModel>()
          .toList();

      // Calculate stats
      final stats = _calculateStats(consultations);

      emit(
        state.copyWith(
          status: ConsultationStatusState.loaded,
          consultations: consultations,
          stats: stats,
          pagination: result['pagination'],
          isLoadingConsultations: false,
          errorMessage: '',
        ),
      );
    } catch (e) {
      log('Error loading consultations: $e');
      emit(
        state.copyWith(
          status: ConsultationStatusState.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingConsultations: false,
        ),
      );
    }
  }

  /// Load single consultation
  Future<void> loadConsultation(String id) async {
    try {
      emit(state.copyWith(isLoadingConsultations: true, errorMessage: ''));

      final consultation = await _consultationService.getConsultation(id);

      emit(
        state.copyWith(
          currentConsultation: consultation,
          isLoadingConsultations: false,
          errorMessage: '',
        ),
      );
    } catch (e) {
      log('Error loading consultation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingConsultations: false,
        ),
      );
    }
  }

  /// Create new consultation
  Future<ConsultationModel?> createConsultation({
    String? patientId,
    ConsultationStatus status = ConsultationStatus.initialConsult,
    DateTime? startTime,
    String priority = 'medium',
    bool isEmergency = false,
    AIAnalysisModel? aiAnalysis,
  }) async {
    try {
      emit(state.copyWith(isCreatingConsultation: true, errorMessage: ''));

      final consultation = await _consultationService.createConsultation(
        patientId: patientId,
        status: status.apiValue,
        startTime: startTime ?? DateTime.now(),
        priority: priority,
        isEmergency: isEmergency,
        aiAnalysis: aiAnalysis,
      );

      log('Consultation created: $consultation');

      // Add to consultations list
      final updatedConsultations = [consultation, ...state.consultations];

      // Recalculate stats
      final stats = _calculateStats(updatedConsultations);

      emit(
        state.copyWith(
          consultations: updatedConsultations,
          currentConsultation: consultation,
          stats: stats,
          isCreatingConsultation: false,
          errorMessage: '',
        ),
      );

      return consultation;
    } catch (e) {
      log('Error creating consultation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isCreatingConsultation: false,
        ),
      );
      return null;
    }
  }

  /// Update consultation
  Future<void> updateConsultation(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      emit(state.copyWith(isUpdatingConsultation: true, errorMessage: ''));

      final updated = await _consultationService.updateConsultation(
        id,
        updates,
      );

      // Update in consultations list
      final updatedConsultations = state.consultations.map((c) {
        return c.id == id ? updated : c;
      }).toList();

      // Update current consultation if it's the one being updated
      ConsultationModel? currentConsultation = state.currentConsultation;
      if (currentConsultation?.id == id) {
        currentConsultation = updated;
      }

      // Recalculate stats
      final stats = _calculateStats(updatedConsultations);

      emit(
        state.copyWith(
          consultations: updatedConsultations,
          currentConsultation: currentConsultation,
          stats: stats,
          isUpdatingConsultation: false,
          errorMessage: '',
        ),
      );
    } catch (e) {
      log('Error updating consultation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isUpdatingConsultation: false,
        ),
      );
    }
  }

  /// Delete consultation
  Future<void> deleteConsultation(String id) async {
    try {
      emit(state.copyWith(isDeletingConsultation: true, errorMessage: ''));

      await _consultationService.deleteConsultation(id);

      // Remove from consultations list
      final updatedConsultations = state.consultations
          .where((c) => c.id != id)
          .toList();

      // Clear current consultation if it's the one being deleted
      ConsultationModel? currentConsultation = state.currentConsultation;
      if (currentConsultation?.id == id) {
        currentConsultation = null;
      }

      // Recalculate stats
      final stats = _calculateStats(updatedConsultations);

      emit(
        state.copyWith(
          consultations: updatedConsultations,
          currentConsultation: currentConsultation,
          stats: stats,
          isDeletingConsultation: false,
          errorMessage: '',
        ),
      );
    } catch (e) {
      log('Error deleting consultation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isDeletingConsultation: false,
        ),
      );
    }
  }

  /// Analyze consultation transcript
  Future<Map<String, dynamic>?> analyzeConsultation(String transcript) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.analyzeConsultation(transcript);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error analyzing consultation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Extract patient info from transcript
  Future<Map<String, dynamic>?> extractPatientInfo(String transcript) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.extractPatientInfo(transcript);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error extracting patient info: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Analyze lab results
  Future<Map<String, dynamic>?> analyzeLab(String imageUrl) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.analyzeLab(imageUrl);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error analyzing lab: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Generate SOAP note
  Future<Map<String, dynamic>?> generateSOAPNote(String transcript) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.generateSOAPNote(transcript);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error generating SOAP note: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Generate tasks from transcript
  Future<Map<String, dynamic>?> generateTasks(String transcript) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.generateTasks(transcript);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error generating tasks: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Generate patient name from transcript
  Future<Map<String, dynamic>?> generatePatientName(String transcript) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.generatePatientName(transcript);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error generating patient name: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Transcribe audio file
  Future<String?> transcribeAudio(String audioFilePath) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));
      log('Transcribe audio file path==========: $audioFilePath');
      final result = await _consultationService.transcribeAudio(audioFilePath);

      emit(state.copyWith(isProcessingAI: false));
      log('Transcribe audio result: $result');
      return result['transcript'] as String?;
    } catch (e) {
      log('Error transcribing audio: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Upload file
  Future<Map<String, dynamic>?> uploadFile(String filePath, String type) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.uploadFile(filePath, type);

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error uploading file: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Generate multimodal documentation
  Future<Map<String, dynamic>?> generateDocumentation({
    required String initialTranscript,
    String? finalTranscript,
    Map<String, dynamic>? labAnalysis,
    Map<String, dynamic>? patientInfo,
    String? consultationId,
  }) async {
    try {
      emit(state.copyWith(isProcessingAI: true, errorMessage: ''));

      final result = await _consultationService.generateMultimodalDocumentation(
        initialTranscript: initialTranscript,
        finalTranscript: finalTranscript,
        labAnalysis: labAnalysis,
        patientInfo: patientInfo,
        consultationId: consultationId,
      );

      emit(state.copyWith(isProcessingAI: false));
      return result;
    } catch (e) {
      log('Error generating documentation: $e');
      emit(
        state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isProcessingAI: false,
        ),
      );
      return null;
    }
  }

  /// Set filter status
  void setFilterStatus(String? status) {
    emit(state.copyWith(filterStatus: status));
  }

  /// Set filter priority
  void setFilterPriority(String? priority) {
    emit(state.copyWith(filterPriority: priority));
  }

  /// Set search term
  void setSearchTerm(String term) {
    emit(state.copyWith(searchTerm: term));
  }

  /// Clear filters
  void clearFilters() {
    emit(
      state.copyWith(filterStatus: null, filterPriority: null, searchTerm: ''),
    );
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }

  /// Set current consultation
  void setCurrentConsultation(ConsultationModel? consultation) {
    emit(state.copyWith(currentConsultation: consultation));
  }

  /// Calculate stats from consultations
  Map<String, dynamic> _calculateStats(List<ConsultationModel> consultations) {
    final activeCount = consultations.where((c) {
      return c.status == ConsultationStatus.initialConsult ||
          c.status == ConsultationStatus.initialComplete ||
          c.status == ConsultationStatus.finalConsult ||
          c.status == ConsultationStatus.processing;
    }).length;

    final completedCount = consultations.where((c) {
      return c.status == ConsultationStatus.complete ||
          c.status == ConsultationStatus.finalComplete;
    }).length;

    final today = DateTime.now();
    final completedToday = consultations.where((c) {
      if (c.status != ConsultationStatus.complete &&
          c.status != ConsultationStatus.finalComplete) {
        return false;
      }
      final consultDate = c.endTime ?? c.updatedAt;
      return consultDate.year == today.year &&
          consultDate.month == today.month &&
          consultDate.day == today.day;
    }).length;

    return {
      'totalConsultations': consultations.length,
      'activeConsultations': activeCount,
      'completedConsultations': completedCount,
      'completedToday': completedToday,
    };
  }
}

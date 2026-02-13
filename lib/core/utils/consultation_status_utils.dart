import '../constants/consultation_status.dart';
import '../../models/consultation_model.dart';

/// Utilities for consultation status management
class ConsultationStatusUtils {
  /// Get status color based on consultation status
  static String getStatusColor(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.initialConsult:
        return 'blue';
      case ConsultationStatus.patientExtraction:
        return 'indigo';
      case ConsultationStatus.patientReview:
        return 'purple';
      case ConsultationStatus.initialComplete:
        return 'green';
      case ConsultationStatus.labAnalysis:
        return 'yellow';
      case ConsultationStatus.finalConsult:
        return 'orange';
      case ConsultationStatus.processing:
        return 'indigo';
      case ConsultationStatus.finalComplete:
      case ConsultationStatus.complete:
        return 'green';
    }
  }

  /// Get next status in workflow
  static ConsultationStatus getNextStatus(ConsultationStatus currentStatus) {
    switch (currentStatus) {
      case ConsultationStatus.initialConsult:
        return ConsultationStatus
            .initialComplete; // Skip extraction, go to tasks
      case ConsultationStatus.patientExtraction:
        return ConsultationStatus.initialComplete;
      case ConsultationStatus.patientReview:
        return ConsultationStatus.initialComplete;
      case ConsultationStatus.initialComplete:
        return ConsultationStatus.finalConsult;
      case ConsultationStatus.finalConsult:
        return ConsultationStatus.processing;
      case ConsultationStatus.processing:
        return ConsultationStatus.complete;
      case ConsultationStatus.labAnalysis:
        return ConsultationStatus.finalConsult;
      case ConsultationStatus.finalComplete:
        return ConsultationStatus.complete;
      case ConsultationStatus.complete:
        return ConsultationStatus.complete; // Already complete
    }
  }

  /// Get previous status in workflow
  static ConsultationStatus? getPreviousStatus(
    ConsultationStatus currentStatus,
  ) {
    switch (currentStatus) {
      case ConsultationStatus.patientExtraction:
      case ConsultationStatus.patientReview:
        return ConsultationStatus.initialConsult;
      case ConsultationStatus.initialComplete:
        return null; // Don't go back to initial recording
      case ConsultationStatus.finalConsult:
        return ConsultationStatus.initialComplete;
      case ConsultationStatus.processing:
        return ConsultationStatus.finalConsult;
      case ConsultationStatus.complete:
      case ConsultationStatus.finalComplete:
        return ConsultationStatus.processing;
      default:
        return null;
    }
  }

  /// Check if consultation is active (in progress)
  static bool isActive(ConsultationStatus status) {
    return status == ConsultationStatus.initialConsult ||
        status == ConsultationStatus.initialComplete ||
        status == ConsultationStatus.finalConsult ||
        status == ConsultationStatus.processing ||
        status == ConsultationStatus.patientExtraction ||
        status == ConsultationStatus.patientReview;
  }

  /// Check if consultation is completed
  static bool isCompleted(ConsultationStatus status) {
    return status == ConsultationStatus.complete ||
        status == ConsultationStatus.finalComplete;
  }

  /// Get current step info (step number, title, description) for UI display
  static Map<String, dynamic> getCurrentStepInfo(ConsultationStatus status) {
    final stepProgress = getWorkflowProgress(status);
    final step = stepProgress['step'] as int;

    String title;
    String description;

    switch (status) {
      case ConsultationStatus.initialConsult:
        title = 'Initial Recording';
        description = 'Record consultation with patient';
        break;
      case ConsultationStatus.patientExtraction:
        title = 'AI Processing';
        description = 'Extracting patient information';
        break;
      case ConsultationStatus.patientReview:
        title = 'Patient Review';
        description = 'Review extracted patient info';
        break;
      case ConsultationStatus.initialComplete:
        title = 'Tasks & Labs';
        description = 'Complete any required tasks';
        break;
      case ConsultationStatus.labAnalysis:
        title = 'Lab Analysis';
        description = 'Upload and analyze lab results';
        break;
      case ConsultationStatus.finalConsult:
        title = 'Final Recording';
        description = 'Record final consultation';
        break;
      case ConsultationStatus.processing:
        title = 'AI Processing';
        description = 'Generating documentation';
        break;
      case ConsultationStatus.finalComplete:
      case ConsultationStatus.complete:
        title = 'Complete';
        description = 'Consultation finished';
        break;
    }

    return {'step': step, 'title': title, 'description': description};
  }

  /// Get workflow progress information
  static Map<String, dynamic> getWorkflowProgress(ConsultationStatus status) {
    final step = status.stepNumber;
    final totalSteps = ConsultationStatus.totalSteps;
    final percentage = (step / totalSteps * 100).round();

    return {
      'step': step,
      'total': totalSteps,
      'percentage': percentage,
      'label': status.label,
    };
  }

  /// Check if consultation has initial recording
  static bool hasInitialRecording(ConsultationModel consultation) {
    return consultation.transcript != null &&
        consultation.transcript!.isNotEmpty;
  }

  /// Check if consultation has patient info
  static bool hasPatientInfo(ConsultationModel consultation) {
    return consultation.aiAnalysis?.patientName != null &&
        consultation.aiAnalysis!.patientName!.isNotEmpty;
  }

  /// Check if consultation has lab analysis
  static bool hasLabAnalysis(ConsultationModel consultation) {
    return consultation.aiAnalysis?.labAnalysis != null;
  }

  /// Check if consultation has final transcript
  static bool hasFinalTranscript(ConsultationModel consultation) {
    return consultation.aiAnalysis?.finalTranscript != null &&
        consultation.aiAnalysis!.finalTranscript!.isNotEmpty;
  }

  /// Get action button text based on status
  static String getActionButtonText(
    ConsultationStatus status, {
    bool isMobile = false,
  }) {
    switch (status) {
      case ConsultationStatus.initialConsult:
        return isMobile ? 'Start Initial Recording' : 'Start Recording';
      case ConsultationStatus.patientExtraction:
        return 'AI Extracting...';
      case ConsultationStatus.patientReview:
        return 'Review Patient Info';
      case ConsultationStatus.initialComplete:
        return 'Review & Continue';
      case ConsultationStatus.finalConsult:
        return isMobile ? 'Start Final Recording' : 'Start Final Recording';
      case ConsultationStatus.processing:
        return 'View Progress';
      case ConsultationStatus.complete:
      case ConsultationStatus.finalComplete:
        return 'Completed';
      case ConsultationStatus.labAnalysis:
        return 'Analyzing Labs...';
    }
  }

  /// Can navigate to specific step?
  static bool canNavigateToStep(
    ConsultationStatus targetStatus,
    ConsultationStatus currentStatus, {
    bool hasInitialRecording = false,
    bool hasPatientInfo = false,
  }) {
    // Can always go to current step
    if (targetStatus == currentStatus) return true;

    // Can only go to previous steps or completed steps
    switch (targetStatus) {
      case ConsultationStatus.initialConsult:
        return hasInitialRecording;
      case ConsultationStatus.patientReview:
        return hasPatientInfo;
      case ConsultationStatus.initialComplete:
        return hasPatientInfo;
      case ConsultationStatus.finalConsult:
        return currentStatus == ConsultationStatus.processing ||
            currentStatus == ConsultationStatus.complete ||
            currentStatus == ConsultationStatus.finalComplete;
      case ConsultationStatus.processing:
        return currentStatus == ConsultationStatus.complete ||
            currentStatus == ConsultationStatus.finalComplete;
      default:
        return false;
    }
  }
}

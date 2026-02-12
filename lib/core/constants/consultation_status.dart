/// Consultation workflow status enum
enum ConsultationStatus {
  initialConsult,
  patientExtraction,
  patientReview,
  initialComplete,
  labAnalysis,
  finalConsult,
  finalComplete,
  processing,
  complete;

  String get label {
    switch (this) {
      case ConsultationStatus.initialConsult:
        return 'Initial Consultation';
      case ConsultationStatus.patientExtraction:
        return 'Extracting Patient Info';
      case ConsultationStatus.patientReview:
        return 'Review Patient Info';
      case ConsultationStatus.initialComplete:
        return 'Tasks & Lab Upload';
      case ConsultationStatus.labAnalysis:
        return 'Lab Analysis';
      case ConsultationStatus.finalConsult:
        return 'Final Consultation';
      case ConsultationStatus.finalComplete:
        return 'Final Complete';
      case ConsultationStatus.processing:
        return 'Processing';
      case ConsultationStatus.complete:
        return 'Complete';
    }
  }

  String get apiValue {
    switch (this) {
      case ConsultationStatus.initialConsult:
        return 'INITIAL_CONSULT';
      case ConsultationStatus.patientExtraction:
        return 'PATIENT_EXTRACTION';
      case ConsultationStatus.patientReview:
        return 'PATIENT_REVIEW';
      case ConsultationStatus.initialComplete:
        return 'INITIAL_COMPLETE';
      case ConsultationStatus.labAnalysis:
        return 'LAB_ANALYSIS';
      case ConsultationStatus.finalConsult:
        return 'FINAL_CONSULT';
      case ConsultationStatus.finalComplete:
        return 'FINAL_COMPLETE';
      case ConsultationStatus.processing:
        return 'PROCESSING';
      case ConsultationStatus.complete:
        return 'COMPLETE';
    }
  }

  static ConsultationStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'INITIAL_CONSULT':
        return ConsultationStatus.initialConsult;
      case 'PATIENT_EXTRACTION':
        return ConsultationStatus.patientExtraction;
      case 'PATIENT_REVIEW':
        return ConsultationStatus.patientReview;
      case 'INITIAL_COMPLETE':
        return ConsultationStatus.initialComplete;
      case 'LAB_ANALYSIS':
        return ConsultationStatus.labAnalysis;
      case 'FINAL_CONSULT':
        return ConsultationStatus.finalConsult;
      case 'FINAL_COMPLETE':
        return ConsultationStatus.finalComplete;
      case 'PROCESSING':
        return ConsultationStatus.processing;
      case 'COMPLETE':
        return ConsultationStatus.complete;
      case 'IN-PROGRESS':
        return ConsultationStatus.initialComplete;
      case 'COMPLETED':
        return ConsultationStatus.complete;
      default:
        return ConsultationStatus.initialConsult;
    }
  }

  int get stepNumber {
    switch (this) {
      case ConsultationStatus.initialConsult:
        return 1;
      case ConsultationStatus.patientExtraction:
      case ConsultationStatus.patientReview:
        return 2;
      case ConsultationStatus.initialComplete:
        return 2;
      case ConsultationStatus.labAnalysis:
        return 3;
      case ConsultationStatus.finalConsult:
        return 3;
      case ConsultationStatus.finalComplete:
      case ConsultationStatus.processing:
        return 4;
      case ConsultationStatus.complete:
        return 4;
    }
  }

  static int get totalSteps => 5;
}

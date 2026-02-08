import 'package:equatable/equatable.dart';
import '../../models/consultation_model.dart';
import '../../core/constants/consultation_status.dart';

/// Consultation feature states
enum ConsultationStatusState { initial, loading, loaded, error }

/// Consultation state class
class ConsultationState extends Equatable {
  final ConsultationStatusState status;
  final List<ConsultationModel> consultations;
  final ConsultationModel? currentConsultation;
  final Map<String, dynamic>? stats;
  final String errorMessage;
  final Map<String, dynamic>? pagination;

  // Filter states
  final String? filterStatus;
  final String? filterPriority;
  final String searchTerm;

  // Loading states
  final bool isLoadingConsultations;
  final bool isCreatingConsultation;
  final bool isUpdatingConsultation;
  final bool isDeletingConsultation;
  final bool isProcessingAI;

  const ConsultationState({
    this.status = ConsultationStatusState.initial,
    this.consultations = const [],
    this.currentConsultation,
    this.stats,
    this.errorMessage = '',
    this.pagination,
    this.filterStatus,
    this.filterPriority,
    this.searchTerm = '',
    this.isLoadingConsultations = false,
    this.isCreatingConsultation = false,
    this.isUpdatingConsultation = false,
    this.isDeletingConsultation = false,
    this.isProcessingAI = false,
  });

  ConsultationState copyWith({
    ConsultationStatusState? status,
    List<ConsultationModel>? consultations,
    ConsultationModel? currentConsultation,
    Map<String, dynamic>? stats,
    String? errorMessage,
    Map<String, dynamic>? pagination,
    String? filterStatus,
    String? filterPriority,
    String? searchTerm,
    bool? isLoadingConsultations,
    bool? isCreatingConsultation,
    bool? isUpdatingConsultation,
    bool? isDeletingConsultation,
    bool? isProcessingAI,
  }) {
    return ConsultationState(
      status: status ?? this.status,
      consultations: consultations ?? this.consultations,
      currentConsultation: currentConsultation ?? this.currentConsultation,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
      filterStatus: filterStatus ?? this.filterStatus,
      filterPriority: filterPriority ?? this.filterPriority,
      searchTerm: searchTerm ?? this.searchTerm,
      isLoadingConsultations:
          isLoadingConsultations ?? this.isLoadingConsultations,
      isCreatingConsultation:
          isCreatingConsultation ?? this.isCreatingConsultation,
      isUpdatingConsultation:
          isUpdatingConsultation ?? this.isUpdatingConsultation,
      isDeletingConsultation:
          isDeletingConsultation ?? this.isDeletingConsultation,
      isProcessingAI: isProcessingAI ?? this.isProcessingAI,
    );
  }

  bool get isLoading => status == ConsultationStatusState.loading;
  bool get hasError => status == ConsultationStatusState.error;
  bool get isLoaded => status == ConsultationStatusState.loaded;

  /// Get active consultations
  List<ConsultationModel> get activeConsultations {
    return consultations.where((c) {
      return c.status == ConsultationStatus.initialConsult ||
          c.status == ConsultationStatus.initialComplete ||
          c.status == ConsultationStatus.finalConsult ||
          c.status == ConsultationStatus.processing;
    }).toList();
  }

  /// Get completed consultations
  List<ConsultationModel> get completedConsultations {
    return consultations.where((c) {
      return c.status == ConsultationStatus.complete ||
          c.status == ConsultationStatus.finalComplete;
    }).toList();
  }

  /// Get filtered consultations
  List<ConsultationModel> get filteredConsultations {
    var filtered = consultations;

    // Filter by status
    if (filterStatus != null && filterStatus!.isNotEmpty) {
      filtered = filtered.where((c) {
        if (filterStatus == 'active') {
          return c.status == ConsultationStatus.initialConsult ||
              c.status == ConsultationStatus.initialComplete ||
              c.status == ConsultationStatus.finalConsult ||
              c.status == ConsultationStatus.processing;
        }
        if (filterStatus == 'completed') {
          return c.status == ConsultationStatus.complete ||
              c.status == ConsultationStatus.finalComplete;
        }
        return c.status.apiValue.toLowerCase() == filterStatus!.toLowerCase();
      }).toList();
    }

    // Filter by priority
    if (filterPriority != null && filterPriority!.isNotEmpty) {
      filtered = filtered.where((c) => c.priority == filterPriority).toList();
    }

    // Filter by search term
    if (searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filtered = filtered.where((c) {
        return (c.patientName?.toLowerCase().contains(term) ?? false) ||
            (c.veterinarianName?.toLowerCase().contains(term) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  List<Object?> get props => [
    status,
    consultations,
    currentConsultation,
    stats,
    errorMessage,
    pagination,
    filterStatus,
    filterPriority,
    searchTerm,
    isLoadingConsultations,
    isCreatingConsultation,
    isUpdatingConsultation,
    isDeletingConsultation,
    isProcessingAI,
  ];
}

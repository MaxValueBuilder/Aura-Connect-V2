import 'package:equatable/equatable.dart';
import '../../models/patient_model.dart';

class PatientState extends Equatable {
  final List<PatientModel> patients;
  final PatientModel? currentPatient;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String errorMessage;
  final String searchTerm;
  final String? filterSpecies;
  final String? filterStatus;

  const PatientState({
    this.patients = const [],
    this.currentPatient,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage = '',
    this.searchTerm = '',
    this.filterSpecies,
    this.filterStatus,
  });

  PatientState copyWith({
    List<PatientModel>? patients,
    PatientModel? currentPatient,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    String? searchTerm,
    String? filterSpecies,
    String? filterStatus,
    bool clearError = false,
    bool clearCurrentPatient = false,
  }) {
    return PatientState(
      patients: patients ?? this.patients,
      currentPatient: clearCurrentPatient ? null : (currentPatient ?? this.currentPatient),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      searchTerm: searchTerm ?? this.searchTerm,
      filterSpecies: filterSpecies ?? this.filterSpecies,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  List<PatientModel> get filteredPatients {
    var filtered = patients;

    // Filter by search term
    if (searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filtered = filtered.where((patient) {
        return patient.name.toLowerCase().contains(term) ||
            patient.ownerName.toLowerCase().contains(term) ||
            (patient.breed?.toLowerCase().contains(term) ?? false);
      }).toList();
    }

    // Filter by species
    if (filterSpecies != null && filterSpecies!.isNotEmpty && filterSpecies != 'all') {
      filtered = filtered.where((patient) {
        return patient.species.toLowerCase() == filterSpecies!.toLowerCase();
      }).toList();
    }

    // Filter by status
    if (filterStatus != null && filterStatus!.isNotEmpty && filterStatus != 'all') {
      filtered = filtered.where((patient) {
        if (filterStatus == 'Active') {
          return patient.isActive;
        } else if (filterStatus == 'Inactive') {
          return !patient.isActive;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  @override
  List<Object?> get props => [
        patients,
        currentPatient,
        isLoading,
        isCreating,
        isUpdating,
        isDeleting,
        errorMessage,
        searchTerm,
        filterSpecies,
        filterStatus,
      ];
}


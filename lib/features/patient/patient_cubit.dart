import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientService _patientService;

  PatientCubit(this._patientService) : super(const PatientState());

  Future<void> loadPatients({bool refresh = false}) async {
    try {
      log('🔍 [PatientCubit] Loading patients...');
      emit(state.copyWith(isLoading: true, errorMessage: '', clearError: true));

      log('🔍 [PatientCubit] Calling patient service...');
      final patients = await _patientService.getPatients(limit: 50);
      log('✅ [PatientCubit] Received ${patients.length} patients');

      emit(state.copyWith(
        patients: patients,
        isLoading: false,
        errorMessage: '',
        clearError: true,
      ));
      log('✅ [PatientCubit] Patients loaded successfully');
    } catch (e, stackTrace) {
      log('❌ [PatientCubit] Error loading patients: $e');
      log('❌ [PatientCubit] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        clearError: false,
      ));
    }
  }

  Future<void> loadPatient(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: '', clearError: true));

      final patient = await _patientService.getPatient(id);

      emit(state.copyWith(
        currentPatient: patient,
        isLoading: false,
        errorMessage: '',
        clearError: true,
      ));
    } catch (e) {
      log('Error loading patient: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        clearError: false,
      ));
    }
  }

  Future<PatientModel?> createPatient({
    required String name,
    required String species,
    String? breed,
    int? age,
    double? weight,
    required String ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalHistory,
    String? microchipNumber,
    String? color,
    String gender = 'unknown',
    bool isActive = true,
  }) async {
    try {
      emit(state.copyWith(isCreating: true, errorMessage: '', clearError: true));

      final patient = await _patientService.createPatient(
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        medicalHistory: medicalHistory,
        microchipNumber: microchipNumber,
        color: color,
        gender: gender,
        isActive: isActive,
      );

      // Add to patients list
      final updatedPatients = [patient, ...state.patients];

      emit(state.copyWith(
        patients: updatedPatients,
        currentPatient: patient,
        isCreating: false,
        errorMessage: '',
        clearError: true,
      ));

      return patient;
    } catch (e) {
      log('Error creating patient: $e');
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        clearError: false,
      ));
      return null;
    }
  }

  Future<PatientModel?> updatePatient(
    String id, {
    String? name,
    String? species,
    String? breed,
    int? age,
    double? weight,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalHistory,
    String? microchipNumber,
    String? color,
    String? gender,
    bool? isActive,
  }) async {
    try {
      emit(state.copyWith(isUpdating: true, errorMessage: '', clearError: true));

      final updated = await _patientService.updatePatient(
        id,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        medicalHistory: medicalHistory,
        microchipNumber: microchipNumber,
        color: color,
        gender: gender,
        isActive: isActive,
      );

      // Update in patients list
      final updatedPatients = state.patients.map((p) {
        return p.id == id ? updated : p;
      }).toList();

      // Update current patient if it's the one being updated
      PatientModel? currentPatient = state.currentPatient;
      if (currentPatient?.id == id) {
        currentPatient = updated;
      }

      emit(state.copyWith(
        patients: updatedPatients,
        currentPatient: currentPatient,
        isUpdating: false,
        errorMessage: '',
        clearError: true,
      ));

      return updated;
    } catch (e) {
      log('Error updating patient: $e');
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        clearError: false,
      ));
      return null;
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      emit(state.copyWith(isDeleting: true, errorMessage: '', clearError: true));

      await _patientService.deletePatient(id);

      // Remove from patients list
      final updatedPatients = state.patients.where((p) => p.id != id).toList();

      // Clear current patient if it's the one being deleted
      PatientModel? currentPatient = state.currentPatient;
      if (currentPatient?.id == id) {
        currentPatient = null;
      }

      emit(state.copyWith(
        patients: updatedPatients,
        currentPatient: currentPatient,
        isDeleting: false,
        errorMessage: '',
        clearError: true,
      ));

      return true;
    } catch (e) {
      log('Error deleting patient: $e');
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        clearError: false,
      ));
      return false;
    }
  }

  void setSearchTerm(String term) {
    emit(state.copyWith(searchTerm: term));
  }

  void setFilterSpecies(String? species) {
    emit(state.copyWith(filterSpecies: species));
  }

  void setFilterStatus(String? status) {
    emit(state.copyWith(filterStatus: status));
  }

  void clearFilters() {
    emit(state.copyWith(
      searchTerm: '',
      filterSpecies: null,
      filterStatus: null,
    ));
  }

  void setCurrentPatient(PatientModel? patient) {
    emit(state.copyWith(currentPatient: patient));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: '', clearError: true));
  }
}


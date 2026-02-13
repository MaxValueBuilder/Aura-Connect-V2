import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;

  SettingsCubit(this._settingsService) : super(const SettingsState());

  /// Load user profile – requires userId
  Future<void> loadProfile(String userId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final profile = await _settingsService.getProfile(userId);
      emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update user profile
  Future<bool> updateProfile(
    String userId, {
    String? avatar,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      emit(
        state.copyWith(
          isSaving: true,
          errorMessage: null,
          successMessage: null,
        ),
      );

      final updatedProfile = await _settingsService.updateProfile(
        userId,
        avatar: avatar,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        licenseNumber: licenseNumber,
        specialization: specialization,
      );

      emit(
        state.copyWith(
          profile: updatedProfile,
          isSaving: false,
          successMessage: 'Profile updated successfully',
          clearError: true,
        ),
      );
      return true;
    } catch (e, stackTrace) {
      log('Error updating profile: $e\n$stackTrace');
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          clearSuccess: true,
        ),
      );
      return false;
    }
  }

  /// Load clinic information – requires clinicId
  Future<void> loadClinic(String clinicId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final clinic = await _settingsService.getClinic(clinicId);
      emit(
        state.copyWith(
          clinic: clinic,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update clinic information
  Future<bool> updateClinic(
    String clinicId, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? licenseNumber,
  }) async {
    try {
      emit(
        state.copyWith(
          isSaving: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
      await _settingsService.updateClinic(
        clinicId,
        clinicName: name,
        clinicAddress: address,
        phone: phone,
        email: email,
        website: website,
        clinicLicense: licenseNumber,
      );
      // Refetch clinic to get updated data (server may not return body on success)
      await loadClinic(clinicId);
      emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Clinic updated successfully',
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString(),
          clearSuccess: true,
        ),
      );
      return false;
    }
  }

  /// Load clinic members (team) – requires clinicId
  Future<void> loadClinicMembers(String clinicId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final users = await _settingsService.getClinicMembers(clinicId);
      emit(state.copyWith(clinicUsers: users, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Invite user to clinic
  Future<bool> inviteUser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    required String clinicId,
  }) async {
    try {
      emit(
        state.copyWith(
          isInviting: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
      await _settingsService.inviteUser(
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      await loadClinicMembers(clinicId);
      emit(
        state.copyWith(
          isInviting: false,
          successMessage: 'Invitation sent successfully',
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isInviting: false,
          errorMessage: e.toString(),
          clearSuccess: true,
        ),
      );
      return false;
    }
  }

  /// Remove user from clinic
  Future<bool> removeUser(String userId, String clinicId) async {
    try {
      emit(
        state.copyWith(
          isInviting: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
      await _settingsService.removeUser(userId);
      await loadClinicMembers(clinicId);
      emit(
        state.copyWith(
          isInviting: false,
          successMessage: 'User removed successfully',
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isInviting: false,
          errorMessage: e.toString(),
          clearSuccess: true,
        ),
      );
      return false;
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void clearSuccess() => emit(state.copyWith(clearSuccess: true));

  /// Load notification preferences – requires userId
  Future<void> loadNotificationPreferences(String userId) async {
    try {
      emit(state.copyWith(isLoadingNotifications: true, errorMessage: null));
      final preferences = await _settingsService.getNotificationPreferences(userId);
      emit(
        state.copyWith(
          notificationPreferences: preferences,
          isLoadingNotifications: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingNotifications: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update notification preferences (sends full notif map, matches web)
  Future<bool> updateNotificationPreferences(
    String userId,
    Map<String, bool> notif,
  ) async {
    try {
      emit(
        state.copyWith(
          isSavingNotifications: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
      await _settingsService.updateNotificationPreferences(userId, notif);
      emit(
        state.copyWith(
          notificationPreferences: notif,
          isSavingNotifications: false,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSavingNotifications: false,
          errorMessage: e.toString(),
          clearSuccess: true,
        ),
      );
      return false;
    }
  }
}

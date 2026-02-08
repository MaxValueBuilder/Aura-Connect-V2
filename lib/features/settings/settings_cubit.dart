import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;
  String? _userEmail;

  SettingsCubit(this._settingsService) : super(const SettingsState());

  /// Set user email for filtering profile
  void setUserEmail(String email) {
    _userEmail = email;
  }

  /// Load user profile
  Future<void> loadProfile({String? userEmail}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final profile = await _settingsService.getProfile(
        userEmail: userEmail ?? _userEmail,
      );
      emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      log('🔍 [SettingsCubit] Updating profile...');
      emit(
        state.copyWith(
          isSaving: true,
          errorMessage: null,
          successMessage: null,
        ),
      );

      log('🔍 [SettingsCubit] Calling settings service...');
      final updatedProfile = await _settingsService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        licenseNumber: licenseNumber,
        specialization: specialization,
      );

      log(
        '✅ [SettingsCubit] Profile updated successfully: ${updatedProfile.email}',
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
      log('❌ [SettingsCubit] Error updating profile: $e');
      log('❌ [SettingsCubit] Stack trace: $stackTrace');
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

  /// Load clinic information
  Future<void> loadClinic() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final clinic = await _settingsService.getClinic();
      final users = clinic['users'] as List<dynamic>? ?? [];
      emit(
        state.copyWith(
          clinic: clinic,
          clinicUsers: users.cast<Map<String, dynamic>>(),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update clinic information
  Future<bool> updateClinic({
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
      final updatedClinic = await _settingsService.updateClinic(
        name: name,
        address: address,
        phone: phone,
        email: email,
        website: website,
        licenseNumber: licenseNumber,
      );
      emit(
        state.copyWith(
          clinic: updatedClinic,
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

  /// Load clinic users
  Future<void> loadClinicUsers() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final users = await _settingsService.getClinicUsers();
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
      // Reload clinic users
      await loadClinicUsers();
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
  Future<bool> removeUser(String userId) async {
    try {
      emit(
        state.copyWith(
          isInviting: true, // Use isInviting for user removal too
          errorMessage: null,
          successMessage: null,
        ),
      );
      await _settingsService.removeUser(userId);
      // Reload clinic users
      await loadClinicUsers();
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

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Clear success message
  void clearSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }

  /// Load notification preferences
  Future<void> loadNotificationPreferences() async {
    try {
      emit(state.copyWith(isLoadingNotifications: true, errorMessage: null));
      final preferences = await _settingsService.getNotificationPreferences();
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

  /// Update notification preferences (auto-save)
  Future<bool> updateNotificationPreferences({
    bool? emailConsultationCompletion,
    bool? emailSystemAlerts,
    bool? emailBillingUpdates,
    bool? inAppNotifications,
  }) async {
    try {
      emit(
        state.copyWith(
          isSavingNotifications: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
      final updatedPreferences = await _settingsService
          .updateNotificationPreferences(
            emailConsultationCompletion: emailConsultationCompletion,
            emailSystemAlerts: emailSystemAlerts,
            emailBillingUpdates: emailBillingUpdates,
            inAppNotifications: inAppNotifications,
          );
      emit(
        state.copyWith(
          notificationPreferences: updatedPreferences,
          isSavingNotifications: false,
          clearError: true,
          clearSuccess: true, // Don't show success message for auto-save
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

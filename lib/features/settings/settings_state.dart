import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

class SettingsState extends Equatable {
  final UserModel? profile;
  final Map<String, dynamic>? clinic;
  final List<Map<String, dynamic>> clinicUsers;
  final bool isLoading;
  final bool isSaving;
  final bool isInviting;
  final bool isLoadingNotifications;
  final bool isSavingNotifications;
  final Map<String, bool>? notificationPreferences;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.profile,
    this.clinic,
    this.clinicUsers = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isInviting = false,
    this.isLoadingNotifications = false,
    this.isSavingNotifications = false,
    this.notificationPreferences,
    this.errorMessage,
    this.successMessage,
  });

  SettingsState copyWith({
    UserModel? profile,
    Map<String, dynamic>? clinic,
    List<Map<String, dynamic>>? clinicUsers,
    bool? isLoading,
    bool? isSaving,
    bool? isInviting,
    bool? isLoadingNotifications,
    bool? isSavingNotifications,
    Map<String, bool>? notificationPreferences,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      clinic: clinic ?? this.clinic,
      clinicUsers: clinicUsers ?? this.clinicUsers,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isInviting: isInviting ?? this.isInviting,
      isLoadingNotifications:
          isLoadingNotifications ?? this.isLoadingNotifications,
      isSavingNotifications:
          isSavingNotifications ?? this.isSavingNotifications,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    profile,
    clinic,
    clinicUsers,
    isLoading,
    isSaving,
    isInviting,
    isLoadingNotifications,
    isSavingNotifications,
    notificationPreferences,
    errorMessage,
    successMessage,
  ];
}

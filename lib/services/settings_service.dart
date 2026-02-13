import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Service for settings-related API calls.
/// Matches web API: getUserProfile, updateUserProfile, getClinicInfo, updateClinicInfo,
/// getClinicMembers, removeUser, inviteUser, getNotifStatus, updateNotif.
class SettingsService {
  final Dio _dio;

  SettingsService(this._dio);

  /// Get user profile – GET /api/users/:userId
  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      final userMap = response.data['user'] as Map<String, dynamic>?;
      if (userMap == null) throw Exception('User not found');
      return UserModel.fromJson(userMap);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile – PUT /api/users/:userId
  Future<UserModel> updateProfile(
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
      final data = <String, dynamic>{};
      if (avatar != null) data['avatar'] = avatar;
      if (email != null) data['email'] = email;
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
      if (specialization != null) data['specialization'] = specialization;

      final response = await _dio.put('/users/$userId', data: data);
      final raw = response.data;
      final userMap = raw is Map && raw['user'] != null
          ? raw['user'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return UserModel.fromJson(Map<String, dynamic>.from(userMap));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get clinic info – GET /api/clinic/:clinicId
  Future<Map<String, dynamic>> getClinic(String clinicId) async {
    try {
      final response = await _dio.get('/clinic/$clinicId');
      return response.data['clinic'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update clinic info – PUT /api/clinic/:clinicId
  Future<void> updateClinic(
    String clinicId, {
    String? clinicName,
    String? clinicAddress,
    String? phone,
    String? email,
    String? website,
    String? clinicLicense,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (clinicName != null) data['clinicName'] = clinicName;
      if (clinicAddress != null) data['clinicAddress'] = clinicAddress;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (website != null) data['website'] = website;
      if (clinicLicense != null) data['clinicLicense'] = clinicLicense;

      await _dio.put('/clinic/$clinicId', data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get clinic members – GET /api/clinic/getmembers/:clinicId
  Future<List<Map<String, dynamic>>> getClinicMembers(String clinicId) async {
    try {
      final response = await _dio.get('/clinic/getmembers/$clinicId');
      final users = response.data['users'] as List<dynamic>? ?? [];
      return users.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove user from clinic – DELETE /api/clinic/removeuser/:userId
  Future<void> removeUser(String userId) async {
    try {
      await _dio.delete('/clinic/removeuser/$userId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Invite user to clinic – POST /api/clinic/invite
  Future<Map<String, dynamic>> inviteUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/clinic/invite',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'role': role,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get notification preferences – GET /api/notifications/getstatus/:userId
  /// Returns { success, status } with status: { emailConsultationCompletion, emailSystemAlerts, emailBillingUpdates, inAppNotifications }
  Future<Map<String, bool>> getNotificationPreferences(String userId) async {
    try {
      final response = await _dio.get('/notifications/getstatus/$userId');
      final status = response.data['status'] as Map<String, dynamic>?;
      if (status == null) {
        return {
          'emailConsultationCompletion': true,
          'emailSystemAlerts': true,
          'emailBillingUpdates': true,
          'inAppNotifications': true,
        };
      }
      return {
        'emailConsultationCompletion': status['emailConsultationCompletion'] as bool? ?? true,
        'emailSystemAlerts': status['emailSystemAlerts'] as bool? ?? true,
        'emailBillingUpdates': status['emailBillingUpdates'] as bool? ?? true,
        'inAppNotifications': status['inAppNotifications'] as bool? ?? true,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update notification preferences – PUT /api/notifications/update
  /// Body: { userId, notif: { emailConsultationCompletion, emailSystemAlerts, emailBillingUpdates, inAppNotifications } }
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> notif,
  ) async {
    try {
      final notifMap = <String, dynamic>{
        'emailConsultationCompletion': notif['emailConsultationCompletion'] ?? true,
        'emailSystemAlerts': notif['emailSystemAlerts'] ?? true,
        'emailBillingUpdates': notif['emailBillingUpdates'] ?? true,
        'inAppNotifications': notif['inAppNotifications'] ?? true,
      };
      await _dio.put('/notifications/update', data: {'userId': userId, 'notif': notifMap});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message =
          error.response!.data['error'] ??
          error.response!.data['message'] ??
          'An error occurred';

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}

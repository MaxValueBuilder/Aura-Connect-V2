import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Service for settings-related API calls (profile, clinic, etc.)
class SettingsService {
  final Dio _dio;

  SettingsService(this._dio);

  /// Get current user profile
  /// Note: Backend doesn't have a GET /users/profile endpoint,
  /// so we get the user from the users list by email
  Future<UserModel> getProfile({String? userEmail}) async {
    try {
      print('🔍 [SettingsService] Getting profile for email: $userEmail');
      // Get all users and find the current user by email
      // The backend returns users filtered by clinic
      final response = await _dio.get('/users');
      print('🔍 [SettingsService] Response status: ${response.statusCode}');
      print(
        '🔍 [SettingsService] Response data type: ${response.data.runtimeType}',
      );
      print('🔍 [SettingsService] Full response data: ${response.data}');

      final users = response.data['users'] as List<dynamic>? ?? [];
      print('🔍 [SettingsService] Users list length: ${users.length}');

      if (users.isEmpty) {
        throw Exception('User not found');
      }

      // If email is provided, filter by it; otherwise return first user
      Map<String, dynamic> userMap;
      if (userEmail != null) {
        print('🔍 [SettingsService] Filtering by email: $userEmail');
        final foundUser = users.firstWhere(
          (user) => (user as Map<String, dynamic>)['email'] == userEmail,
          orElse: () => users.first,
        );
        userMap = foundUser as Map<String, dynamic>;
      } else {
        userMap = users.first as Map<String, dynamic>;
      }

      print('🔍 [SettingsService] User map: $userMap');
      print('🔍 [SettingsService] User map keys: ${userMap.keys.toList()}');

      // Log each field
      userMap.forEach((key, value) {
        print(
          '🔍 [SettingsService] User - $key: $value (type: ${value.runtimeType})',
        );
      });

      final user = UserModel.fromJson(userMap);
      print('✅ [SettingsService] Successfully parsed user: ${user.email}');
      return user;
    } on DioException catch (e) {
      print('❌ [SettingsService] DioException: $e');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ [SettingsService] Unexpected error: $e');
      print('❌ [SettingsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? licenseNumber,
    String? specialization,
  }) async {
    try {
      print('🔍 [SettingsService] Updating profile with data:');
      print('🔍 [SettingsService] - firstName: $firstName');
      print('🔍 [SettingsService] - lastName: $lastName');
      print('🔍 [SettingsService] - phone: $phone');
      print('🔍 [SettingsService] - licenseNumber: $licenseNumber');
      print('🔍 [SettingsService] - specialization: $specialization');

      final requestData = {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (specialization != null) 'specialization': specialization,
        'sendNotification': true, // Trigger system alert notification
      };
      print('🔍 [SettingsService] Request data: $requestData');

      final response = await _dio.put('/users/profile', data: requestData);

      print('🔍 [SettingsService] Response status: ${response.statusCode}');
      print('🔍 [SettingsService] Response data: ${response.data}');
      print(
        '🔍 [SettingsService] Response data type: ${response.data.runtimeType}',
      );

      final userData =
          response.data['user'] as Map<String, dynamic>? ?? response.data;
      print('🔍 [SettingsService] User data: $userData');
      print('🔍 [SettingsService] User data keys: ${userData.keys.toList()}');

      // Log each field
      userData.forEach((key, value) {
        print(
          '🔍 [SettingsService] User - $key: $value (type: ${value.runtimeType})',
        );
      });

      final user = UserModel.fromJson(userData);
      print(
        '✅ [SettingsService] Successfully parsed updated user: ${user.email}',
      );
      return user;
    } on DioException catch (e) {
      print('❌ [SettingsService] DioException: $e');
      if (e.response != null) {
        print('❌ [SettingsService] Response data: ${e.response!.data}');
      }
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ [SettingsService] Unexpected error: $e');
      print('❌ [SettingsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get clinic information
  Future<Map<String, dynamic>> getClinic() async {
    try {
      final response = await _dio.get('/clinic');
      return response.data['clinic'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update clinic information
  Future<Map<String, dynamic>> updateClinic({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? licenseNumber,
  }) async {
    try {
      final response = await _dio.put(
        '/clinic',
        data: {
          if (name != null) 'name': name,
          if (address != null) 'address': address,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (website != null) 'website': website,
          if (licenseNumber != null) 'licenseNumber': licenseNumber,
          'sendNotification': true,
        },
      );
      return response.data['clinic'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get clinic users (team members)
  Future<List<Map<String, dynamic>>> getClinicUsers() async {
    try {
      final response = await _dio.get('/clinic');
      final clinic = response.data['clinic'] as Map<String, dynamic>;
      final users = clinic['users'] as List<dynamic>? ?? [];
      return users.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Invite user to clinic
  Future<Map<String, dynamic>> inviteUser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/clinic/invite',
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove user from clinic
  Future<void> removeUser(String userId) async {
    try {
      await _dio.delete('/clinic/users/$userId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await _dio.get('/users/notifications');
      final preferences = response.data['preferences'] as Map<String, dynamic>;
      return {
        'emailConsultationCompletion':
            preferences['emailConsultationCompletion'] as bool? ?? true,
        'emailSystemAlerts': preferences['emailSystemAlerts'] as bool? ?? true,
        'emailBillingUpdates':
            preferences['emailBillingUpdates'] as bool? ?? true,
        'inAppNotifications':
            preferences['inAppNotifications'] as bool? ?? true,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update notification preferences
  Future<Map<String, bool>> updateNotificationPreferences({
    bool? emailConsultationCompletion,
    bool? emailSystemAlerts,
    bool? emailBillingUpdates,
    bool? inAppNotifications,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (emailConsultationCompletion != null) {
        requestData['emailConsultationCompletion'] =
            emailConsultationCompletion;
      }
      if (emailSystemAlerts != null) {
        requestData['emailSystemAlerts'] = emailSystemAlerts;
      }
      if (emailBillingUpdates != null) {
        requestData['emailBillingUpdates'] = emailBillingUpdates;
      }
      if (inAppNotifications != null) {
        requestData['inAppNotifications'] = inAppNotifications;
      }

      final response = await _dio.put(
        '/users/notifications',
        data: requestData,
      );
      final preferences = response.data['preferences'] as Map<String, dynamic>;
      return {
        'emailConsultationCompletion':
            preferences['emailConsultationCompletion'] as bool,
        'emailSystemAlerts': preferences['emailSystemAlerts'] as bool,
        'emailBillingUpdates': preferences['emailBillingUpdates'] as bool,
        'inAppNotifications': preferences['inAppNotifications'] as bool,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
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

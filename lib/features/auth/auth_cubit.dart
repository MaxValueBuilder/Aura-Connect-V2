import 'dart:developer';

import 'package:aura/models/user_model.dart';
import 'package:aura/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Auth0 auth0;
  final FlutterSecureStorage secureStorage;
  final AuthService authService;

  AuthCubit(this.auth0, this.secureStorage, this.authService)
    : super(const AuthState());

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // Check if user has valid credentials
      final hasCredentials = await auth0.credentialsManager
          .hasValidCredentials();

      if (hasCredentials) {
        final credentials = await auth0.credentialsManager.credentials();

        // Get user info
        final userProfile = await auth0.api.userProfile(
          accessToken: credentials.accessToken,
        );

        // Store tokens
        await _storeTokens(credentials);

        // Store user email
        await secureStorage.write(key: 'user_email', value: userProfile.email);

        // Check clinic setup status
        final hasClinic = await _checkClinicSetup();

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: credentials.accessToken,
            userEmail: userProfile.email,
            hasClinic: hasClinic,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Login with Auth0
  Future<void> login() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final credentials = await auth0
          .webAuthentication(scheme: "com.example.aura")
          .login(useHTTPS: true);
      log("credentials: $credentials");
      log("credentials refresh token: ${credentials.refreshToken}");
      log("credentials id token: ${credentials.idToken}");
      log("credentials token type: ${credentials.tokenType}");

      // Get user info
      final userProfile = await auth0.api.userProfile(
        accessToken: credentials.accessToken,
      );

      // Store tokens
      await _storeTokens(credentials);

      // Store user email
      await secureStorage.write(key: 'user_email', value: userProfile.email);

      // Check clinic setup status
      final hasClinic = await _checkClinicSetup();

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: credentials.accessToken,
          userEmail: userProfile.email,
          hasClinic: hasClinic,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Signup with Auth0
  Future<void> signup() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final credentials = await auth0
          .webAuthentication(scheme: "com.example.aura")
          .login(
            audience: AppConstants.auth0Audience,
            scopes: {'openid', 'profile', 'email', 'offline_access'},
            parameters: {'screen_hint': 'signup'},
            useHTTPS: true,
          );

      // Get user info
      final userProfile = await auth0.api.userProfile(
        accessToken: credentials.accessToken,
      );

      // Store tokens
      await _storeTokens(credentials);

      // Store user email
      await secureStorage.write(key: 'user_email', value: userProfile.email);

      // Check clinic setup status (new users won't have clinic yet)
      final hasClinic = await _checkClinicSetup();

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: credentials.accessToken,
          userEmail: userProfile.email,
          hasClinic: hasClinic,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Setup clinic for authenticated user
  Future<void> setupClinic({
    required String clinicName,
    required String clinicEmail,
    String? clinicPhone,
    required String firstName,
    required String lastName,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      await authService.setupClinic(
        clinicName: clinicName,
        clinicEmail: clinicEmail,
        clinicPhone: clinicPhone,
        firstName: firstName,
        lastName: lastName,
      );

      // Update state to indicate clinic is now set up
      emit(state.copyWith(status: AuthStatus.authenticated, hasClinic: true));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  /// Check if user has clinic setup
  Future<bool> _checkClinicSetup() async {
    try {
      final result = await authService.checkClinicSetup();
      return result['hasClinic'] ?? false;
    } catch (e) {
      log('Error checking clinic setup: $e');
      // If check fails, assume no clinic (new user)
      return false;
    }
  }

  /// Refresh clinic setup status
  Future<void> refreshClinicStatus() async {
    if (state.isAuthenticated) {
      try {
        final hasClinic = await _checkClinicSetup();
        emit(state.copyWith(hasClinic: hasClinic));
      } catch (e) {
        log('Error refreshing clinic status: $e');
      }
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // await auth0.webAuthentication().logout();
      await _clearTokens();

      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Store tokens securely
  Future<void> _storeTokens(Credentials credentials) async {
    await secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: credentials.accessToken,
    );
    if (credentials.refreshToken != null) {
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: credentials.refreshToken,
      );
    }
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: 'user_email');
  }

  /// Update user
  void setUser(UserModel user) {
    emit(state.copyWith(user: user));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }
}

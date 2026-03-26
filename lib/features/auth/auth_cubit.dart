import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:aura/models/user_model.dart';
import 'package:aura/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';

import '../../../core/constants/app_constants.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage secureStorage;
  final AuthService authService;

  AuthCubit(this.secureStorage, this.authService) : super(const AuthState());

  /// Initialize auth state from stored JWT and user
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final token = await secureStorage.read(key: AppConstants.accessTokenKey);
      if (token == null || token.isEmpty) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final userJson = await secureStorage.read(key: AppConstants.userDataKey);
      String? userEmail;
      UserModel? user;
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final map = jsonDecode(userJson) as Map<String, dynamic>;
          user = UserModel.fromJson(map);
          userEmail = user.email;
        } catch (_) {
          userEmail = await secureStorage.read(key: 'user_email');
        }
      } else {
        userEmail = await secureStorage.read(key: 'user_email');
      }

      // Same as web: derive hasClinic from stored user (user.clinicId)
      final hasClinic = _hasClinicFromStoredUser(userJson);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
          userEmail: userEmail,
          user: user,
          hasClinic: hasClinic,
        ),
      );
    } catch (e) {
      log('Auth initialize error: $e');
      await _clearTokens();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    try {
      emit(
        state.copyWith(
          status: AuthStatus.loading,
          errorMessage: '',
          loadingSource: 'email',
        ),
      );

      final data = await authService.login(email: email, password: password);
      final token = data['token'] as String?;
      final userMap = data['user'] as Map<String, dynamic>?;

      if (token == null) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid login response',
            clearLoadingSource: true,
          ),
        );
        return;
      }

      final refreshToken = data['refresh_token'] as String?;
      await _storeAuth(
        token: token,
        userMap: userMap,
        refreshToken: refreshToken,
      );
      final userEmail = userMap?['email']?.toString() ?? email;
      UserModel? user;
      if (userMap != null) {
        user = UserModel.fromJson(userMap);
      }

      // Same as web LogIn.tsx: use user.clinicId from login response
      final hasClinic = _hasClinicFromUserMap(userMap);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
          userEmail: userEmail,
          user: user,
          hasClinic: hasClinic,
          clearLoadingSource: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: message,
          clearLoadingSource: true,
        ),
      );
    }
  }

  /// Sign up with email, password, first name, last name.
  /// Backend requires email confirmation: on success we emit [AuthStatus.signupSuccess]
  /// with the server message; user must confirm email then sign in from login screen.
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      emit(
        state.copyWith(
          status: AuthStatus.loading,
          errorMessage: '',
          loadingSource: 'email',
        ),
      );

      final data = await authService.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final success = data['success'] == true;
      final message = data['message']?.toString() ?? '';

      if (success && message.isNotEmpty) {
        // Email confirmation required: show success and let user go to login
        emit(
          state.copyWith(
            status: AuthStatus.signupSuccess,
            signupSuccessMessage: message,
            clearLoadingSource: true,
          ),
        );
        return;
      }

      // If backend ever returns token on signup (e.g. no email confirmation), handle it
      final token = data['token'] as String?;
      final userMap = data['user'] as Map<String, dynamic>?;
      if (token != null && userMap != null) {
        await _storeAuth(token: token, userMap: userMap);
        final userEmail = userMap['email']?.toString() ?? email;
        final user = UserModel.fromJson(userMap);
        final hasClinic = _hasClinicFromUserMap(userMap);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: token,
            userEmail: userEmail,
            user: user,
            hasClinic: hasClinic,
            clearLoadingSource: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.signupSuccess,
          signupSuccessMessage:
              'Account created. Please check your email to confirm, then sign in.',
          clearLoadingSource: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: message,
          clearLoadingSource: true,
        ),
      );
    }
  }

  /// Sign in with Google (gets ID token from plugin, sends to backend POST /auth/google).
  Future<void> loginWithGoogle() async {
    try {
      emit(
        state.copyWith(
          status: AuthStatus.loading,
          errorMessage: '',
          loadingSource: 'google',
        ),
      );

      // IMPORTANT:
      // The backend usually validates the ID token `aud` against the *Web* client id.
      // If we pass an iOS client id here, iOS will return an ID token with `aud`
      // set to that iOS client id, and many backends will reject it as
      // "Unacceptable audience".
      //
      // Use the Web client id for *all* platforms when requesting the server
      // audience token. iOS native configuration (URL schemes / GIDClientID) is
      // handled in `ios/Runner/Info.plist`.
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
      final rawNonce = _generateRawNonce();
      final hashedNonce = _sha256OfString(rawNonce);
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: webClientId?.isNotEmpty == true ? webClientId : null,
        nonce: hashedNonce,
      );

      final account = await googleSignIn.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );

      log('Google account: ${account.authentication.idToken}');

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'Could not get Google ID token. Try again or use email sign in.',
            clearLoadingSource: true,
          ),
        );
        return;
      }

      final data = await authService.loginWithGoogle(
        idToken: idToken,
        nonce: rawNonce,
      );
      final token = data['token'] as String?;
      final userMap = data['user'] as Map<String, dynamic>?;

      if (token == null) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid login response from server',
            clearLoadingSource: true,
          ),
        );
        return;
      }

      final refreshToken = data['refresh_token'] as String?;
      await _storeAuth(
        token: token,
        userMap: userMap,
        refreshToken: refreshToken,
      );
      final userEmail = userMap?['email']?.toString() ?? account.email;
      UserModel? user;
      if (userMap != null) {
        user = UserModel.fromJson(userMap);
      }
      final hasClinic = _hasClinicFromUserMap(userMap);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
          userEmail: userEmail,
          user: user,
          hasClinic: hasClinic,
          clearLoadingSource: true,
        ),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearLoadingSource: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: e.description ?? 'Google sign-in failed',
            clearLoadingSource: true,
          ),
        );
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: message,
          clearLoadingSource: true,
        ),
      );
    }
  }

  void clearSignupSuccess() {
    if (state.status == AuthStatus.signupSuccess) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Setup clinic for authenticated user (calls POST /api/clinic/register)
  Future<void> setupClinic({
    required String clinicName,
    required String clinicEmail,
    String? clinicPhone,
    String? clinicWebsite,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final data = await authService.setupClinic(
        clinicName: clinicName,
        clinicEmail: clinicEmail,
        clinicPhone: clinicPhone,
        clinicWebsite: clinicWebsite,
      );

      // Update stored user with new clinicId (same as web updating localStorage user)
      final clinicId = data['clinic']?['id']?.toString();
      if (clinicId != null) {
        await _updateStoredUserClinicId(clinicId);
      }

      emit(state.copyWith(status: AuthStatus.authenticated, hasClinic: true));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  /// Same as web: hasClinic from user object (no separate API).
  bool _hasClinicFromUserMap(Map<String, dynamic>? userMap) {
    if (userMap == null) return false;
    final id = userMap['clinicId'];
    return id != null && id.toString().trim().isNotEmpty;
  }

  /// Read stored user JSON and return true if user has clinicId.
  bool _hasClinicFromStoredUser(String? userJson) {
    if (userJson == null || userJson.isEmpty) return false;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return _hasClinicFromUserMap(map);
    } catch (_) {
      return false;
    }
  }

  /// After clinic register, update stored user with clinicId so next launch has it.
  Future<void> _updateStoredUserClinicId(String clinicId) async {
    final userJson = await secureStorage.read(key: AppConstants.userDataKey);
    if (userJson == null || userJson.isEmpty) return;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      map['clinicId'] = clinicId;
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(map),
      );
    } catch (e) {
      log('Error updating stored user clinicId: $e');
    }
  }

  /// Refresh clinic setup status from stored user (no server call).
  Future<void> refreshClinicStatus() async {
    if (state.isAuthenticated) {
      final userJson = await secureStorage.read(key: AppConstants.userDataKey);
      final hasClinic = _hasClinicFromStoredUser(userJson);
      emit(state.copyWith(hasClinic: hasClinic));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _clearTokens();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _storeAuth({
    required String token,
    Map<String, dynamic>? userMap,
    String? refreshToken,
  }) async {
    await secureStorage.write(key: AppConstants.accessTokenKey, value: token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    }
    if (userMap != null) {
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(userMap),
      );
      final email = userMap['email']?.toString();
      if (email != null) {
        await secureStorage.write(key: 'user_email', value: email);
      }
    }
  }

  Future<void> _clearTokens() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: AppConstants.userDataKey);
    await secureStorage.delete(key: 'user_email');
  }

  void setUser(UserModel user) {
    emit(state.copyWith(user: user));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }

  String _generateRawNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}

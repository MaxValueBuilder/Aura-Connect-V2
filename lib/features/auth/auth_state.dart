part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  signupSuccess,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? accessToken;
  final String? userEmail;
  final UserModel? user;
  final String errorMessage;
  final bool hasClinic;

  /// When status is signupSuccess, message to show (e.g. "Check your email to confirm").
  final String? signupSuccessMessage;

  /// When status is loading: 'email' for login/signup form, 'google' for Google sign-in.
  final String? loadingSource;

  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.userEmail,
    this.user,
    this.errorMessage = '',
    this.hasClinic = false,
    this.signupSuccessMessage,
    this.loadingSource,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? userEmail,
    UserModel? user,
    String? errorMessage,
    bool? hasClinic,
    String? signupSuccessMessage,
    String? loadingSource,
    bool clearLoadingSource = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      userEmail: userEmail ?? this.userEmail,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      hasClinic: hasClinic ?? this.hasClinic,
      signupSuccessMessage: signupSuccessMessage ?? this.signupSuccessMessage,
      loadingSource: clearLoadingSource ? null : (loadingSource ?? this.loadingSource),
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isLoadingGoogle => status == AuthStatus.loading && loadingSource == 'google';
  bool get isLoadingEmail => status == AuthStatus.loading && loadingSource != 'google';
  bool get hasError => status == AuthStatus.error;
  bool get isSignupSuccess => status == AuthStatus.signupSuccess;

  @override
  List<Object?> get props => [
    status,
    accessToken,
    userEmail,
    user,
    errorMessage,
    hasClinic,
    signupSuccessMessage,
    loadingSource,
  ];
}

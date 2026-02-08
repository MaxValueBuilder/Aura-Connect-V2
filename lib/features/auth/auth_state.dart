part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? accessToken;
  final String? userEmail;
  final UserModel? user;
  final String errorMessage;
  final bool hasClinic;

  const AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.userEmail,
    this.user,
    this.errorMessage = '',
    this.hasClinic = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? userEmail,
    UserModel? user,
    String? errorMessage,
    bool? hasClinic,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      userEmail: userEmail ?? this.userEmail,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      hasClinic: hasClinic ?? this.hasClinic,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, accessToken, userEmail, user, errorMessage, hasClinic];
}


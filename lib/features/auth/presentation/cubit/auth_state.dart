part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? message;

  const AuthState._({
    required this.status,
    this.user,
    this.message,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.failure(String message)
      : this._(status: AuthStatus.failure, message: message);
  const AuthState.actionSuccess(String message)
      : this._(status: AuthStatus.actionSuccess, message: message);

  @override
  List<Object?> get props => [status, user?.uid, message];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  actionSuccess,
}

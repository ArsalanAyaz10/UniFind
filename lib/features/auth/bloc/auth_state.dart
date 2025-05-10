abstract class AuthState {}

class AuthInitial extends AuthState {} //nothing happened yet.

class AuthLoading extends AuthState {} //  we are waiting for the result.

class AuthSuccess extends AuthState {} // signup or login succeeded.

class AuthLoggedOut extends AuthState {} // for logout

class PasswordResetSuccess extends AuthState {}

//failure in sign up or login.
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

part of 'login_controller.dart';

sealed class LoginState {
  const LoginState();
}

class NotAuthenticated extends LoginState {}

class AuthenticatedByGoogle extends LoginState {}

class Loading extends LoginState {}

class LoginError extends LoginState {
  final String errorMessage;

  const LoginError({required this.errorMessage});
}

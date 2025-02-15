part of 'login_controller.dart';

sealed class LoginEvent {
  const LoginEvent();
}

class PerformGoogleAuth extends LoginEvent {}

part of 'login_controller.dart';

sealed class LoginEvent {
  const LoginEvent();
}

class PerformGoogleAuth extends LoginEvent {}

class RetrieveUspCourses extends LoginEvent {
  RetrieveUspCourses({required this.carrerCode});
  int carrerCode;
}

class UspCourseSelected extends LoginEvent {
  UspCourseSelected({required this.courseName});
  String courseName;
}

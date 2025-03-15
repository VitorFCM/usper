import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/authentication/google_authentication_exceptions.dart';
import 'package:usper/services/authentication/google_authentication_interface.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/utils/courses_requests/get_usp_carrers.dart';
import 'package:usper/utils/courses_requests/get_usp_courses.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginController extends Bloc<LoginEvent, LoginState> {
  GoogleAuthenticationInterface googleAuth;
  UsperUser? user;
  bool? isNewUser;
  RepositoryInterface repositoryService;
  Future<Map<int, String>>? uspCarrersCodes;

  LoginController({required this.googleAuth, required this.repositoryService})
      : super(NotAuthenticated()) {
    on<PerformGoogleAuth>(_performGoogleAuth);
    on<RetrieveUspCourses>(_retrieveUspCourses);
    on<UspCourseSelected>(_updateUserCourse);
  }

  void _performGoogleAuth(
      PerformGoogleAuth event, Emitter<LoginState> emit) async {
    emit(Loading());
    try {
      user = await googleAuth.performGoogleLogin();
      isNewUser = await repositoryService.insertUser(user!);
      if (isNewUser!) {
        uspCarrersCodes = getUspCarrers();
      }
      emit(AuthenticatedByGoogle());
    } on NotAUniversityEmail {
      emit(const LoginError(
          errorMessage:
              "O email selecionado não é da USP. Por favor, selecione o email da universidade"));
    } catch (e) {
      print(e.toString());
      emit(const LoginError(
          errorMessage:
              "Erro desconhecido. Por favor, tente novamente mais tarde"));
    }
  }

  void _retrieveUspCourses(
      RetrieveUspCourses event, Emitter<LoginState> emit) async {
    emit(UspCoursesList(courses: await getUspCourses(event.carrerCode)));
  }

  void _updateUserCourse(
      UspCourseSelected event, Emitter<LoginState> emit) async {
    try {
      user!.course = event.courseName;
      await repositoryService.updateUser(user!);
      emit(UspCourseUpdated());
    } catch (e) {
      print(e);
    }
  }
}

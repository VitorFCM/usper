import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/authentication/google_authentication_exceptions.dart';
import 'package:usper/services/authentication/google_authentication_interface.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginController extends Bloc<LoginEvent, LoginState> {
  GoogleAuthenticationInterface googleAuth;
  UsperUser? user;
  RepositoryInterface repositoryService;

  LoginController({required this.googleAuth, required this.repositoryService})
      : super(NotAuthenticated()) {
    on<PerformGoogleAuth>(_performGoogleAuth);
  }

  void _performGoogleAuth(
      PerformGoogleAuth event, Emitter<LoginState> emit) async {
    emit(Loading());
    try {
      user = await googleAuth.performGoogleLogin();
      await repositoryService.insertUser(user!);
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
}

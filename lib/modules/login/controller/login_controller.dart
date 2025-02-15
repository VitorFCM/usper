import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/exceptions/google_authentication_exceptions.dart';
import 'package:usper/services/interfaces/google_authentication_interface.dart';
import 'package:usper/utils/database/insert_data.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginController extends Bloc<LoginEvent, LoginState> {
  GoogleAuthenticationInterface googleAuth;
  UsperUser? user;

  LoginController({required this.googleAuth}) : super(NotAuthenticated()) {
    on<PerformGoogleAuth>(_performGoogleAuth);
  }

  void _performGoogleAuth(
      PerformGoogleAuth event, Emitter<LoginState> emit) async {
    emit(Loading());
    try {
      user = await googleAuth.performGoogleLogin();
      await insertUserDatabase(user!);
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

  Future<void> insertUserDatabase(UsperUser user) async {
    try {
      await insertData(DatabaseTables.users, {
        "email": user.email,
        "image_link": user.imageLink,
        "first_name": user.firstName,
        "last_name": user.lastName
      });
    } on PostgrestException catch (e) {
      if (e.code != null && "23505".compareTo(e.code!) != 0) rethrow;
    }
  }
}

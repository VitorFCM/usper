import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/google_login_button.dart';
import 'package:usper/widgets/loading_widget.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        child: BlocConsumer<LoginController, LoginState>(
      listener: (context, state) {
        if (state is AuthenticatedByGoogle) {
          Navigator.popAndPushNamed(context, '/home');
        }
        if (state is LoginError) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.errorMessage));
        }
      },
      builder: (context, state) {
        if (state is Loading) {
          return LoadingWidget(
            infoSection: ChangingTextWidget(texts: const [
              "Saindo da aula",
              "Estudando pra prova",
              "Fazendo login"
            ]),
          );
        }
        return loginScreen(context);
      },
    ));
  }

  Widget loginScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Image(image: AssetImage('assets/usp.png')),
        Align(
          alignment: Alignment.bottomCenter,
          child: GoogleLoginButton(
              onPressed: () => BlocProvider.of<LoginController>(context)
                  .add(PerformGoogleAuth())),
        )
      ],
    );
  }
}

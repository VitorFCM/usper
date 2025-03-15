import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/widgets/text_dropdown_menu.dart';

class UspCourseSelector extends StatelessWidget {
  UspCourseSelector({super.key, required this.uspCarrers});

  Map<int, String> uspCarrers;

  @override
  Widget build(BuildContext context) {
    LoginController loginController = BlocProvider.of<LoginController>(context);

    return Dialog(
        insetPadding: const EdgeInsets.only(right: 16.0, left: 16.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        backgroundColor: blue,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "Parece que você acabou de chegar aqui! Selecione o seu curso",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500, color: white)),
              const SizedBox(
                height: 15,
              ),
              TextDropdownMenu.fromMap(
                values: uspCarrers,
                label: "Unidade",
                onSelectedCallback: (int carrerCode) => loginController
                    .add(RetrieveUspCourses(carrerCode: carrerCode)),
                width: MediaQuery.of(context).size.width * 0.85,
              ),
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<LoginController, LoginState>(
                  buildWhen: (previous, current) => current is UspCoursesList,
                  builder: (context, state) {
                    List<String> dropdownValues = state is UspCoursesList
                        ? state.courses
                        : ["Sem cursos"];
                    return TextDropdownMenu.fromList(
                        values: dropdownValues,
                        label: "Cursos",
                        onSelectedCallback: (String courseName) {
                          //=>
                          print("adicionando: $courseName");
                          loginController
                              .add(UspCourseSelected(courseName: courseName));
                          Navigator.of(context).pop();
                        },
                        width: MediaQuery.of(context).size.width * 0.85);
                  })
            ],
          ),
        ));
  }
}

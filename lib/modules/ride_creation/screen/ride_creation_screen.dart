import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/ride_creation/controller/ride_creation_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/page_title.dart';

class RideCreationScreen extends StatelessWidget {
  const RideCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    int seatsCounter = 0;

    return BaseScreen(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: titleOcupation),
          child: PageTitle(title: "Criação de\ncarona"),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: lighterBlue,
            ),
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                textFormField("Origem"),
                const SizedBox(height: 10),
                textFormField("Destino"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        //flex: 2,
                        child: infoInput("Horario de Partida", yellow,
                            Text("00:00"), Colors.black, 550)),
                    SizedBox(width: 10),
                    Expanded(
                        flex: 1,
                        child: infoInput(
                            "Vagas",
                            Colors.black,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      BlocProvider.of<RideCreationController>(
                                              context)
                                          .add(const SeatsCounterDecreased());
                                    },
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      color: white,
                                    )),
                                BlocBuilder<RideCreationController,
                                        RideCreationState>(
                                    builder: (context, state) {
                                  if (state is SeatsCounterNewValue) {
                                    seatsCounter = state.seats;
                                  }
                                  return Text(
                                    "${seatsCounter}",
                                    style: const TextStyle(color: white),
                                  );
                                }),
                                IconButton(
                                    onPressed: () {
                                      BlocProvider.of<RideCreationController>(
                                              context)
                                          .add(const SeatsCounterIncreased());
                                    },
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: white,
                                    )),
                              ],
                            ),
                            white,
                            150)),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                        flex: 1,
                        child: button("Cancelar", white, 500,
                            () => Navigator.pop(context), Colors.black)),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: button(
                            "Criar carona",
                            Colors.black,
                            150,
                            () => print("Apertou")
                                /*BlocProvider.of<RideCreationController>(context)
                                    .add(const RideCreationFinished())*/,
                            yellow)),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    ));
  }

  TextButton button(String title, Color textColor, double minWidth,
      VoidCallback onPressedFunction, Color backgroundColor) {
    return TextButton(
      onPressed: onPressedFunction,
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: const EdgeInsets.all(15),
          backgroundColor: backgroundColor,
          minimumSize: Size(minWidth, 50)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget infoInput(String title, Color color, Widget inputWidget,
      Color textColor, double minWidth) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 10),
            ),
          ),
          Container(
            height: 40,
            alignment: Alignment.center,
            child: inputWidget,
          )
        ],
      ),
    );
  }

  TextFormField textFormField(String hintText) {
    return TextFormField(
      textAlignVertical: const TextAlignVertical(y: 0.0),
      cursorColor: black,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(
          borderSide: const BorderSide(style: BorderStyle.none, width: 0.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

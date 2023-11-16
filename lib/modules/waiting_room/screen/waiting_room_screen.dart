import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/utils/calc_text_size.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/arrow.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/core/classes/class_user.dart';
import 'package:usper/widgets/user_image.dart';

class WaitingRoomScreen extends StatelessWidget {
  WaitingRoomScreen({super.key});

  late double _txtInfoMaxWidth;
  static const double lateralPadding = 15;

  final User u = User(
      "Vitor",
      "Favrin Carrera Miguel",
      "Engenharia de Computacao",
      "https://images.trustinnews.pt/uploads/sites/5/2019/10/o-que-nunca-se-deve-fazer-a-um-gato-2.jpeg");

  final RideData r = RideData(
      originName: "Engcomppppppppppppppppp",
      destName: "Instituto de ciencias matematicas e computacao",
      originCoord: LatLng(0.0, 0.0),
      destCoord: LatLng(0.0, 0.0),
      departTime: DateTime.now(),
      vehicle: Vehicle(4, "Corsa", "ABC-7777", "red"));

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    double passSectionHeight = MediaQuery.of(context).size.height * 0.2;
    if (passSectionHeight >= 400) passSectionHeight = 400;

    _txtInfoMaxWidth = MediaQuery.of(context).size.width * 0.3;
    return BaseScreen(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleOcupation),
              child: PageTitle(title: "Esperando\npassageiros"),
            ),
            const SizedBox(height: 20),
            rideInfoCard(u, r, context),
            const SizedBox(height: 20),
            const Text(
              "Passageiros aprovados",
              style: TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: passSectionHeight),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    passengerCard(u),
                    const SizedBox(height: 15),
                    passengerCard(u),
                    const SizedBox(height: 15),
                    passengerCard(u),
                    const SizedBox(height: 15),
                    passengerCard(u),
                    const SizedBox(height: 15),
                    passengerCard(u),
                    const SizedBox(height: 15),
                    passengerCard(u),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.center,
                child: button("Cancelar", white, buttonWidth,
                    () => Navigator.pop(context), Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget rideInfoCard(User driver, RideData rideData, BuildContext context) {
    const double edgeInsets = 10;

    double destNameWidth =
        calcTextSize(r.destName, const TextStyle(fontSize: 12)).width;

    double arrowEnd = (destNameWidth < _txtInfoMaxWidth)
        ? MediaQuery.of(context).size.width -
            2 * lateralPadding -
            2 * edgeInsets -
            20 -
            calcTextSize(r.originName, const TextStyle(fontSize: 12)).width -
            destNameWidth
        : _txtInfoMaxWidth - 20;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: yellow,
        ),
        padding: const EdgeInsets.all(edgeInsets),
        child: Column(
          children: [
            Row(
              children: [
                UserImage(user: driver, radius: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textInfo(driver.firstName, Colors.black, 18),
                    textInfo(driver.course, Colors.black, 12)
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.all(edgeInsets),
                  child: Column(
                    children: [
                      textInfo("Partida", white, 13),
                      textInfo(datetimeToString(r.departTime), white, 12)
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                textInfo(r.originName, Colors.black, 12),
                Expanded(
                  child: Container(
                    height: 50,
                    child: CustomPaint(
                      painter: Arrow(
                          p1: const Offset(10, 25), p2: Offset(arrowEnd, 25)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: textInfo(r.destName, Colors.black, 12),
                )
              ],
            ),
          ],
        ));
  }

  TextButton button(String title, Color textColor, double minWidth,
      VoidCallback onPressedFunction, Color backgroundColor) {
    return TextButton(
      onPressed: onPressedFunction,
      style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: backgroundColor,
          minimumSize: Size(minWidth, 50)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget passengerCard(User passenger) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: lighterBlue,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          UserImage(user: passenger, radius: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textInfo(passenger.firstName, white, 18),
              textInfo(passenger.course, white, 12)
            ],
          )
        ],
      ),
    );
  }

  Widget textInfo(String info, Color color, double fontSize) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _txtInfoMaxWidth),
      child: Text(
        info,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
    );
  }
}

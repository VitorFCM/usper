import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/utils/calc_text_size.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/arrow.dart';
import 'package:usper/widgets/info_input_card.dart';
import 'package:usper/widgets/user_image.dart';

class RideInfoCard extends StatelessWidget {
  RideInfoCard({super.key, required this.rideData});

  final RideData rideData;
  late double _txtInfoMaxWidth;

  @override
  Widget build(BuildContext context) {
    const double edgeInsets = 10;
    const double lateralPadding = 15;

    _txtInfoMaxWidth = MediaQuery.of(context).size.width * 0.3;
    double destNameWidth = calcTextWidth(rideData.destName);

    double arrowEnd = (destNameWidth < _txtInfoMaxWidth)
        ? MediaQuery.of(context).size.width -
            2 * lateralPadding -
            2 * edgeInsets -
            20 -
            calcTextWidth(rideData.originName) -
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
                UserImage(user: rideData.driver, radius: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textInfo(rideData.driver.firstName, Colors.black, 18),
                    textInfo(rideData.driver.course, Colors.black, 12)
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
                      textInfo(datetimeToString(rideData.departTime), white, 12)
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                textInfo(rideData.originName, Colors.black, 12),
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
                  child: textInfo(rideData.destName, Colors.black, 12),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoInputCard(
                    title: "Modelo",
                    color: Colors.black,
                    inputWidget: Text(
                      rideData.vehicle.model,
                      style: const TextStyle(color: white),
                    ),
                    textColor: white,
                    minWidth: 100),
                InfoInputCard(
                    title: "Placa",
                    color: Colors.black,
                    inputWidget: Text(
                      rideData.vehicle.licensePlate,
                      style: const TextStyle(color: white),
                    ),
                    textColor: white,
                    minWidth: 100)
              ],
            )
          ],
        ));
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

  double calcTextWidth(String info) {
    double textWidth = calcTextSize(info, const TextStyle(fontSize: 12)).width;
    return textWidth > _txtInfoMaxWidth ? _txtInfoMaxWidth : textWidth;
  }
}

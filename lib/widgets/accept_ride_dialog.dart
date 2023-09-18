import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_user.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/ride_info.dart';
import 'package:usper/widgets/user_image.dart';

class AcceptRideDialog extends StatelessWidget {
  final User driver;
  final RideData rideData;

  const AcceptRideDialog(
      {super.key, required this.driver, required this.rideData});

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.3;
    const double infoFontSize = 15;

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      backgroundColor: lighterBlue,
      actions: [acceptRideButton(context)],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.clear_rounded, color: white, size: 30)),
          ),
          UserImage(user: driver, radius: 70),
          Text(driver.firstName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: white, fontSize: 20)),
          Text(driver.course,
              textAlign: TextAlign.center,
              style: const TextStyle(color: white, fontSize: 15)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RideInfo(
                          type: "Origem",
                          value: rideData.originName,
                          maxWidth: dialogWidth,
                          fontSize: infoFontSize),
                      RideInfo(
                          type: "Horario",
                          value: datetimeToString(rideData.departTime),
                          maxWidth: dialogWidth,
                          fontSize: infoFontSize),
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RideInfo(
                          type: "Destino",
                          value: rideData.destName,
                          maxWidth: dialogWidth,
                          fontSize: infoFontSize),
                      RideInfo(
                          type: "Vagas",
                          value: rideData.vehicle.seats.toString(),
                          maxWidth: dialogWidth,
                          fontSize: infoFontSize)
                    ]),
              ],
            ),
          )
        ],
      ),
    );
  }

  TextButton acceptRideButton(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
          backgroundColor: yellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50)),
      child: const Text(
        'Topar carona',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
      ),
    );
  }
}

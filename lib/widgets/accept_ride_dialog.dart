import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_user.dart';
import 'package:usper/widgets/ride_info.dart';
import 'package:usper/widgets/user_image.dart';

class AcceptRideDialog extends StatelessWidget {
  final User driver;
  final RideData rideData;

  const AcceptRideDialog(
      {super.key, required this.driver, required this.rideData});

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width;
    const double infoFontSize = 15;

    return AlertDialog(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RideInfo(
                  type: "Origem",
                  value: rideData.originName,
                  maxWidth: dialogWidth * 0.5,
                  fontSize: infoFontSize),
              RideInfo(
                  type: "Destino",
                  value: rideData.destName,
                  maxWidth: dialogWidth * 0.5,
                  fontSize: infoFontSize)
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RideInfo(
                  type: "Horario",
                  value: rideData.originName,
                  maxWidth: dialogWidth * 0.5,
                  fontSize: infoFontSize),
              RideInfo(
                  type: "Destino",
                  value: rideData.destName,
                  maxWidth: dialogWidth * 0.5,
                  fontSize: infoFontSize)
            ],
          ),
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

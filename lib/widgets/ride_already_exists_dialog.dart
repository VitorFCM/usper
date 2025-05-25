import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/widgets/ride_info_card.dart';

class RideAlreadyExistsDialog extends StatelessWidget {
  final String title;
  final RideData oldRide;
  final void Function() chooseOldRide;
  final void Function() chooseNewRide;
  final String newRideButtonText;
  final String oldRideButtonText;

  RideAlreadyExistsDialog({
    super.key,
    required this.title,
    required this.oldRide,
    required this.chooseOldRide,
    required this.chooseNewRide,
    this.newRideButtonText = 'Carona nova',
    this.oldRideButtonText = 'Carona antiga',
  });

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return Dialog(
        alignment: Alignment.center,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        backgroundColor: lighterBlue,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 30,
              ),
              RideInfoCard(rideData: oldRide),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: button(newRideButtonText, Colors.black,
                      buttonWidth + 50, () => chooseNewRide(), yellow, 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Align(
                  alignment: Alignment.center,
                  child: button(oldRideButtonText, white, buttonWidth,
                      () => chooseOldRide(), Colors.black, 10),
                ),
              )
            ],
          ),
        ));
  }

  TextButton button(String title, Color textColor, double minWidth,
      VoidCallback onPressedFunction, Color backgroundColor, double radius) {
    return TextButton(
      onPressed: onPressedFunction,
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          backgroundColor: backgroundColor,
          minimumSize: Size(minWidth, 20)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }
}

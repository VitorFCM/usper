import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/widgets/user_image.dart';

class AcceptedPassengerDialog extends StatelessWidget {
  final UsperUser passenger;

  const AcceptedPassengerDialog({super.key, required this.passenger});

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.3;
    const double infoFontSize = 15;

    return AlertDialog(
      shape: const RoundedRectangleBorder(
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
          UserImage(user: passenger, radius: 70),
          Text(passenger.firstName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: white, fontSize: 20)),
          Text(passenger.course,
              textAlign: TextAlign.center,
              style: const TextStyle(color: white, fontSize: 15)),
          const SizedBox(height: 20),
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

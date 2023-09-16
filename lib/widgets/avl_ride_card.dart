import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_user.dart';
import 'package:usper/widgets/user_image.dart';

class AvlRideCard extends StatelessWidget {
  final User user;
  final RideData rideData;

  AvlRideCard({Key? key, required this.user, required this.rideData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double placeMaxWidth = MediaQuery.of(context).size.width * 0.2;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: lighterBlue,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                UserImage(user: user, radius: 25),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    user.firstName,
                    style: const TextStyle(
                        color: white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(
                    rideData.vehicle.licensePlate,
                    style: const TextStyle(
                        color: white,
                        fontSize: 10,
                        fontWeight: FontWeight.w400),
                  ),
                ])
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                rideInfo("Origem", rideData.originName, placeMaxWidth),
                rideInfo("Destino", rideData.destName, placeMaxWidth),
                rideInfo(
                    "Horario",
                    "${rideData.departTime.hour}:${rideData.departTime.minute}",
                    placeMaxWidth),
              ],
            )
          ],
        ));
  }

  Widget rideInfo(String type, String place, double maxWidth) {
    const double fontSize = 10;

    return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(type, style: TextStyle(color: yellow, fontSize: fontSize)),
            Text(place, style: TextStyle(color: white, fontSize: fontSize))
          ],
        ));
  }
}

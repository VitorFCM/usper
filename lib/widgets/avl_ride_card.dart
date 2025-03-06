import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/accept_ride_dialog.dart';
import 'package:usper/widgets/ride_info.dart';
import 'package:usper/widgets/user_image.dart';

class AvlRideCard extends StatelessWidget {
  final RideData rideData;

  const AvlRideCard({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    double infoMaxWidth = MediaQuery.of(context).size.width * 0.2;

    return GestureDetector(
        onTap: () => {
              showDialog(
                  context: context,
                  builder: (context) => AcceptRideDialog(
                      driver: rideData.driver, rideData: rideData))
            },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: lighterBlue,
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    UserImage(user: rideData.driver, radius: 25),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.5),
                              child: Text(
                                rideData.driver.firstName,
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              )),
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
                    RideInfo(
                        type: "Origem",
                        value: rideData.originName,
                        maxWidth: infoMaxWidth),
                    RideInfo(
                        type: "Destino",
                        value: rideData.destName,
                        maxWidth: infoMaxWidth),
                    RideInfo(
                        type: "Horario",
                        value: datetimeToString(rideData.departTime),
                        maxWidth: infoMaxWidth),
                  ],
                )
              ],
            )));
  }
}

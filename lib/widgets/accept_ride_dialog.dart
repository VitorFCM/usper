import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/waiting_room/controller/waiting_room_controller.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/loading_widget.dart';
import 'package:usper/widgets/ride_already_exists_dialog.dart';
import 'package:usper/widgets/ride_info.dart';
import 'package:usper/widgets/user_image.dart';

class AcceptRideDialog extends StatelessWidget {
  final RideData rideData;
  late WaitingRoomController controller;

  AcceptRideDialog({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    controller = BlocProvider.of<WaitingRoomController>(context);

    return BlocConsumer<WaitingRoomController, WaitingRoomState>(
      listener: (context, state) {
        if (state is RideRequestCreatedState) {
          BlocProvider.of<HomeController>(context)
              .add(UserAndRideAssociation(ride: state.ride, isARequest: true));
          Navigator.popAndPushNamed(context, "/waiting_room");
        } else if (state is RideStartedState) {
          Navigator.popAndPushNamed(context, "/ride_dashboard");
        }
      },
      builder: (context, state) {
        if (state is Loading) {
          return waitingDialog();
        } else if (state is PassengerAlreadyHaveARequest) {
          return RideAlreadyExistsDialog(
              title: "Parece que você já possui a seguinte carona em andamento",
              oldRide: state.ride,
              chooseOldRide: () =>
                  controller.add(KeepOldRequest(oldRide: state.ride)),
              chooseNewRide: () => controller.add(DeleteOldRequestAndCreateNew(
                  oldRide: state.ride, newRide: rideData)));
        } else if (state is ErrorMessage) {
          return ErrorAlertDialog(errorMessage: state.message);
        }
        return rideInfo(context);
      },
    );
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

  AlertDialog waitingDialog() {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        backgroundColor: lighterBlue,
        content: LoadingWidget(
          infoSection: ChangingTextWidget(texts: const [
            "Saindo da aula",
            "Estudando pra prova",
            "Topando carona"
          ]),
        ));
  }

  AlertDialog rideInfo(BuildContext context) {
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
          UserImage(user: rideData.driver, radius: 70),
          Text(rideData.driver.firstName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: white, fontSize: 20)),
          Text(rideData.driver.course,
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
      onPressed: () {
        controller.add(CreateRideRequest(ride: rideData));
      },
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

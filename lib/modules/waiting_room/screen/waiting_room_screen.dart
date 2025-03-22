import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/modules/waiting_room/controller/waiting_room_controller.dart';
import 'package:usper/utils/calc_text_size.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/arrow.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/widgets/user_image.dart';

class WaitingRoomScreen extends StatelessWidget {
  WaitingRoomScreen({super.key});

  late double _txtInfoMaxWidth;
  static const double lateralPadding = 15;
  late Map<String, UsperUser> acceptedRideRequests;

  @override
  Widget build(BuildContext context) {
    WaitingRoomController controller =
        BlocProvider.of<WaitingRoomController>(context);

    acceptedRideRequests = controller.acceptedRideRequests;
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    double passSectionHeight = MediaQuery.of(context).size.height * 0.3;
    if (passSectionHeight >= 400) passSectionHeight = 400;

    _txtInfoMaxWidth = MediaQuery.of(context).size.width * 0.3;
    return BaseScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: titleOcupation),
            child: PageTitle(title: "Sala de Espera"),
          ),
          const SizedBox(height: 20),
          rideInfoCard(controller.ride, context),
          const SizedBox(height: 20),
          const Text(
            "Passageiros aprovados",
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: passSectionHeight, minHeight: passSectionHeight),
            child: approvedPassengers(context),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Align(
              alignment: Alignment.center,
              child: button("Cancelar", white, buttonWidth, () {
                controller.add(CancelRideRequest());
                Navigator.pop(context);
              }, Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget rideInfoCard(RideData rideData, BuildContext context) {
    const double edgeInsets = 10;

    double destNameWidth =
        calcTextSize(rideData.destName, const TextStyle(fontSize: 12)).width;

    double arrowEnd = (destNameWidth < _txtInfoMaxWidth)
        ? MediaQuery.of(context).size.width -
            2 * lateralPadding -
            2 * edgeInsets -
            20 -
            calcTextSize(rideData.originName, const TextStyle(fontSize: 12))
                .width -
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
          ],
        ));
  }

  Widget approvedPassengers(BuildContext context) {
    return BlocBuilder<WaitingRoomController, WaitingRoomState>(
      buildWhen: (previous, current) {
        return true;
      },
      builder: (context, state) {
        if (state is AllAcceptedRequests) {
          acceptedRideRequests = state.acceptedRequests;
        } else if (state is NewRequestAcceptedState) {
          acceptedRideRequests[state.passenger.email] = state.passenger;
        } else if (state is RequestCancelledState) {
          acceptedRideRequests.remove(state.passengerEmail);
        }

        print(acceptedRideRequests);

        return ListView.builder(
          shrinkWrap: true,
          itemCount: acceptedRideRequests.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child:
                    passengerCard(acceptedRideRequests.values.toList()[index]));
          },
        );
      },
    );
  }

  TextButton button(String title, Color textColor, double minWidth,
      VoidCallback onPressedFunction, Color backgroundColor) {
    return TextButton(
      onPressed: onPressedFunction,
      style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          backgroundColor: backgroundColor,
          minimumSize: Size(minWidth, 20)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget passengerCard(UsperUser passenger) {
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

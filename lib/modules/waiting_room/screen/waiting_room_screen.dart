import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/waiting_room/controller/waiting_room_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/widgets/ride_info_card.dart';
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
    return BlocListener<WaitingRoomController, WaitingRoomState>(
      listener: (context, state) {
        if (state is ErrorMessage) {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.message));
        } else if (state is RideStartedState) {
          Navigator.popAndPushNamed(context, '/ride_dashboard');
        } else if (state is RideCanceledState) {
          BlocProvider.of<HomeController>(context)
              .add(DisassociateUserAndRide());
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        }
      },
      child: BaseScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleOcupation),
              child: PageTitle(title: "Sala de Espera"),
            ),
            const SizedBox(height: 20),
            RideInfoCard(rideData: controller.ride),
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
              padding: const EdgeInsets.only(top: 50),
              child: Align(
                alignment: Alignment.center,
                child: button("Cancelar", white, buttonWidth,
                    () => controller.add(CancelRideRequest()), Colors.black),
              ),
            )
          ],
        ),
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/modules/chat/controller/chat_controller.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/passengers_selection/controller/passengers_selection_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/loading_widget.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/widgets/user_image.dart';

class PassengersSelScreen extends StatelessWidget {
  PassengersSelScreen({super.key});

  late double _txtInfoMaxWidth;
  static const double lateralPadding = 15;
  Map<String, UsperUser> passengersRequests = {};
  Map<String, UsperUser> passengersAccepted = {};
  late PassengersSelectionController _controller;

  @override
  Widget build(BuildContext context) {
    _txtInfoMaxWidth = MediaQuery.of(context).size.width - 130;
    _controller = BlocProvider.of<PassengersSelectionController>(context);

    return BaseScreen(
        child: BlocConsumer<PassengersSelectionController,
            PassengersSelectionState>(
      listener: (context, state) {
        if (state is RideStartedState) {
          Navigator.popAndPushNamed(context, '/ride_dashboard');
        } else if (state is RideCanceledState) {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        }
      },
      builder: (context, state) {
        if (state is Loading) {
          return LoadingWidget(
            infoSection: ChangingTextWidget(texts: const [
              "Saindo do bandeco",
              "Ligando o veículo",
              "Informando os passageiros",
              "Iniciando carona"
            ]),
          );
        }
        return passengersSelectionScreen(context);
      },
    ));
  }

  Widget passengersSelectionScreen(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    double passSectionHeight = MediaQuery.of(context).size.height * 0.3;
    if (passSectionHeight >= 400) passSectionHeight = 400;

    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: titleOcupation),
          child: PageTitle(title: "Seleção de\npassageiros"),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 140,
          width: MediaQuery.of(context).size.width,
          child: newPassengersList(context),
        ),
        const SizedBox(height: 30),
        const Text(
          "Passageiros aprovados",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: passSectionHeight, minHeight: passSectionHeight),
            child: approvedPassengers(context)),
        //const Spacer(),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Align(
            alignment: Alignment.center,
            child: button("Iniciar carona", Colors.black, buttonWidth + 50, () {
              _controller.add(StartRide());

              RideData ride = _controller.ride;
              BlocProvider.of<RideDashboardController>(context)
                  .add(SetRide(ride: ride, user: ride.driver));
            }, yellow, 10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Align(
            alignment: Alignment.center,
            child: button("Cancelar", white, buttonWidth,
                () => _controller.add(CancelRide()), Colors.black, 10),
          ),
        )
      ],
      //),
    );
  }

  Widget approvedPassengers(BuildContext context) {
    return BlocBuilder<PassengersSelectionController, PassengersSelectionState>(
      buildWhen: (previous, current) {
        return true;
      },
      builder: (context, state) {
        if (state is RequestCancelledState) {
          passengersAccepted.remove(state.passengerEmail);
        } else if (state is RequestAcceptedState) {
          passengersAccepted[state.passenger.email] = state.passenger;
        } else if (state is PassengersRetrievedState) {
          passengersAccepted = state.approved;
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: passengersAccepted.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child:
                    passengerCard(passengersAccepted.values.toList()[index]));
          },
        );
      },
    );
  }

  Widget newPassengersList(BuildContext context) {
    ScrollController controller = ScrollController(
        initialScrollOffset: 1 * MediaQuery.of(context).size.width / 2);

    return BlocBuilder<PassengersSelectionController, PassengersSelectionState>(
      buildWhen: (previous, current) {
        return true;
      },
      builder: (context, state) {
        if (state is RequestCreatedState) {
          passengersRequests[state.passenger.email] = state.passenger;
        } else if (state is RequestCancelledState) {
          passengersRequests.remove(state.passengerEmail);
        } else if (state is RequestRefusedState) {
          passengersRequests.remove(state.passengerEmail);
        } else if (state is RequestAcceptedState) {
          passengersRequests.remove(state.passenger.email);
        } else if (state is PassengersRetrievedState) {
          passengersRequests = state.requests;
        }

        return ListView.builder(
          //shrinkWrap: true,
          itemCount: passengersRequests.length,
          controller: controller,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: passengerSelCard(
                    passengersRequests.values.toList()[index]));
          },
        );
      },
    );
  }

  Widget passengerSelCard(UsperUser passenger) {
    double cardWidth = 250;
    double padding = 10;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: yellow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserImage(user: passenger, radius: 30),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: cardWidth - 2 * padding),
                      child: Text(passenger.firstName,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20))),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Text(passenger.course,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 10)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              button(
                  "Recusar",
                  white,
                  100,
                  () => _controller
                      .add(RequestRefused(passengerEmail: passenger.email)),
                  Colors.black,
                  20),
              button(
                  "Aceitar",
                  Colors.black,
                  100,
                  () => _controller.add(RequestAccepted(passenger: passenger)),
                  Colors.green,
                  20)
            ],
          )
        ],
      ),
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

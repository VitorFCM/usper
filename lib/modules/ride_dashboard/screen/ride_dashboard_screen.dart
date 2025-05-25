import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/expandable_map_widget.dart';
import 'package:usper/widgets/loading_widget.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_info_card.dart';

class RideDashboardScreen extends StatelessWidget {
  late RideDashboardController _rideDashboardController;

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    _rideDashboardController =
        BlocProvider.of<RideDashboardController>(context);

    return BaseScreen(
        child: BlocConsumer<RideDashboardController, RideDashboardState>(
      listener: (context, state) {
        if (state is RideFinishedState) {
          BlocProvider.of<HomeController>(context)
              .add(DisassociateUserAndRide());
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        }
      },
      builder: (context, state) {
        if (state is LoadingState) {
          return LoadingWidget(
            infoSection: ChangingTextWidget(texts: const [
              "Chegando ao destino",
              "Desligando o veículo",
              "Dando tchau",
              "Finalizando carona"
            ]),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleOcupation),
              child: PageTitle(title: "Carona iniciada"),
            ),
            const SizedBox(height: 20),
            RideInfoCard(rideData: _rideDashboardController.ride),
            const SizedBox(height: 20),
            ExpandableMapWidget(
              origin: _rideDashboardController.ride.originCoord,
              destination: _rideDashboardController.ride.destCoord,
              routePoints: _rideDashboardController.ride.route ?? [],
            ),
            buttonSection(context),
          ],
        );
      },
    ));
  }

  Widget buttonSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.center,
        child: _rideDashboardController.isDriver
            ? button(
                "Finalizar",
                white,
                MediaQuery.of(context).size.width * 0.8,
                () => _rideDashboardController.add(FinishRide()),
                Colors.black)
            : button(
                "Desistir",
                white,
                MediaQuery.of(context).size.width * 0.8,
                () => _rideDashboardController.add(PassengerGiveUp()),
                Colors.black),
      ),
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
          minimumSize: Size(minWidth, 30)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }
}

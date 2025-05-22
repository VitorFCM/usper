import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/expandable_map_widget.dart';
import 'package:usper/widgets/loading_widget.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_info_card.dart';

class RideDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    RideDashboardController controller =
        BlocProvider.of<RideDashboardController>(context);

    return BaseScreen(
        child: BlocConsumer<RideDashboardController, RideDashboardState>(
      listener: (context, state) {
        if (state is RideFinishedState) {
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
            RideInfoCard(rideData: controller.ride),
            const SizedBox(height: 20),
            ExpandableMapWidget(
              origin: controller.ride.originCoord,
              destination: controller.ride.destCoord,
              routePoints: controller.ride.route ?? [],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Align(
                alignment: Alignment.center,
                child: button(
                    "Finalizar",
                    white,
                    MediaQuery.of(context).size.width * 0.8,
                    () => controller.add(FinishRide()),
                    Colors.black),
              ),
            ),
          ],
        );
      },
    ));

    ;
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

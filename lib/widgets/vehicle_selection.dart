import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/ride_creation/controller/ride_creation_controller.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/vehicle_input_alert_dialog.dart';

class VehicleSelection extends StatelessWidget {
  VehicleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideCreationController, RideCreationState>(
      listener: (context, state) {
        if (state is RideCreationStateError) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.errorMessage));
        }
      },
      child: AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          backgroundColor: blue,
          content: Stack(
            alignment: Alignment.topCenter,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (context) => VehicleInputAlertDialog());
                },
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: yellow,
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Adicionar novo veiculo",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: blue,
                ),
                padding: const EdgeInsets.all(12),
                height: 160,
                width: MediaQuery.of(context).size.width,
                child: vehiclesList(context),
              )
            ],
          )),
    );
  }

  Widget vehiclesList(BuildContext context) {
    RideCreationController rideCreationController =
        BlocProvider.of<RideCreationController>(context);

    UsperUser? driver = BlocProvider.of<LoginController>(context).user;

    rideCreationController.add(RetrieveVehiclesList(driver!.email));

    ScrollController controller = ScrollController(
        initialScrollOffset: 1 * MediaQuery.of(context).size.width / 2);

    return BlocBuilder<RideCreationController, RideCreationState>(
        buildWhen: (previous, current) {
      return current is VehiclesListRetrieved;
    }, builder: (context, state) {
      List<Widget> vehiclesCardsList = state is VehiclesListRetrieved
          ? state.vehiclesList
              .map((vehicle) =>
                  vehicleCard(vehicle, rideCreationController, context))
              .toList()
          : [Text("Sem veiculos registrados")];

      int vehiclesCardsListLen = vehiclesCardsList.length;

      for (int i = 1; i <= vehiclesCardsListLen + 1; i += 2) {
        vehiclesCardsList.insert(i, Container(width: 10));
      }

      return ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: vehiclesCardsList,
      );
    });
  }

  Widget vehicleCard(Vehicle vehicle,
      RideCreationController rideCreationController, BuildContext context) {
    return GestureDetector(
        onTap: () {
          rideCreationController.add(VehicleChosed(vehicle));
          Navigator.pop(context);
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: yellow,
          ),
          padding: EdgeInsets.all(10),
          child: Text(vehicle.licensePlate),
        ));
  }
}

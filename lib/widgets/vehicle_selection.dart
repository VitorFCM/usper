import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/ride_creation/vehicle_configuration_controller/vehicle_configuration_controller.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/vehicle_input_alert_dialog.dart';

class VehicleSelection extends StatelessWidget {
  VehicleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleConfigurationController,
        VehicleConfigurationState>(
      listener: (context, state) {
        if (state is VehicleConfigurationStateError) {
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
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                height: 160,
                width: MediaQuery.of(context).size.width,
                child: vehiclesList(context),
              )
            ],
          )),
    );
  }

  Widget vehiclesList(BuildContext context) {
    VehicleConfigurationController vehicleConfigurationController =
        BlocProvider.of<VehicleConfigurationController>(context);

    UsperUser? driver = BlocProvider.of<LoginController>(context).user;

    vehicleConfigurationController.add(RetrieveVehiclesList(driver!.email));

    ScrollController controller = ScrollController(
        initialScrollOffset: 1 * MediaQuery.of(context).size.width / 2);

    return BlocBuilder<VehicleConfigurationController,
        VehicleConfigurationState>(buildWhen: (previous, current) {
      return current is VehiclesListRetrieved;
    }, builder: (context, state) {
      List<Widget> vehiclesCardsList = state is VehiclesListRetrieved
          ? state.vehiclesList
              .map((vehicle) => Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: vehicleCard(
                        vehicle, vehicleConfigurationController, context),
                  ))
              .toList()
          : [Text("Sem veiculos registrados")];

      return ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: vehiclesCardsList,
      );
    });
  }

  Widget vehicleCard(
      Vehicle vehicle,
      VehicleConfigurationController vehicleConfigurationController,
      BuildContext context) {
    return GestureDetector(
        onTap: () {
          vehicleConfigurationController.add(VehicleChosed(vehicle));
          Navigator.pop(context);
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: yellow,
          ),
          padding: const EdgeInsets.all(10),
          child: Text(vehicle.licensePlate),
        ));
  }
}

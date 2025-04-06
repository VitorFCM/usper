import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pinput/pinput.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/ride_creation/vehicle_configuration_controller/vehicle_configuration_controller.dart';
import 'package:usper/utils/get_nearest_color_name.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/info_input_card.dart';
import 'package:usper/widgets/text_dropdown_menu.dart';

class VehicleInputAlertDialog extends StatelessWidget {
  VehicleInputAlertDialog({super.key});

  Color vehicleColor = white;
  String colorName = "";

  @override
  Widget build(BuildContext context) {
    VehicleConfigurationController vehicleConfigurationController =
        BlocProvider.of<VehicleConfigurationController>(context);

    TextEditingController plateController = TextEditingController();

    return BlocListener<VehicleConfigurationController,
        VehicleConfigurationState>(
      listener: (context, state) {
        if (state is VehicleConfigurationStateError) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.errorMessage));
        } else if (state is VehicleDefined) {
          Navigator.pop(context);
        }
      },
      child: Dialog(
          insetPadding: const EdgeInsets.only(right: 16.0, left: 16.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          backgroundColor: blue,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoInputCard(
                    title: "Placa",
                    color: white,
                    inputWidget: Pinput(
                      controller: plateController,
                      length: 7,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    textColor: Colors.black,
                    minWidth: 350),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    colorSelectorSection(context),
                    const SizedBox(width: 10),
                    seatsCounterSection(vehicleConfigurationController),
                  ],
                ),
                const SizedBox(height: 20),
                vehicleModelSection(vehicleConfigurationController),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: vehicleTypeSection(vehicleConfigurationController),
                ),
                const SizedBox(height: 50),
                button("Tudo certo!", Colors.black, 180, () {
                  UsperUser? driver =
                      BlocProvider.of<LoginController>(context).user;
                  vehicleConfigurationController
                      .add(VehicleDataReady(plateController.text, driver));
                }, yellow)
              ],
            ),
          )),
    );
  }

  Widget colorSelectorSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pickColor(context);
      },
      child: BlocBuilder<VehicleConfigurationController,
          VehicleConfigurationState>(buildWhen: (previous, current) {
        return current is VehicleColorSetted;
      }, builder: (context, state) {
        Color invertedColor = getInvertedColor(vehicleColor);
        return InfoInputCard(
            title: "Cor",
            color: invertedColor,
            inputWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    colorName,
                    style: TextStyle(
                        color: vehicleColor, fontWeight: FontWeight.w400),
                  ),
                  Icon(
                    Icons.directions_car,
                    color: vehicleColor,
                    size: 40,
                  )
                ]),
            textColor: vehicleColor,
            minWidth: 160,
            width: 120);
      }),
    );
  }

  Widget seatsCounterSection(
      VehicleConfigurationController vehicleConfigurationController) {
    int seatsCounter = 0;

    return InfoInputCard(
        title: "Vagas",
        color: white,
        inputWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  vehicleConfigurationController
                      .add(const SeatsCounterDecreased());
                },
                icon: const Icon(
                  Icons.remove_rounded,
                  color: Colors.black,
                )),
            BlocBuilder<VehicleConfigurationController,
                VehicleConfigurationState>(builder: (context, state) {
              if (state is SeatsCounterNewValue) {
                seatsCounter = state.seats;
              }
              return Text(
                "$seatsCounter",
                style: const TextStyle(color: Colors.black),
              );
            }),
            IconButton(
                onPressed: () {
                  vehicleConfigurationController
                      .add(const SeatsCounterIncreased());
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.black,
                )),
          ],
        ),
        textColor: Colors.black,
        minWidth: 160,
        width: 120);
  }

  Widget vehicleTypeSection(
      VehicleConfigurationController vehicleConfigurationController) {
    vehicleConfigurationController.add(VehicleTypeSwitched(true));

    return InfoInputCard(
        title: "Tipo de Veiculo",
        color: yellow,
        inputWidget: BlocBuilder<VehicleConfigurationController,
            VehicleConfigurationState>(buildWhen: (previous, current) {
          return current is VehicleMakersRetrieved;
        }, builder: (context, state) {
          bool isCar = state is VehicleMakersRetrieved && state.isCar;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              isCar
                  ? const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Colors.black,
                    )
                  : const Icon(
                      Icons.motorcycle,
                      size: 40,
                      color: Colors.black,
                    ),
              const SizedBox(width: 10),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: !isCar,
                  inactiveTrackColor: Colors.black,
                  inactiveThumbColor: yellow,
                  activeColor: yellow,
                  activeTrackColor: Colors.black,
                  trackOutlineColor: MaterialStateProperty.resolveWith(
                    (final Set<MaterialState> states) {
                      return Colors.transparent;
                    },
                  ),
                  onChanged: (bool value) {
                    isCar = !isCar;
                    vehicleConfigurationController
                        .add(VehicleTypeSwitched(isCar));
                  },
                ),
              ),
            ],
          );
        }),
        textColor: Colors.black,
        minWidth: 160,
        width: 120);
  }

  Widget vehicleModelSection(
      VehicleConfigurationController vehicleConfigurationController) {
    return InfoInputCard(
        title: "Modelo do Veiculo",
        color: Colors.black,
        inputWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder<VehicleConfigurationController,
                VehicleConfigurationState>(buildWhen: (previous, current) {
              return current is VehicleMakersRetrieved;
            }, builder: (context, state) {
              List<String> dropdownValues = state is VehicleMakersRetrieved
                  ? state.vehicleMakers
                  : ["Sem marcas"];
              return TextDropdownMenu.fromList(
                  values: dropdownValues,
                  label: "Marca",
                  onSelectedCallback: (String value) =>
                      vehicleConfigurationController
                          .add(VehicleMakerSelected(value)));
            }),
            BlocBuilder<VehicleConfigurationController,
                VehicleConfigurationState>(buildWhen: (previous, current) {
              return current is VehicleModelsRetrieved;
            }, builder: (context, state) {
              List<String> dropdownValues = state is VehicleModelsRetrieved
                  ? state.vehicleModels
                  : ["Sem modelos"];
              return TextDropdownMenu.fromList(
                  values: dropdownValues,
                  label: "Modelo",
                  onSelectedCallback: (String value) =>
                      vehicleConfigurationController
                          .add(VehicleModelSelected(value)));
            })
          ],
        ),
        textColor: white,
        minWidth: 160);
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

  Color getInvertedColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  void pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: yellow,
          title: const Text("Escolha uma cor",
              style: TextStyle(fontWeight: FontWeight.w400)),
          content: SingleChildScrollView(
              child: Column(
            children: [
              ColorPicker(
                pickerColor: vehicleColor,
                onColorChanged: (Color color) {
                  vehicleColor = color;
                  colorName = getNearestColorName(vehicleColor);
                  BlocProvider.of<VehicleConfigurationController>(context)
                      .add(SetVehicleColor(vehicleColor, colorName));
                },
                showLabel: false,
                enableAlpha: false,
                pickerAreaHeightPercent: 0.8,
              ),
              BlocBuilder<VehicleConfigurationController,
                  VehicleConfigurationState>(buildWhen: (previous, current) {
                return current is VehicleColorSetted;
              }, builder: (context, state) {
                String colorName = "";

                if (state is VehicleColorSetted) {
                  colorName = state.colorName;
                }
                return Text(colorName,
                    style: const TextStyle(fontWeight: FontWeight.w400));
              })
            ],
          )),
          actions: [
            TextButton(
              child: const Text('Selecionar',
                  style: TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

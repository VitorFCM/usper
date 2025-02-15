import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pinput/pinput.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/ride_creation/controller/ride_creation_controller.dart';
import 'package:usper/utils/get_nearest_color_name.dart';
import 'package:usper/widgets/error_alert_dialog.dart';

class VehicleInputAlertDialog extends StatelessWidget {
  VehicleInputAlertDialog({super.key});

  Color vehicleColor = white;
  String colorName = "";

  @override
  Widget build(BuildContext context) {
    RideCreationController rideCreationController =
        BlocProvider.of<RideCreationController>(context);

    TextEditingController plateController = TextEditingController();

    return BlocListener<RideCreationController, RideCreationState>(
      listener: (context, state) {
        if (state is RideCreationStateError) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.errorMessage));
        } else if (state is RideVehicleDefined) {
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
                infoInput(
                    "Placa",
                    white,
                    Pinput(
                      controller: plateController,
                      length: 7,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    Colors.black,
                    350),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    colorSelectorSection(context),
                    const SizedBox(width: 10),
                    seatsCounterSection(rideCreationController),
                  ],
                ),
                const SizedBox(height: 20),
                vehicleModelSection(rideCreationController),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: vehicleTypeSection(rideCreationController),
                ),
                const SizedBox(height: 50),
                button("Tudo certo!", Colors.black, 180, () {
                  UsperUser? driver =
                      BlocProvider.of<LoginController>(context).user;
                  rideCreationController
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
      child: BlocBuilder<RideCreationController, RideCreationState>(
          buildWhen: (previous, current) {
        return current is VehicleColorSetted;
      }, builder: (context, state) {
        Color invertedColor = getInvertedColor(vehicleColor);
        return infoInput(
            "Cor",
            invertedColor,
            Row(
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
            vehicleColor,
            160);
      }),
    );
  }

  Widget seatsCounterSection(RideCreationController rideCreationController) {
    int seatsCounter = 0;

    return infoInput(
        "Vagas",
        white,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  rideCreationController.add(const SeatsCounterDecreased());
                },
                icon: const Icon(
                  Icons.remove_rounded,
                  color: Colors.black,
                )),
            BlocBuilder<RideCreationController, RideCreationState>(
                builder: (context, state) {
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
                  rideCreationController.add(const SeatsCounterIncreased());
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.black,
                )),
          ],
        ),
        Colors.black,
        160);
  }

  Widget vehicleTypeSection(RideCreationController rideCreationController) {
    rideCreationController.add(VehicleTypeSwitched(true));

    return infoInput(
        "Tipo de Veiculo",
        yellow,
        BlocBuilder<RideCreationController, RideCreationState>(
            buildWhen: (previous, current) {
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
                    rideCreationController.add(VehicleTypeSwitched(isCar));
                  },
                ),
              ),
            ],
          );
        }),
        Colors.black,
        160,
        width: 120);
  }

  Widget vehicleModelSection(RideCreationController rideCreationController) {
    return infoInput(
        "Modelo do Veiculo",
        Colors.black,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BlocBuilder<RideCreationController, RideCreationState>(
                buildWhen: (previous, current) {
              return current is VehicleMakersRetrieved;
            }, builder: (context, state) {
              List<String> dropdownValues = state is VehicleMakersRetrieved
                  ? state.vehicleMakers
                  : ["Sem marcas"];
              return dropdownMenu(
                  dropdownValues,
                  "Marca",
                  (String value) =>
                      rideCreationController.add(VehicleMakerSelected(value)));
            }),
            BlocBuilder<RideCreationController, RideCreationState>(
                buildWhen: (previous, current) {
              return current is VehicleModelsRetrieved;
            }, builder: (context, state) {
              List<String> dropdownValues = state is VehicleModelsRetrieved
                  ? state.vehicleModels
                  : ["Sem modelos"];
              return dropdownMenu(
                  dropdownValues,
                  "Modelo",
                  (String value) =>
                      rideCreationController.add(VehicleModelSelected(value)));
            })
          ],
        ),
        white,
        160);
  }

  Widget dropdownMenu(List<String> dropdownValues, String label,
      Function(String) onSelectedCallback) {
    return DropdownMenu<String>(
      initialSelection: dropdownValues.first,
      label: Text(label),
      width: 140,
      onSelected: (String? value) {
        if (value != null) {
          onSelectedCallback(value);
        }
      },
      textStyle: const TextStyle(color: white),
      dropdownMenuEntries: dropdownValues
          .map<DropdownMenuEntry<String>>(
            (String name) => DropdownMenuEntry<String>(
              value: name,
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(white)),
              label: name,
            ),
          )
          .toList(),
      menuHeight: 250,
      menuStyle: const MenuStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.black)),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: white),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: BoxConstraints.tight(const Size.fromHeight(40)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
                  BlocProvider.of<RideCreationController>(context)
                      .add(SetVehicleColor(vehicleColor, colorName));
                },
                showLabel: false,
                enableAlpha: false,
                pickerAreaHeightPercent: 0.8,
              ),
              BlocBuilder<RideCreationController, RideCreationState>(
                  buildWhen: (previous, current) {
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

  Widget infoInput(String title, Color color, Widget inputWidget,
      Color textColor, double minWidth,
      {double? width}) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      width: width,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            alignment: Alignment.center,
            child: inputWidget,
          )
        ],
      ),
    );
  }
}

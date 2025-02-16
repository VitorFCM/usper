import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/expandable_map_widget.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/set_location_alert_dialog.dart';
import 'package:usper/widgets/vehicle_selection.dart';

class RideCreationScreen extends StatelessWidget {
  RideCreationScreen({super.key});

  DateTime selectedTime = DateTime.now().add(const Duration(minutes: 10));

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    RideCreationController rideCreationController =
        BlocProvider.of<RideCreationController>(context);

    return BlocListener<RideCreationController, RideCreationState>(
      listener: (context, state) {
        if (state is RideCreationStateError) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorAlertDialog(errorMessage: state.errorMessage));
        } else if (state is RideCreated) {
          Navigator.popAndPushNamed(context, "/passengers_selection");
        }
      },
      child: BaseScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleOcupation),
              child: PageTitle(title: "Criação de\ncarona"),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: lighterBlue,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    textFormField<SetOriginData, OriginLocationSetted>(
                        "Origem", rideCreationController, context),
                    const SizedBox(height: 10),
                    textFormField<SetDestinationData, DestLocationSetted>(
                        "Destino", rideCreationController, context),
                    const SizedBox(height: 20),
                    ExpandableMapWidget(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            //flex: 2,
                            child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? time =
                                await _showTimePicker(context);
                            if (time != null) {
                              selectedTime = DateTime(
                                  selectedTime.year,
                                  selectedTime.month,
                                  selectedTime.day,
                                  time.hour,
                                  time.minute);
                              rideCreationController
                                  .add(SetDepartureTime(selectedTime));
                            }
                          },
                          child: infoInput(
                              "Horario de Partida",
                              yellow,
                              BlocBuilder<RideCreationController,
                                  RideCreationState>(
                                buildWhen: (previous, current) {
                                  return current is DepartureTimeSetted;
                                },
                                builder: (context, state) {
                                  if (state is DepartureTimeSetted) {
                                    return Text(
                                        datetimeToString(state.departTime));
                                  } else {
                                    return Text(datetimeToString(selectedTime));
                                  }
                                },
                              ),
                              Colors.black,
                              550),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => VehicleSelection());
                              },
                              child: infoInput(
                                  "Veículo",
                                  Colors.black,
                                  BlocBuilder<RideCreationController,
                                          RideCreationState>(
                                      buildWhen: (previous, current) {
                                    return current is RideVehicleDefined;
                                  }, builder: (context, state) {
                                    if (state is RideVehicleDefined) {
                                      return Text(
                                        state.vehicle.licensePlate,
                                        style: const TextStyle(color: white),
                                      );
                                    }
                                    return const Icon(
                                      Icons.airport_shuttle,
                                      color: white,
                                      size: 40,
                                    );
                                  }),
                                  white,
                                  150),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //const SizedBox(height: 50),
            //const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 20),
              child: Align(
                alignment: Alignment.center,
                child: button(
                    "Criar carona",
                    Colors.black,
                    MediaQuery.of(context).size.width * 0.8,
                    () => rideCreationController.add(RideCreationFinished(
                        BlocProvider.of<LoginController>(context).user)),
                    yellow),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: button(
                    "Cancelar",
                    white,
                    MediaQuery.of(context).size.width * 0.5,
                    () => {
                          rideCreationController.add(RideCanceled()),
                          Navigator.pop(context)
                        },
                    Colors.black),
              ),
            ),
          ],
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

  Widget infoInput(String title, Color color, Widget inputWidget,
      Color textColor, double minWidth) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(color: textColor, fontSize: 10),
            ),
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

  Widget textFormField<T extends SetLocationData, U extends LocationSetted>(
      String hintText,
      RideCreationController controller,
      BuildContext context) {
    LatLong? initPosition;

    return GestureDetector(
        onTap: () async {
          if (U == OriginLocationSetted) {
            initPosition = controller.originData != null
                ? controller.originData!.latLong
                : null;
          } else if (U == DestLocationSetted) {
            initPosition = controller.destData != null
                ? controller.destData!.latLong
                : null;
          }
          showDialog(
              context: context,
              builder: (context) => SetLocationAlertDialog(
                  onPickedFunction: (pickedData) {
                    T event = T == SetOriginData
                        ? SetOriginData(pickedData) as T
                        : SetDestinationData(pickedData) as T;
                    event.locationData = pickedData;
                    controller.add(event);
                    Navigator.of(context).pop();
                  },
                  initPosition: initPosition));
        },
        child: Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<RideCreationController, RideCreationState>(
            buildWhen: (previous, current) {
              return current is U;
            },
            builder: (context, state) {
              if (state is U) {
                return Text(state.address);
              } else {
                return Text(hintText);
              }
            },
          ),
        ));
  }

  Future<TimeOfDay?> _showTimePicker(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}

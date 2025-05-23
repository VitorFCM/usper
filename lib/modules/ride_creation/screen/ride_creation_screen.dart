import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/passengers_selection/controller/passengers_selection_controller.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';
import 'package:usper/utils/datetime_to_string.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/expandable_map_widget.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/info_input_card.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_already_exists_dialog.dart';
import 'package:usper/widgets/set_location_alert_dialog.dart';
import 'package:usper/widgets/vehicle_selection.dart';

class RideCreationScreen extends StatelessWidget {
  RideCreationScreen({super.key});

  DateTime selectedTime = DateTime.now().add(const Duration(minutes: 10));
  late RideCreationController _rideCreationController;

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;
    _rideCreationController = BlocProvider.of<RideCreationController>(context);

    return BlocListener<RideCreationController, RideCreationState>(
      listener: (context, state) {
        if (state is RideCreationStateError) {
          showDialog(
              context: context,
              builder: (context) {
                return ErrorAlertDialog(
                  errorMessage: state.errorMessage,
                );
              });
        } else if (state is RideCreated) {
          if (state.ride.started ?? false) {
            Navigator.pushNamed(context, "/ride_dashboard");
          } else {
            BlocProvider.of<PassengersSelectionController>(context)
                .add(SetRideData(ride: state.ride));
            Navigator.popAndPushNamed(context, "/passengers_selection");
          }
        } else if (state is DriverAlreadyHaveARide) {
          showDialog(
              context: context,
              builder: (context) {
                return RideAlreadyExistsDialog(
                    title:
                        "Só é possível ter uma carona por vez, e você já possiu uma ativa.",
                    oldRide: state.oldRide,
                    chooseOldRide: () => _rideCreationController
                        .add(KeepOldRide(oldRide: state.oldRide)),
                    chooseNewRide: () => _rideCreationController.add(
                        DeleteOldRideAndCreateNew(oldRide: state.oldRide)));
              });
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
                    textFormField<SetOriginData, OriginLocationSetState>(
                        "Origem", _rideCreationController, context),
                    const SizedBox(height: 10),
                    textFormField<SetDestinationData, DestLocationSetState>(
                        "Destino", _rideCreationController, context),
                    const SizedBox(height: 20),
                    mapBuilder(context),
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
                              _rideCreationController
                                  .add(SetDepartureTime(selectedTime));
                            }
                          },
                          child: InfoInputCard(
                              title: "Horario de Partida",
                              color: yellow,
                              inputWidget: BlocBuilder<RideCreationController,
                                  RideCreationState>(
                                buildWhen: (previous, current) {
                                  return current is DepartureTimeSetState;
                                },
                                builder: (context, state) {
                                  if (state is DepartureTimeSetState) {
                                    return Text(
                                        datetimeToString(state.departTime));
                                  } else {
                                    return Text(datetimeToString(selectedTime));
                                  }
                                },
                              ),
                              textColor: Colors.black,
                              minWidth: 550),
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
                              child: InfoInputCard(
                                  title: "Veículo",
                                  color: Colors.black,
                                  inputWidget: BlocBuilder<
                                          RideCreationController,
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
                                  textColor: white,
                                  minWidth: 150),
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
                    () => _rideCreationController.add(RideCreationFinished(
                        BlocProvider.of<LoginController>(context).user)),
                    yellow),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: button(
                    "Cancelar", white, MediaQuery.of(context).size.width * 0.5,
                    () {
                  _rideCreationController.add(RideCanceled());
                  Navigator.pop(context);
                }, Colors.black),
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

  Widget textFormField<T extends SetLocationData, U extends LocationSetState>(
      String hintText,
      RideCreationController controller,
      BuildContext context) {
    LatLong? initPosition;

    return GestureDetector(
        onTap: () async {
          if (U == OriginLocationSetState) {
            initPosition = controller.originData?.latLong;
          } else if (U == DestLocationSetState) {
            initPosition = controller.destData?.latLong;
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

  BlocBuilder mapBuilder(BuildContext context) {
    LatLng? origin;
    LatLng? destination;
    List<LatLng> routePoints = [];

    return BlocBuilder<RideCreationController, RideCreationState>(
      buildWhen: (previous, current) {
        return current is LocationSetState;
      },
      builder: (context, state) {
        if (state is OriginLocationSetState) {
          origin = state.location;
          routePoints = state.route ?? [];
        } else if (state is DestLocationSetState) {
          destination = state.location;
          routePoints = state.route ?? [];
        }

        return ExpandableMapWidget(
          origin: origin,
          destination: destination,
          routePoints: routePoints,
        );
      },
    );
  }
}

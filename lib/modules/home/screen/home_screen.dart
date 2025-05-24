import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/passengers_selection/controller/passengers_selection_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/widgets/avl_ride_card.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_already_exists_dialog.dart';
import 'package:usper/widgets/set_location_alert_dialog.dart';
import 'package:usper/widgets/user_image.dart';
import 'package:usper/widgets/usp_course_selector.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  Map<String, RideData> rides = {};
  late UsperUser user;
  bool _dialogOpened = false;
  late HomeController _homeController;

  @override
  Widget build(BuildContext context) {
    context.select((LoginController controller) {
      user = controller.user!;
      if (controller.isNewUser! && !_dialogOpened) {
        _dialogOpened = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            controller.uspCarrersCodes?.then((uspCourses) {
              if (!Navigator.of(context).canPop()) {
                showDialog(
                  context: context,
                  builder: (context) =>
                      UspCourseSelector(uspCarrers: uspCourses),
                );
              }
            });
          }
        });
      }
    });

    const double imgRadius = 35;
    const double lateralPadding = 15;
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;

    double screenOcupation = 2 * (imgRadius + lateralPadding) + titleOcupation;

    if (screenOcupation >= MediaQuery.of(context).size.width) {
      titleOcupation -= screenOcupation - MediaQuery.of(context).size.width;
    }

    _homeController = BlocProvider.of<HomeController>(context);

    return BlocListener<HomeController, HomeScreenState>(
        listener: (context, state) {
          if (state is FollowToRideCreation) {
            Navigator.pushNamed(context, "/ride_creation");
          } else if (state is UserAlreadyCreatedARide) {
            showDialog(
                context: context,
                builder: (context) => RideAlreadyExistsDialog(
                    title:
                        "Parece que você já possui a seguinte carona em andamento",
                    oldRide: state.ride,
                    chooseOldRide: () =>
                        _homeController.add(KeepOldRide(oldRide: state.ride)),
                    chooseNewRide: () => _homeController.add(
                        DeleteOldRideAndCreateNew(
                            oldRideId: state.ride.driver.email))));
          } else if (state is HomeStateError) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorAlertDialog(errorMessage: state.errorMessage));
          } else if (state is KeepOldRideState) {
            if (state.oldRide.started ?? false) {
              BlocProvider.of<RideDashboardController>(context).add(
                  SetRide(ride: state.oldRide, user: state.oldRide.driver));
              Navigator.pushNamed(context, "/ride_dashboard");
            } else {
              BlocProvider.of<PassengersSelectionController>(context)
                  .add(SetRideData(ride: state.oldRide));
              Navigator.pushNamed(context, "/passengers_selection");
            }
          }
        },
        child: BaseScreen(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: titleOcupation),
                  child:
                      PageTitle(title: "Para onde\nvamos, ${user.firstName}?"),
                ),
                UserImage(user: user, radius: imgRadius)
              ],
            ),
            const SizedBox(height: 20),
            textFormField(context),
            const SizedBox(height: 50),
            rideCreationButton(context),
            const SizedBox(height: 50),
            const Text(
              "Caronas disponíveis",
              style: TextStyle(
                  color: white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            availableRides(context)
          ],
        )));
  }

  Widget textFormField(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          showDialog(
              context: context,
              builder: (context) => SetLocationAlertDialog(
                  onPickedFunction: (pickedData) {
                    _homeController.add(SetDestination(pickedData: pickedData));
                    Navigator.of(context).pop();
                  },
                  initPosition: _homeController.destinationData?.latLong));
        },
        child: Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: BlocBuilder<HomeController, HomeScreenState>(
            buildWhen: (previous, current) {
              return current is DestinationSetState;
            },
            builder: (context, state) {
              if (state is DestinationSetState) {
                return Text(state.address);
              } else {
                return Text('Digite um local');
              }
            },
          ),
        ));
  }

  TextButton rideCreationButton(BuildContext context) {
    return TextButton(
      onPressed: () => BlocProvider.of<HomeController>(context)
          .add(CreateRide(rideId: user.email)),
      style: TextButton.styleFrom(
          backgroundColor: yellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50)),
      child: const Text(
        'Oferecer carona',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget availableRides(BuildContext context) {
    return BlocBuilder<HomeController, HomeScreenState>(
      buildWhen: (previous, current) {
        return current is InitialRidesLoaded ||
            current is InsertRideRecordState ||
            current is RemoveRideRecordState ||
            current is DestinationSetState;
      },
      builder: (context, state) {
        if (state is InitialRidesLoaded) {
          rides = state.rides;
        } else if (state is InsertRideRecordState) {
          rides[state.rideData.driver.email] = state.rideData;
        } else if (state is RemoveRideRecordState) {
          rides.remove(state.rideId);
        } else if (state is DestinationSetState) {
          rides = state.ordenatedRides;
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AvlRideCard(rideData: rides.values.toList()[index]),
            );
          },
        );
      },
    );
  }
}

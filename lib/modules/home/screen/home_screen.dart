import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/passengers_selection/controller/passengers_selection_controller.dart';
import 'package:usper/widgets/avl_ride_card.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/error_alert_dialog.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_already_exists_dialog.dart';
import 'package:usper/widgets/user_image.dart';
import 'package:usper/widgets/usp_course_selector.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  Map<String, RideData> rides = {};
  late UsperUser u;
  bool _dialogOpened = false;

  @override
  Widget build(BuildContext context) {
    context.select((LoginController controller) {
      u = controller.user!;
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

    HomeController controller = BlocProvider.of<HomeController>(context);

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
                        controller.add(KeepOldRide(oldRide: state.ride)),
                    chooseNewRide: () => controller.add(
                        DeleteOldRideAndCreateNew(
                            oldRideId: state.ride.driver.email))));
          } else if (state is HomeStateError) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorAlertDialog(errorMessage: state.errorMessage));
          } else if (state is KeepOldRideState) {
            if (state.oldRide.started ?? false) {
              print("To do");
              //Navigator.pushNamed(context, "/ride_dashboard");
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
                  child: PageTitle(title: "Para onde\nvamos, ${u.firstName}?"),
                ),
                UserImage(user: u, radius: imgRadius)
              ],
            ),
            const SizedBox(height: 20),
            textFormField(),
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

  TextFormField textFormField() {
    return TextFormField(
      textAlignVertical: const TextAlignVertical(y: 0.0),
      cursorColor: black,
      decoration: InputDecoration(
        hintText: 'Digite um local',
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        border: OutlineInputBorder(
          borderSide: const BorderSide(style: BorderStyle.none, width: 0.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  TextButton rideCreationButton(BuildContext context) {
    return TextButton(
      onPressed: () => BlocProvider.of<HomeController>(context)
          .add(CreateRide(rideId: u.email)),
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
            current is RemoveRideRecordState;
      },
      builder: (context, state) {
        if (state is InitialRidesLoaded) {
          rides = state.rides;
        } else if (state is InsertRideRecordState) {
          rides[state.rideData.driver.email] = state.rideData;
        } else if (state is RemoveRideRecordState) {
          rides.remove(state.rideId);
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

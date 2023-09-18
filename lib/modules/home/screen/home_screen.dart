import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/widgets/accept_ride_dialog.dart';
import 'package:usper/widgets/avl_ride_card.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/user_image.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final User u = User(
      "Vitorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr",
      "Favrin Carrera Miguel",
      "Engenharia de Computacao",
      "https://www.readersdigest.ca/wp-content/uploads/2019/11/cat-10-e1573844975155.jpg");

  final RideData r = RideData(
      originName: "Engcomp",
      destName: "IFSC",
      originCoord: LatLng(0.0, 0.0),
      destCoord: LatLng(0.0, 0.0),
      departTime: DateTime.now(),
      vehicle: Vehicle(4, "Corsa", "ABC-7777", "red"));

  @override
  Widget build(BuildContext context) {
    const double imgRadius = 35;
    const double lateralPadding = 15;
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;

    double screenOcupation = 2 * (imgRadius + lateralPadding) + titleOcupation;

    if (screenOcupation >= MediaQuery.of(context).size.width) {
      titleOcupation -= screenOcupation - MediaQuery.of(context).size.width;
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: blue,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(
              top: 30, left: lateralPadding, right: lateralPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: titleOcupation),
                    child:
                        PageTitle(title: "Para onde\nvamos, ${u.firstName} ?"),
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
              avaibleRides(context)
            ],
          ),
        )),
      ),
    );
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
      onPressed: () {},
      style: TextButton.styleFrom(
          backgroundColor: yellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50)),
      child: const Text(
        'Oferecer carona',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget avaibleRides(BuildContext context) {
    //Future implementation of BlocBuilder
    return GestureDetector(
        onTap: () => {
              showDialog(
                  context: context,
                  builder: (context) =>
                      AcceptRideDialog(driver: u, rideData: r))
            },
        child: AvlRideCard(driver: u, rideData: r));
  }
}

import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_user.dart';

class UserImage extends StatelessWidget {
  final User user;
  final double radius;
  const UserImage({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    String link = user.imageLink;
    /*if (link == null) {
      return CircleAvatar(
        child: Text(
          user.getFirstName()[0].toUpperCase(),
          style: TextStyle(
            fontSize: radius,
            color: white,
          ),
        ),
        backgroundColor: eerieBlack,
        radius: radius,
      );
    }*/

    return CircleAvatar(
      backgroundImage: NetworkImage(
        link,
      ),
      backgroundColor: black,
      radius: radius,
    );
  }
}

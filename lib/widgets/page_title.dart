import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class PageTitle extends StatelessWidget {
  final String title;
  final double size;

  PageTitle({Key? key, required this.title, this.size = 27}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          TextStyle(color: white, fontSize: size, fontWeight: FontWeight.bold),
    );
  }
}

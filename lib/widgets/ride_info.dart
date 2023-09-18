import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class RideInfo extends StatelessWidget {
  final String type;
  final String value;
  final double maxWidth;
  final double fontSize;

  const RideInfo(
      {super.key,
      required this.type,
      required this.value,
      required this.maxWidth,
      this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(type, style: TextStyle(color: yellow, fontSize: fontSize)),
            Text(value, style: TextStyle(color: white, fontSize: fontSize))
          ],
        ));
  }
}

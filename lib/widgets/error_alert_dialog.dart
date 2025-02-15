import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class ErrorAlertDialog extends StatelessWidget {
  final String errorMessage;

  const ErrorAlertDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        backgroundColor: yellow,
        content: Text(errorMessage,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)));
  }
}

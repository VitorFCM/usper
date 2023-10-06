import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final double lateralPadding = 15;
  BaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: blue,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: 30, left: lateralPadding, right: lateralPadding),
        child: this.child,
      ),
    ));
  }
}

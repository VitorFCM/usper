import 'package:flutter/material.dart';

class InfoInputCard extends StatelessWidget {
  const InfoInputCard(
      {super.key,
      required this.title,
      required this.color,
      required this.inputWidget,
      required this.textColor,
      required this.minWidth,
      this.width});

  final String title;
  final Color color;
  final Widget inputWidget;
  final Color textColor;
  final double minWidth;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      width: width,
      height: 80,
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
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ),
          const SizedBox(
            height: 10,
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
}

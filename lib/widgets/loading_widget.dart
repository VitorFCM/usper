import 'package:flutter/material.dart';
import 'package:usper/constants/colors_constants.dart';

class LoadingWidget extends StatelessWidget {
  Widget infoSection;
  LoadingWidget({super.key, this.infoSection = const SizedBox()});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 150,
            width: 150,
            child: CircularProgressIndicator(
              color: yellow,
              strokeWidth: 10,
            ),
          ),
        ),
        infoSection
      ],
    );
  }
}

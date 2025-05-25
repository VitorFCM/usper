import 'dart:async';

import 'package:flutter/material.dart';
import 'package:usper/widgets/user_image.dart';

class BlinkingCircleImage extends StatefulWidget {
  final UserImage userImage;

  const BlinkingCircleImage({Key? key, required this.userImage})
      : super(key: key);

  @override
  _BlinkingCircleImageState createState() => _BlinkingCircleImageState();
}

class _BlinkingCircleImageState extends State<BlinkingCircleImage> {
  bool _visible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double diameter = widget.userImage.radius * 2 + 10;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
            ),
          ),
        ),
        widget.userImage,
      ],
    );
  }
}

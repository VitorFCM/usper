import 'dart:async';
import 'package:flutter/material.dart';

class ChangingTextWidget extends StatefulWidget {
  final List<String> texts;
  final double fontSize;
  final Duration duration;

  // Construtor
  ChangingTextWidget({
    required this.texts,
    this.fontSize = 16.0,
    this.duration = const Duration(seconds: 1),
  });

  @override
  _ChangingTextWidgetState createState() => _ChangingTextWidgetState();
}

class _ChangingTextWidgetState extends State<ChangingTextWidget> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
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
    return Text(
      widget.texts[_currentIndex],
      style: TextStyle(fontSize: widget.fontSize),
    );
  }
}

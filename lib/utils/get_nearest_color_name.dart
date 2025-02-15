import 'package:flutter/material.dart';

int _colorDistance(Color color1, Color color2) {
  int redDiff = color1.red - color2.red;
  int greenDiff = color1.green - color2.green;
  int blueDiff = color1.blue - color2.blue;

  return redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff;
}

String getNearestColorName(Color color) {
  Map<Color, String> colorNames = {
    Colors.red: "Vermelho",
    Colors.green: "Verde",
    Colors.blue: "Azul",
    Colors.yellow: "Amarelo",
    Colors.orange: "Laranja",
    Colors.purple: "Roxo",
    Colors.pink: "Rosa",
    Colors.brown: "Marrom",
    Colors.black: "Preto",
    Colors.white: "Branco",
    Colors.grey: "Cinza",
  };

  Color nearestColor = Colors.black;
  int minDistance =
      _colorDistance(Colors.black, Colors.white); //max distance possible

  colorNames.forEach((Color key, String value) {
    int distance = _colorDistance(color, key);
    if (distance < minDistance) {
      minDistance = distance;
      nearestColor = key;
    }
  });
  return colorNames[nearestColor]!;
}

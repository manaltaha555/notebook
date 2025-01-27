import 'package:flutter/material.dart';

class ScreenSize {
  final double screenWidth;
  final double screenHeight;

  ScreenSize({required this.screenWidth, required this.screenHeight});
}

ScreenSize getScreenSize(BuildContext context) {
  var orientation = MediaQuery.of(context).orientation;
  var size = MediaQuery.of(context).size;

  if (orientation == Orientation.portrait) {
    return ScreenSize(screenWidth: size.width, screenHeight: size.height);
  } else {
    return ScreenSize(screenWidth: size.height, screenHeight: size.width);
  }
}

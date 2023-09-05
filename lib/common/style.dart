import 'package:flutter/material.dart';

import '../config.dart';

ButtonStyle buttonStyle() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
    overlayColor: MaterialStateProperty.all<Color>(readColorEnd()),
  );
}

TextStyle tomorrowAndTodayTextStyle() {
  return TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
}
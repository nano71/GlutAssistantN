import 'package:flutter/material.dart';

import '../config.dart';

ButtonStyle buttonStyle() {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(readCardBackgroundColor2()),
    overlayColor: WidgetStateProperty.all<Color>(readColorEnd()),
  );
}

TextStyle tomorrowAndTodayTextStyle() {
  return TextStyle(fontSize: 14, color: readTextColor(), decoration: TextDecoration.none);
}

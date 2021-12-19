import 'package:flutter/material.dart';

import '../config.dart';

ButtonStyle buttonStyle(){
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
    overlayColor: MaterialStateProperty.all<Color>(readColorEnd()),
  );
}

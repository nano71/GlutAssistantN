import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconWidget extends StatefulWidget {
  final Key key;

  IconWidget(this.key);

  @override
  State<StatefulWidget> createState() => IconWidgetState();
}

class IconWidgetState extends State<IconWidget> {
  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _angle,
      child: const Icon(
        Icons.refresh,
        color: Colors.blue,
        size: 32,
      ),
    );
  }

  void onPressed(double angle) {
    setState(() => _angle = angle);
  }
}

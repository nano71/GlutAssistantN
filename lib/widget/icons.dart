import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshIconWidgetDynamic extends StatefulWidget {
  final Key key;

  RefreshIconWidgetDynamic(this.key);

  @override
  State<StatefulWidget> createState() => RefreshIconWidgetDynamicState();
}

class RefreshIconWidgetDynamicState extends State<RefreshIconWidgetDynamic> {
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

Icon chevronRight =const Icon(
  Icons.chevron_right,
  color: Colors.black45,
);

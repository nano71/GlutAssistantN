import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class RefreshIconWidgetDynamic extends StatefulWidget {
  const RefreshIconWidgetDynamic({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RefreshIconWidgetDynamicState();
}

class RefreshIconWidgetDynamicState extends State<RefreshIconWidgetDynamic> {
  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _angle,
      child: Icon(
        Icons.refresh,
        color: readColor(),
        size: 32,
      ),
    );
  }

  void onPressed(double angle) {
    setState(() => _angle = angle);
  }
}

Icon chevronRight = const Icon(
  Icons.chevron_right,
  color: Colors.black45,
);
Icon chevronDown = const Icon(
  Icons.keyboard_arrow_down_outlined,
  color: Colors.black45,
);
Icon chevronUp = const Icon(
  Icons.keyboard_arrow_up_outlined,
  color: Colors.black45,
);
Icon goCurrent = const Icon(
  Icons.gps_fixed_outlined,
  color: Colors.black,
  size: 24,
);

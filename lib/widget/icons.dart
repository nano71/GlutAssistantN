import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../config.dart';
import 'cards.dart';

class RefreshIconWidgetDynamic extends StatefulWidget {
  RefreshIconWidgetDynamic({Key? key}) : super(key: key);

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
        HomeCardsState.icons[0],
        color: readColor(),
        size: 32,
      ),
    );
  }

  void onPressed(double angle) {
    setState(() => _angle = angle);
  }
}

Icon chevronRight = Icon(
  Remix.arrow_right_s_line,
  color: Colors.black45,
  size: 18,
);
Icon chevronDown = Icon(
  Remix.arrow_down_s_line,
  color: Colors.black45,
);
Icon chevronUp = Icon(
  Remix.arrow_up_s_line,
  color: Colors.black45,
);
Icon goCurrent = Icon(
  Remix.map_pin_line,
  color: Colors.black,
  size: 14,
);

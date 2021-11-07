import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({Key? key}) : super(key: key);

  @override
  HomeCardState createState() => HomeCardState();
}

class HomeCardState extends State<HomeCard> with AutomaticKeepAliveClientMixin {
  GlobalKey<CircularProgressDynamicState> indicatorKey = GlobalKey();
  GlobalKey<TextProgressDynamicState> textKey = GlobalKey();
  final int _week = int.parse(writeData["week"]);

  @override
  void initState() {
    super.initState();
    // _getWeek();
    _weekProgressAnimation();
  }

  void _weekProgressAnimation() {
    double _count = 0.0;
    const period = Duration(milliseconds: 10);
    int next(int min, int max) {
      int res = min + Random().nextInt(max - min + 1);
      return res;
    }

    Timer.periodic(period, (timer) {
      _count += 0.01;
      indicatorKey.currentState!.onPressed(_count);
      textKey.currentState!.onPressed((_count * 100).toInt());
      if (_count >= _weekProgressDouble()) {
        timer.cancel();
      }
    });
  }

  String _weekProgressText() {
    return ((_week * 5) + (DateTime.now().weekday / 7 * 5)).toInt().toString() + "%";
  }

  double _weekProgressDouble() {
    return (_week * 5 / 100) + (DateTime.now().weekday / 7 * 5 / 100);
  }

  String _weekText() {
    if (_week == 20) {
      return "学期即将结束";
    } else if (_week >= 17) {
      return "期末来临,复习为重";
    } else if (_week >= 10) {
      return "学期过半,珍惜当下";
    } else if (_week >= 5) {
      return "已过小半,集中精力";
    } else if (_week >= 1) {
      return "开学不久,好好玩吧";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: Colors.blue,
      ),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: SizedBox(
              //限制进度条的高度
              height: 60.0,
              //限制进度条的宽度
              width: 60,
              child: CircularProgressDynamic(indicatorKey),
            ),
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 32, 0),
              child: TextProgressDynamic(textKey),
            )),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 24, 90, 0),
            child: Text(
              "第$_week周",
              style:
                  const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 90, 24),
              child: Text(_weekText(), style: const TextStyle(color: Colors.white)),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
                width: 60,
                margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Center(
                    child: Text(DateTime.now().weekday.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))))
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget homeCard2 = Stack(
  children: [
    Align(
      child: Container(
        margin: HomeCardsState.iconMargin,
        child: Icon(
          HomeCardsState.icons[1],
          color: Colors.blue,
          size: HomeCardsState.iconSize,
        ),
      ),
    ),
    Align(
      child: Container(
        margin: HomeCardsState.textMargin,
        child: Text(HomeCardsState.iconTexts[1], style: HomeCardsState.textStyle),
      ),
    ),
  ],
);

Widget homeCard3 = Stack(
  children: [
    Align(
      child: Container(
        margin: HomeCardsState.iconMargin,
        child: Icon(
          HomeCardsState.icons[2],
          color: Colors.blue,
          size: HomeCardsState.iconSize,
        ),
      ),
    ),
    Align(
      child: Container(
        margin: HomeCardsState.textMargin,
        child: Text(HomeCardsState.iconTexts[2], style: HomeCardsState.textStyle),
      ),
    ),
  ],
);

class HomeCardsState {
  static double iconSize = 36;
  static List icons = [Icons.refresh, Icons.saved_search, Icons.library_books_sharp];
  static List iconTexts = ["课表刷新", "教室查询", "我的考试"];
  static EdgeInsetsGeometry textMargin = const EdgeInsets.fromLTRB(0, 44, 0, 0);
  static EdgeInsetsGeometry iconMargin = const EdgeInsets.fromLTRB(0, 0, 0, 32);
  static Decoration? cardDecoration = const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    color: Color.fromARGB(42, 199, 229, 253),
  );
  static double width = double.infinity;
  static TextStyle textStyle = const TextStyle(color: Colors.black54);
}

class CircularProgressDynamic extends StatefulWidget {
  final Key key;

  CircularProgressDynamic(this.key);

  @override
  State<StatefulWidget> createState() => CircularProgressDynamicState();
}

class CircularProgressDynamicState extends State<CircularProgressDynamic> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 8,
      //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
      value: _value,
      //背景颜色
      backgroundColor: const Color.fromARGB(128, 255, 255, 255),
      //进度颜色
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void onPressed(double value) {
    setState(() => _value = value);
  }
}

class TextProgressDynamic extends StatefulWidget {
  final Key key;

  TextProgressDynamic(this.key);

  @override
  State<StatefulWidget> createState() => TextProgressDynamicState();
}

class TextProgressDynamicState extends State<TextProgressDynamic> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Text((_value.toString() + "%"), style: const TextStyle(color: Colors.white));
  }

  void onPressed(int value) {
    setState(() => _value = value);
  }
}

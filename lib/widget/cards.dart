import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../config.dart';
import '../data.dart';

class HomePageSemesterProgressCard extends StatefulWidget {
  HomePageSemesterProgressCard({Key? key}) : super(key: key);

  @override
  _HomePageSemesterProgressCardState createState() => _HomePageSemesterProgressCardState();
}

class _HomePageSemesterProgressCardState extends State<HomePageSemesterProgressCard>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<_HomePageDynamicCircularProgressBarState> indicatorKey = GlobalKey();
  GlobalKey<_HomePageDynamicProgressTextState> textKey = GlobalKey();
  int week = weekInt();

  @override
  void initState() {
    super.initState();
    // _getWeek();
    circularProgressBarAnimation();
  }

  void circularProgressBarAnimation() {
    double count = 0.0;
    Duration period = Duration(milliseconds: 10);
    Timer.periodic(period, (timer) {
      count += 0.01;
      indicatorKey.currentState!.onPressed(count);
      textKey.currentState!.onPressed((count * 100).toInt());
      if (count >= currentProgress()) {
        timer.cancel();
      }
    });
  }

  double currentProgress() {
    if (week > 20) {
      return 1.00;
    }
    return (week * 5 / 100) - 0.05 + (DateTime.now().weekday / 7 * 5 / 100);
  }

  String tipText() {
    if (week > 20) {
      return "学期已经结束咯";
    } else if (week == 20) {
      return "学期即将结束";
    } else if (week >= 15) {
      return "期末来临,复习为重";
    } else if (week >= 10) {
      return "学期过半,珍惜当下";
    } else if (week >= 5) {
      return "已过小半,集中精力";
    } else if (week >= 1) {
      return "开学不久,好好玩吧";
    } else {
      return "新学期即将到来";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        // color: Global.homeCardsColor,
        gradient: readGradient(),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: SizedBox(
                //限制进度条的高度
                height: 110 - 32 - 4,
                //限制进度条的宽度
                width: 110 - 32 - 4,
                child: _HomePageDynamicCircularProgressBar(key: indicatorKey),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 16 + (110 - 32) / 2 - 20, 0),
                child: SizedBox(width: 40, child: _HomePageDynamicProgressText(key: textKey))),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 30, 110, 0),
              child: Text(
                "第${week}周",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 110, 30),
                child: Text(tipText(), style: TextStyle(color: Colors.white)),
              )),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 80,
              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Center(
                child: Text(
                  DateTime.now().weekday.toString(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Widget homeCard2 = Stack(
//   children: [
//     Align(
//       child: Container(
//         margin: HomeCardsState.iconMargin,
//         child: Icon(
//           HomeCardsState.icons[1],
//           color: readColor(),
//           size: HomeCardsState.iconSize,
//         ),
//       ),
//     ),
//     Align(
//       child: Container(
//         margin: HomeCardsState.textMargin,
//         // child: Text(HomeCardsState.iconTexts[1], style: HomeCardsState.textStyle),
//       ),
//     ),
//   ],
// );
//
// Widget homeCard3 = Stack(
//   children: [
//     Align(
//       child: Container(
//         margin: HomeCardsState.iconMargin,
//         child: Icon(
//           HomeCardsState.icons[2],
//           color: readColor(),
//           size: HomeCardsState.iconSize,
//         ),
//       ),
//     ),
//     Align(
//       child: Container(
//         margin: HomeCardsState.textMargin,
//         // child: Text(HomeCardsState.iconTexts[2], style: HomeCardsState.textStyle),
//       ),
//     ),
//   ],
// );

class HomePageCardsState {
  static double iconSize = 36;
  static List icons = [Remix.refresh_line, Remix.search_eye_line, Remix.file_list_3_line];
  static List iconTexts = ["课表刷新", "成绩查询", "我的考试"];
  static EdgeInsetsGeometry textMargin = EdgeInsets.fromLTRB(0, 44, 0, 0);
  static EdgeInsetsGeometry iconMargin = EdgeInsets.fromLTRB(0, 0, 0, 32);
  static Decoration? cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    color: Color.fromARGB(42, 199, 229, 253),
  );
  static double width = double.infinity;
}

class _HomePageDynamicCircularProgressBar extends StatefulWidget {
  _HomePageDynamicCircularProgressBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageDynamicCircularProgressBarState();
}

class _HomePageDynamicCircularProgressBarState extends State<_HomePageDynamicCircularProgressBar> {
  double value = 0.0;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 4,
      value: value,
      backgroundColor: Color.fromARGB(48, 255, 255, 255),
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void onPressed(double newValue) {
    setState(() => value = newValue);
  }
}

class _HomePageDynamicProgressText extends StatefulWidget {
  _HomePageDynamicProgressText({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageDynamicProgressTextState();
}

class _HomePageDynamicProgressTextState extends State<_HomePageDynamicProgressText> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Text(
      (value < 10 ? "0" + value.toString() + "%" : value.toString() + "%"),
      style: TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  void onPressed(int newValue) {
    setState(() => value = newValue);
  }
}

Widget OptionsCard({required Widget child}) {
  return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: readCardBackgroundColor(),
      ),
      padding: EdgeInsets.all(16),
      child: child);
}

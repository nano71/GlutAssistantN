import 'dart:async';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/dialog.dart';

import '../config.dart';

class RowHeader extends StatefulWidget {
  const RowHeader({Key? key}) : super(key: key);

  @override
  RowHeaderState createState() => RowHeaderState();
}

class RowHeaderState extends State<RowHeader> {
  String _week = writeData["week"];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //  decoration: ,
      children: _loopRowHeader(writeData["week"] == _week),
    );
  }

  void onPressed(int week) {
    setState(() => _week = week.toString());
  }
}

List<Widget> _loopRowHeader(bool nowWeek) {
  List _weekDayList = ["一", "二", "三", "四", "五", "六", "日"];
  List<Widget> list = [];
  for (int i = 0; i < 8; i++) {
    if (i == 0) {
      list.add(const SizedBox(width: 20));
    } else {
      list.add(
        Expanded(
          child: Container(
            height: 30,
            child: Center(
              child: Text(
                "周${_weekDayList[i - 1]}",
                style: TextStyle(
                    color: nowWeek
                        ? (i == DateTime.now().weekday ? readColor() : Colors.grey)
                        : Colors.grey),
              ),
            ),
          ),
        ),
      );
    }
  }
  return list;
}

Widget _leftGrid(String title) {
  return Container(
    width: 20,
    height: Global.schedulePageGridHeight,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
          top: BorderSide(
            width: 0.5, //宽度
            color: title != "1" ? Color(0xfff9f9f9) : Colors.white, //边框颜色
          ),
          right: BorderSide(
            width: 0.5, //宽度
            color: Color(0xfff9f9f9), //边框颜色
          )),
    ),
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: readColor()),
    ),
  );
}

List<Widget> _loopLeftGrid() {
  List<Widget> list = [];
  for (int i = 1; i < 12; i++) {
    list.add(_leftGrid(i.toString()));
  }
  return list;
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

GlobalKey<SchedulePageState> schedulePageKey = GlobalKey();
EventBus reState = EventBus();

class SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin {
  late double _startPositionX;
  late double _startPositionY;
  int _currentScheduleWeek = int.parse(writeData["week"]);
  GlobalKey<SchedulePageColumnState> weekKey = GlobalKey();
  GlobalKey<ScheduleTopBarState> barKey = GlobalKey();
  GlobalKey<RowHeaderState> rowHeaderKey = GlobalKey();
  late StreamSubscription<ReState> eventBusFn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusFn = pageBus.on<ReState>().listen((event) {
      reState();
    });
  }

  void _warning1() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "已经没了!", 1));
  }

  void _showWeekSnackBar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(jwSnackBar(3, "第" + _currentScheduleWeek.toString() + "周", 0));
  }

  void _touchListen(double eX, double eY) {
    double minValue = Global.schedulePageTouchMovesMinValue;
    double sX = _startPositionX;
    double sY = _startPositionY;
    if (eY - sY < minValue || eY + sY < minValue) {
      if (sX - eX > minValue) {
        if (_currentScheduleWeek == 25) {
          _warning1();
        } else {
          // print("下一页");
          _currentScheduleWeek++;
          _showWeekSnackBar();
          _findNewSchedule();
        }
      } else if (eX - sX > minValue) {
        if (_currentScheduleWeek == 1) {
          _warning1();
        } else {
          // print("上一页");
          _currentScheduleWeek--;
          _showWeekSnackBar();
          _findNewSchedule();
        }
      }
    }
  }

  void _findNewSchedule() {
    weekKey.currentState!.onPressed(_currentScheduleWeek);
    barKey.currentState!.onPressed(_currentScheduleWeek);
    rowHeaderKey.currentState!.onPressed(_currentScheduleWeek);
  }

  reState() {
    setState(() {});
    if (writeData["week"] != _currentScheduleWeek.toString()) {
      _currentScheduleWeek = int.parse(writeData["week"]);
      weekKey.currentState!.onPressed(int.parse(writeData["week"]));
      barKey.currentState!.onPressed(int.parse(writeData["week"]));
      rowHeaderKey.currentState!.onPressed(int.parse(writeData["week"]));
    }
  }

  @override
  void dispose() {
    eventBusFn.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Column(
        children: [
          ScheduleTopBar(key: barKey),
          RowHeader(key: rowHeaderKey),
          Expanded(
            child: Listener(
              onPointerDown: (e) {
                _startPositionX = e.position.dx;
                _startPositionY = e.position.dy;
              },
              onPointerUp: (e) {
                _touchListen(e.position.dx, e.position.dy);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                scrollDirection: Axis.vertical,
                child: Row(
                  children: [
                    Column(
                      children: _loopLeftGrid(),
                    ),
                    SchedulePageColumn(key: weekKey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//星期几
class SchedulePageColumn extends StatefulWidget {
  const SchedulePageColumn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SchedulePageColumnState();
}

class SchedulePageColumnState extends State<SchedulePageColumn> {
  String _findWeek = writeData["week"];

  @override
  Widget build(BuildContext context) {
    if (int.parse(_findWeek) > 20) {
      _findWeek = "20";
    }
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _loopWeekDayCol(_findWeek),
      ),
    );
  }

  void onPressed(int week) {
    setState(() => _findWeek = week.toString());
  }
}

List<Widget> _loopWeekDayCol(String week) {
  List<Widget> list = [];
  for (int i = 1; i < 8; i++) {
    list.add(_col(week, i.toString()));
  }
  return list;
}

Widget _col(String week, String weekDay) {
  return Expanded(
    child: Column(
      children: _loopWeekDayColGrid(week, weekDay),
    ),
  );
}

List<Widget> _loopWeekDayColGrid(String week, String weekDay) {
  List<Widget> list = [];
  Map _schedule = schedule[week][weekDay];
  int s = 1;
  for (int i = 1; i < 12; i++) {
    String courseName = courseLongText2ShortName(_schedule[i.toString()][0]);
    String studyArea = _schedule[i.toString()][2];
    String teacher = _schedule[i.toString()][1];

    if (courseName != "null") {
      if (i == 1) {
        s = i;
      } else if (courseName == courseLongText2ShortName(_schedule[(i - 1).toString()][0])) {
        if (i == 11) {
          list.add(Grid(week, weekDay, i, s, courseName, studyArea, teacher, randomColors(),
              Global.schedulePageGridHeight * (i - s + 1)));
        } else if (courseName != courseLongText2ShortName(_schedule[(i + 1).toString()][0])) {
          list.add(Grid(week, weekDay, i, s, courseName, studyArea, teacher, randomColors(),
              Global.schedulePageGridHeight * (i - s + 1)));
        }
      } else {
        s = i;
      }
    } else {
      list.add(Grid(week, weekDay, 0, 0, "", "", "", Colors.white));
    }
  }
  return list;
}

class Grid extends StatelessWidget {
  final int index;
  final int index2;
  final String title;
  final String studyArea;
  final String teacher;
  final Color color;
  final double height;
  final String week;
  final String weekDay;

  Grid(this.week, this.weekDay, this.index, this.index2, this.title, this.studyArea, this.teacher,
      this.color,
      [this.height = 60.0]);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle style = const TextStyle(fontSize: 12, color: Colors.white);
    return InkWell(
      onTap: () {
        if (index != 0||index2 != 0) {
          // print(index2);
          // print(index);
          scheduleDialog(context, week, weekDay, index.toString());
          // ScaffoldMessenger.of(context).removeCurrentSnackBar();
          // ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, teacher, 2));
        }
      },
      child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            border: Border(
              top: BorderSide(
                width: 1, //宽度
                color: Colors.white, //边框颜色
              ),
              right: BorderSide(
                width: 1, //宽度
                color: Colors.white, //边框颜色
              ),
              bottom: BorderSide(
                width: 1, //宽度
                color: Colors.white, //边框颜色
              ),
              left: BorderSide(
                width: 1, //宽度
                color: Colors.white, //边框颜色
              ),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          ),
          padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                softWrap: true,
                style: style,
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  // Text(
                  //   teacher,
                  //   textAlign: TextAlign.center,
                  //   softWrap: true,
                  //   style: style,
                  // ),
                  Text(
                    studyArea,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: style,
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

// Widget _grid(int index, int index2, String title, String studyArea, String teacher, Color color,
//     [double height = 60.0]) {
//   TextStyle style = const TextStyle(fontSize: 12, color: Colors.white);
//   return InkWell(
//     onTap: () {
//       if (index != 0) {
//         // print(index2);
//         // print(index);
//         // ScaffoldMessenger.of(context).removeCurrentSnackBar();
//         // ScaffoldMessenger.of(context)
//         //     .showSnackBar(jwSnackBar(1, "第" + _currentScheduleWeek.toString() + "周", 0));
//       }
//     },
//     child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: color,
//           border: Border(
//             top: BorderSide(
//               width: 1, //宽度
//               color: Colors.white, //边框颜色
//             ),
//             right: BorderSide(
//               width: 1, //宽度
//               color: Colors.white, //边框颜色
//             ),
//             bottom: BorderSide(
//               width: 1, //宽度
//               color: Colors.white, //边框颜色
//             ),
//             left: BorderSide(
//               width: 1, //宽度
//               color: Colors.white, //边框颜色
//             ),
//           ),
//           borderRadius: const BorderRadius.all(Radius.circular(6.0)),
//         ),
//         padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               softWrap: true,
//               style: style,
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Column(
//               children: [
//                 // Text(
//                 //   teacher,
//                 //   textAlign: TextAlign.center,
//                 //   softWrap: true,
//                 //   style: style,
//                 // ),
//                 Text(
//                   studyArea,
//                   textAlign: TextAlign.center,
//                   softWrap: true,
//                   style: style,
//                 ),
//               ],
//             ),
//           ],
//         )),
//   );
// }

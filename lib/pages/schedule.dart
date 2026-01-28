import 'dart:async';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '/common/io.dart';
import '/data.dart';
import '/widget/bars.dart';
import '/widget/dialog.dart';
import '../config.dart';

class RowHeader extends StatefulWidget {
  RowHeader({Key? key}) : super(key: key);

  @override
  RowHeaderState createState() => RowHeaderState();
}

class RowHeaderState extends State<RowHeader> {
  int _week = weekInt(exclusionZero: true);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //  decoration: ,
      children: [
        SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _loopRowHeader(AppData.week == _week),
              ),
              (AppData.persistentData["showDayByWeekDay"] ?? "0") == "1"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _loopRowHeader2(DateTime.now(), _week),
                    )
                  : Container(),
            ],
          ),
        )
      ],
    );
  }

  void onPressed(int week) {
    setState(() => _week = week);
  }
}

List<Widget> _loopRowHeader(bool isCurrentWeek) {
  List _weekDayList = ["一", "二", "三", "四", "五", "六", "日"];
  List<Widget> list = [];
  for (int i = 0; i < 7; i++) {
    list.add(
      Expanded(
        child: Container(
          height: 30,
          child: Center(
            child: Text(
              "周${_weekDayList[i]}",
              style: TextStyle(color: isCurrentWeek ? (i + 1 == DateTime.now().weekday ? readColor() : Colors.grey) : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
  return list;
}

List<int> fillWeekWithWeekOffset(DateTime today, int difference) {
  // 获取今天是星期几，1是周一，7是周日
  int currentDayOfWeek = today.weekday;

  // 计算今天所在周的周一日期
  DateTime startOfWeek = today.subtract(Duration(days: currentDayOfWeek - 1));

  // 通过偏移量计算目标周的起始日期
  DateTime targetWeekStart = startOfWeek.add(Duration(days: difference * 7));

  // 生成目标周的日期天数，0:周一, 1:周二, ..., 6:周日
  List<int> weekDays = List.generate(7, (index) {
    return targetWeekStart.add(Duration(days: index)).day;
  });

  return weekDays;
}

List<Widget> _loopRowHeader2(DateTime current, int currentWeek) {
  List<Widget> list = [];
  int difference = currentWeek - AppData.week;
  List<int> weekDays = fillWeekWithWeekOffset(current, difference);
  for (var value in weekDays) {
    list.add(
      Expanded(
        child: Container(
          // height: 30,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Center(
            child: Text(
              "$value",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
  return list;
}

Widget _leftGrid(String title) {
  return Container(
    width: 20,
    height: AppConfig.schedulePageGridHeight,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: readBackgroundColor(),
      border: Border(
          top: BorderSide(
            width: 1, //宽度
            color: Color(0xffFFFFFF), //边框颜色
          ),
          right: BorderSide(
            width: 1, //宽度
            color: Color(0xffFFFFFF), //边框颜色
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
  SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

GlobalKey<SchedulePageState> schedulePageKey = GlobalKey();
EventBus reState = EventBus();

class SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin {
  late double _startPositionX;
  late double _startPositionY;
  int _currentScheduleWeek = weekInt(exclusionZero: true);
  GlobalKey<SchedulePageColumnState> weekKey = GlobalKey();
  GlobalKey<ScheduleTopBarState> barKey = GlobalKey();
  GlobalKey<RowHeaderState> rowHeaderKey = GlobalKey();
  late StreamSubscription<ReloadSchedulePageState> eventBusListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Duration duration = Duration(milliseconds: 500);
    Timer(duration, () {
      AppData.persistentData["prompt"] ??= "5";

      int _number = int.parse(AppData.persistentData["prompt"] ?? "");
      if (_number > 0) {
        _showPrompt();
        _number--;
        AppData.persistentData["prompt"] = _number.toString();
        writeConfig();
      }
    });
    eventBusListener = eventBus.on<ReloadSchedulePageState>().listen((event) {
      setState(() {});
      if (AppData.week != _currentScheduleWeek) {
        _currentScheduleWeek = weekInt(exclusionZero: true);
        weekKey.currentState!.onPressed(weekInt(exclusionZero: true));
        barKey.currentState!.onPressed(weekInt(exclusionZero: true));
        rowHeaderKey.currentState!.onPressed(weekInt(exclusionZero: true));
      }
    });
  }

  void _warning1() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "已经没了!", 1));
  }

  void _showWeekSnackBar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "第" + _currentScheduleWeek.toString() + "周", 0));
  }

  void _showPrompt() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "左右划动 ~", 2));
  }

  void _touchListen(double eX, double eY) {
    double minValue = AppConfig.schedulePageTouchMovesMinValue;
    double sX = _startPositionX;
    double sY = _startPositionY;
    if (eY - sY < minValue || eY + sY < minValue) {
      if (sX - eX > minValue) {
        if (_currentScheduleWeek == 25) {
          _warning1();
        } else {
          print("下一页");
          _currentScheduleWeek++;
          _showWeekSnackBar();
          _findNewSchedule();
        }
      } else if (eX - sX > minValue) {
        if (_currentScheduleWeek == 1) {
          _warning1();
        } else {
          print("上一页");
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

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: readBackgroundColor(),
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
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
  SchedulePageColumn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SchedulePageColumnState();
}

class SchedulePageColumnState extends State<SchedulePageColumn> {
  int _findWeek = weekInt(exclusionZero: true);

  @override
  Widget build(BuildContext context) {
    if (_findWeek > 20) {
      _findWeek = 20;
    }
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _loopWeekDayCol(_findWeek.toString()),
      ),
    );
  }

  void onPressed(int week) {
    setState(() => _findWeek = week);
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
  Map _schedule = AppData.schedule[week][weekDay];
  int s = 1;
  for (int i = 1; i < 12; i++) {
    String courseName = courseLongText2Short(_schedule[i.toString()][0]);
    String studyArea = _schedule[i.toString()][2];
    String teacher = _schedule[i.toString()][1];
    bool courseNameNotNull() => courseName != "null";
    if (courseNameNotNull()) {
      bool courseNameIsPreviousCourseName() => courseName == courseLongText2Short(_schedule[(i - 1).toString()][0]);
      bool courseNameNotIsNextCourseName() => courseName != courseLongText2Short(_schedule[(i + 1).toString()][0]);
      bool studyAreaNotIsNextStudyArea() => studyArea != _schedule[(i + 1).toString()][2];
      bool studyAreaIsPreviousStudyArea() => studyArea == _schedule[(i - 1).toString()][2];

      if (i == 1)
        s = i;
      else if (studyAreaIsPreviousStudyArea() && courseNameIsPreviousCourseName()) {
        double height = AppConfig.schedulePageGridHeight * (i - s + 1);
        if (i == 11)
          list.add(Grid(week, weekDay, i, s, courseName, studyArea, teacher, randomColors(), height));
        else if (studyAreaNotIsNextStudyArea() || courseNameNotIsNextCourseName()) list.add(Grid(week, weekDay, i, s, courseName, studyArea, teacher, randomColors(), height));
      } else
        s = i;
    } else
      list.add(Grid(week, weekDay, i, 0, "", "", "", readBackgroundColor()));
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

  Grid(this.week, this.weekDay, this.index, this.index2, this.title, this.studyArea, this.teacher, this.color, [this.height = 60.0]);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle style = TextStyle(fontSize: 12, color: Colors.white);
    BoxDecoration decoration = BoxDecoration(
      color: color,
      border: Border.all(
        width: 1, //宽度
        color: readBackgroundColor(), //边框颜色
      ),
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    );
    if (index == 11 && index2 == 0) {
      decoration = BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(
            width: 1, //宽度
            color: Colors.white, //边框颜色
          ),
          right: BorderSide(
            width: 1, //宽度
            color: Colors.white, //边框颜色
          ),
        ),
      );
    } else if (index == 1 && index2 == 0) {
      decoration = BoxDecoration(
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
        ),
      );
    } else if (index % 2 == 0 && index2 == 0) {
      decoration = BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(
            width: 1, //宽度
            color: Colors.white, //边框颜色
          ),
          right: BorderSide(
            width: 1, //宽度
            color: Colors.white, //边框颜色
          ),
        ),
      );
    } else if (index2 == 0) {
      decoration = BoxDecoration(
        color: color,
        border: Border(
          right: BorderSide(
            width: 1, //宽度
            color: Colors.white, //边框颜色
          ),
        ),
      );
    }
    return InkWell(
      onTap: () {
        if (index != 0 && index2 != 0) {
          print(index2);
          print(index);
          scheduleDialog(context, week, weekDay, index.toString());
          // ScaffoldMessenger.of(context).removeCurrentSnackBar();
          // ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, teacher, 2));
        }
      },
      child: Container(
          height: height,
          decoration: decoration,
          padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
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
              SizedBox(
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
//   TextStyle style =  TextStyle(fontSize: 12, color: Colors.white);
//   return InkWell(
//     onTap: () {
//       if (index != 0) {
//         print(index2);
//         print(index);
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
//           borderRadius:  BorderRadius.all(Radius.circular(6.0)),
//         ),
//         padding:  EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
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
//              SizedBox(
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

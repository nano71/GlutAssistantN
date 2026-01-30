import 'dart:async';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '/data.dart';
import '/widget/bars.dart';
import '/widget/dialog.dart';
import '../config.dart';

class _Header extends StatefulWidget {
  _Header({Key? key}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
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
              AppData.showDayByWeekDay
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
  DateTime now = DateTime.now();
  Color textColor(int i) {
    if (isCurrentWeek && i + 1 == now.weekday) {
      return readColor();
    }
    return Colors.grey;
  }

  for (int i = 0; i < 7; i++) {
    list.add(
      Expanded(
        child: Container(
          height: 30,
          child: Center(
            child: Text(
              "周${_weekDayList[i]}",
              style: TextStyle(color: textColor(i)),
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
  int day = DateTime.now().day;
  for (var value in weekDays) {
    list.add(
      Expanded(
        child: Container(
          // height: 30,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Center(
            child: Text(
              "$value",
              style: TextStyle(color: difference == 0 && value == day ? readColor() : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
  return list;
}

Widget _LeftGrid(String title) {
  return Container(
      width: 20,
      height: AppConfig.schedulePageGridHeight,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: readBackgroundColor(),
          border: Border(
            bottom: BorderSide(
              width: 1, //宽度
              color: title == "11" ? Colors.transparent : readBorderColor(), //边框颜色
            ),
          ),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: readColor()),
        ),
      ));
}

List<Widget> _LeftGrids() {
  List<Widget> list = [];
  for (int i = 1; i < 12; i++) {
    list.add(_LeftGrid(i.toString()));
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
  late double startPositionX;
  late double startPositionY;
  int currentScheduleWeek = weekInt(exclusionZero: true);
  GlobalKey<_ContentState> weekKey = GlobalKey();
  GlobalKey<ScheduleTopBarState> topBarKey = GlobalKey();
  GlobalKey<_HeaderState> rowHeaderKey = GlobalKey();
  late StreamSubscription<ReloadSchedulePageState> eventBusListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (AppData.schedulePagePromptCount < 5) {
      Timer(Duration(milliseconds: 500), () {
        showTip();
        AppData.schedulePagePromptCount++;
      });
    }

    eventBusListener = eventBus.on<ReloadSchedulePageState>().listen((event) {
      setState(() {});
      if (AppData.week != currentScheduleWeek) {
        currentScheduleWeek = weekInt(exclusionZero: true);
        weekKey.currentState!.onPressed(weekInt(exclusionZero: true));
        topBarKey.currentState!.onPressed(weekInt(exclusionZero: true));
        rowHeaderKey.currentState!.onPressed(weekInt(exclusionZero: true));
      }
    });
  }

  void showWarningTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "已经没了!", 1));
  }

  void showCurrentWeekTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "第" + currentScheduleWeek.toString() + "周", 0));
  }

  void showTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "左右划动 ~", 2));
  }

  void onTouchMove(double eX, double eY) {
    double minValue = AppConfig.schedulePageTouchMovesMinValue;
    double sX = startPositionX;
    double sY = startPositionY;
    if (eY - sY < minValue || eY + sY < minValue) {
      if (sX - eX > minValue) {
        if (currentScheduleWeek == 25) {
          showWarningTip();
        } else {
          print("下一页");
          currentScheduleWeek++;
          showCurrentWeekTip();
          _findNewSchedule();
        }
      } else if (eX - sX > minValue) {
        if (currentScheduleWeek == 1) {
          showWarningTip();
        } else {
          print("上一页");
          currentScheduleWeek--;
          showCurrentWeekTip();
          _findNewSchedule();
        }
      }
    }
  }

  void _findNewSchedule() {
    weekKey.currentState!.onPressed(currentScheduleWeek);
    topBarKey.currentState!.onPressed(currentScheduleWeek);
    rowHeaderKey.currentState!.onPressed(currentScheduleWeek);
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
          ScheduleTopBar(key: topBarKey),
          _Header(key: rowHeaderKey),
          Expanded(
            child: Listener(
              onPointerDown: (e) {
                startPositionX = e.position.dx;
                startPositionY = e.position.dy;
              },
              onPointerUp: (e) {
                onTouchMove(e.position.dx, e.position.dy);
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                scrollDirection: Axis.vertical,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: readBorderColor(),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: _LeftGrids(),
                      ),
                    ),
                    _Content(key: weekKey),
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
class _Content extends StatefulWidget {
  _Content({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  int currentWeek = weekInt(exclusionZero: true);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _Columns(currentWeek > 20 ? "20" : currentWeek.toString()),
      ),
    );
  }

  void onPressed(int week) {
    setState(() => currentWeek = week);
  }
}

List<Widget> _Columns(String week) {
  List<Widget> list = [];
  for (int i = 1; i < 8; i++) {
    list.add(_Column(week, i.toString()));
  }
  return list;
}

Widget _Column(String week, String weekDay) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: readBorderColor()),
          top: BorderSide(width: 1, color: readBorderColor()),
          bottom: BorderSide(width: 1, color: readBorderColor()),
        ),
      ),
      child: Column(
        children: _Grids(week, weekDay),
      ),
    ),
  );
}

List<Widget> _Grids(String week, String weekDay) {
  List<Widget> list = [];
  Map _schedule = AppData.schedule[week][weekDay];
  int start = 1;
  for (int end = 1; end < 12; end++) {
    String courseName = courseLongText2Short(_schedule[end.toString()][0]);
    String studyArea = _schedule[end.toString()][2];
    String teacher = _schedule[end.toString()][1];
    bool courseNameNotNull() => courseName != "null";
    if (courseNameNotNull()) {
      bool courseNameIsPreviousCourseName() => courseName == courseLongText2Short(_schedule[(end - 1).toString()][0]);
      bool courseNameNotIsNextCourseName() => courseName != courseLongText2Short(_schedule[(end + 1).toString()][0]);
      bool studyAreaNotIsNextStudyArea() => studyArea != _schedule[(end + 1).toString()][2];
      bool studyAreaIsPreviousStudyArea() => studyArea == _schedule[(end - 1).toString()][2];

      if (end == 1) {
        start = end;
      } else if (studyAreaIsPreviousStudyArea() && courseNameIsPreviousCourseName()) {
        double height = AppConfig.schedulePageGridHeight * (end - start + 1);
        if (end == 11 || studyAreaNotIsNextStudyArea() || courseNameNotIsNextCourseName()) {
          list.add(_Grid(week, weekDay,start,  end, courseName, studyArea, teacher, randomColors(), height));
        }
      } else {
        start = end;
      }
    } else {
      list.add(_Grid(week, weekDay, 0, end, "", "", "", readBackgroundColor()));
    }
  }
  return list;
}

class _Grid extends StatelessWidget {
  final int start;
  final int end;
  final String title;
  final String classroomNumber;
  final String teacher;
  final Color color;
  final double height;
  final String week;
  final String weekDay;

  _Grid(this.week, this.weekDay, this.start, this.end, this.title, this.classroomNumber, this.teacher, this.color,
      [this.height = 60.0]);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle style = TextStyle(fontSize: 12, color: Colors.white);
    late BoxDecoration decoration;
    if (start % 2 == 0) {
      decoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1, //宽度
            color: readBorderColor(), //边框颜色
          ),
        ),
      );
    } else {
      decoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1, //宽度
            color: Colors.transparent, //边框颜色
          ),
        ),
      );
    }
    return InkWell(
        onTap: () {
          if (start != 0 && end != 0) {
            print(start);
            print(end);
            scheduleDialog(context, week, weekDay, start.toString());
            // ScaffoldMessenger.of(context).removeCurrentSnackBar();
            // ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, teacher, 2));
          }
        },
        child: Container(
          height: height,
          child: Container(
            decoration: decoration,
            child: Container(
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
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
                          classroomNumber,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: style,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ));
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

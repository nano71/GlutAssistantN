import 'dart:async';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../type/course.dart';
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
    print("onPressed");
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
  GlobalKey<_HeaderState> headerKey = GlobalKey();
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
      print(1742);
      setState(() {});
      if (AppData.week != currentScheduleWeek) {
        currentScheduleWeek = weekInt(exclusionZero: true);
        weekKey.currentState!.onPressed(weekInt(exclusionZero: true));
        topBarKey.currentState!.onPressed(weekInt(exclusionZero: true));
        headerKey.currentState!.onPressed(weekInt(exclusionZero: true));
      }
    });
  }

  void showWarningTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "已经没了!", 1));
  }

  void showCurrentWeekTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(3, "第" + currentScheduleWeek.toString() + "周", 0));
  }

  void showTip() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(3, "左右划动 ~", 2));
  }

  void onTouchMove(double eX, double eY) {
    double minValue = AppConfig.schedulePageMinSwipeDistance;
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
          updateState();
        }
      } else if (eX - sX > minValue) {
        if (currentScheduleWeek == 1) {
          showWarningTip();
        } else {
          print("上一页");
          currentScheduleWeek--;
          showCurrentWeekTip();
          updateState();
        }
      }
    }
  }

  void updateState() {
    weekKey.currentState!.onPressed(currentScheduleWeek);
    topBarKey.currentState!.onPressed(currentScheduleWeek);
    headerKey.currentState!.onPressed(currentScheduleWeek);
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
          _Header(key: headerKey),
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
        children: _Columns(currentWeek > 20 ? 20 : currentWeek),
      ),
    );
  }

  void onPressed(int week) {
    print("onPressed2");
    setState(() => currentWeek = week);
  }
}

List<Widget> _Columns(int week) {
  List<Widget> list = [];
  for (int i = 1; i < 8; i++) {
    list.add(_Column(week, i));
  }
  return list;
}

Widget _Column(int week, int weekDay) {
  Color borderColor = readBorderColor();
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: borderColor),
          top: BorderSide(width: 1, color: borderColor),
          bottom: BorderSide(width: 1, color: borderColor),
        ),
      ),
      child: Column(
        children: _Grids(week, weekDay),
      ),
    ),
  );
}

List<Widget> _Grids(int week, int weekDay) {
  List<Widget> list = [];
  List<Course> daySchedule = AppData.schedule[week][weekDay];
  int start = 1;
  Color defaultColor = readBackgroundColor();
  for (int end = 1; end < 12; end++) {
    Course course = daySchedule[end];
    String courseName = courseLongText2Short(course.name);

    if (!course.isEmpty) {
      bool courseNameIsPreviousCourseName() => courseName == courseLongText2Short(daySchedule[end - 1].name);
      bool courseNameNotIsNextCourseName() => courseName != courseLongText2Short(daySchedule[end + 1].name);
      bool studyAreaNotIsNextStudyArea() => course.location != daySchedule[end + 1].location;
      bool studyAreaIsPreviousStudyArea() => course.location == daySchedule[end - 1].location;

      if (end == 1) {
        start = end;
      } else if (studyAreaIsPreviousStudyArea() && courseNameIsPreviousCourseName()) {
        double height = AppConfig.schedulePageGridHeight * (end - start + 1);
        if (end == 11 || studyAreaNotIsNextStudyArea() || courseNameNotIsNextCourseName()) {
          list.add(_Grid(week, weekDay,start,  end, courseName, course.location, course.teacher, randomColors(), height));
        }
      } else {
        start = end;
      }
    } else {
      list.add(_Grid(week, weekDay, 0, end, "", "", "", defaultColor));
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
  final int week;
  final int weekDay;

  _Grid(this.week, this.weekDay, this.start, this.end, this.title, this.classroomNumber, this.teacher, this.color,
      [this.height = 60.0]);

  final TextStyle style = TextStyle(fontSize: 12, color: Colors.white);

  @override
  Widget build(BuildContext context) {
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
            showCourseInfoDialog(context, week, weekDay, start);
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

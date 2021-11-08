import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/data.dart';
import 'package:glutnnbox/widget/bars.dart';

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
      list.add(Expanded(
          child: Center(
              child: Text(
        "周${_weekDayList[i - 1]}",
        style: TextStyle(
            color:
                nowWeek ? (i == DateTime.now().weekday ? Colors.blue : Colors.grey) : Colors.grey),
      ))));
    }
  }
  return list;
}

Widget _leftGrid(String title) {
  return Container(
    width: 20,
    height: Global.schedulePageGridHeight,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
          top: BorderSide(
            width: 0.75, //宽度
            color: Color(0xfff9f9f9), //边框颜色
          ),
          right: BorderSide(
            width: 0.75, //宽度
            color: Color(0xfff9f9f9), //边框颜色
          )),
    ),
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Colors.blue),
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

class SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin {
  late double _startPositionX;
  late double _startPositionY;
  int _currentScheduleWeek = int.parse(writeData["week"]);
  GlobalKey<SchedulePageColumnState> weekKey = GlobalKey();
  GlobalKey<ScheduleTopBarState> barKey = GlobalKey();
  GlobalKey<RowHeaderState> rowHeaderKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _warning1() {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(jwSnackBar(false, "别翻了,已经没了...", 1));
  }

  void _touchListen(double eX, double eY) {
    double minValue = Global.schedulePageTouchMovesMinValue;
    double sX = _startPositionX;
    double sY = _startPositionY;
    if (eY - sY < minValue || eY + sY < minValue) {
      if (sX - eX > minValue) {
        if (_currentScheduleWeek == 20) {
          _warning1();
        } else {
          print("下一页");
          _currentScheduleWeek++;
          _findNewSchedule();
        }
      } else if (eX - sX > minValue) {
        if (_currentScheduleWeek == 1) {
          _warning1();
        } else {
          print("上一页");
          _currentScheduleWeek--;
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

  void reState() {
    if (writeData["week"] != _currentScheduleWeek.toString()) {
      _currentScheduleWeek = int.parse(writeData["week"]);
      weekKey.currentState!.onPressed(int.parse(writeData["week"]));
      barKey.currentState!.onPressed(int.parse(writeData["week"]));
      rowHeaderKey.currentState!.onPressed(int.parse(writeData["week"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Column(
        children: [
          InkWell(
            child: ScheduleTopBar(key: barKey),
            onTap: reState,
          ),
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

    if (courseName != "null") {
      if (i == 1) {
        // print(courseName + " start${i}");
        s = i;
      } else if (courseName == courseLongText2ShortName(_schedule[(i - 1).toString()][0])) {
        if (i == 11) {
          // print(courseName + " end${i}");
          list.add(_grid(
              courseName, studyArea, randomColors(), Global.schedulePageGridHeight * (i - s + 1)));
        } else if (courseName != courseLongText2ShortName(_schedule[(i + 1).toString()][0])) {
          // print(courseName + " end${i}");
          list.add(_grid(
              courseName, studyArea, randomColors(), Global.schedulePageGridHeight * (i - s + 1)));
        }
      } else {
        // print(courseName + " start${i}");
        s = i;
      }
    } else {
      list.add(_grid("", "", Colors.white));
    }
  }
  return list;
}

Widget _grid(String title, String studyArea, Color color, [double height = 60.0]) {
  TextStyle style = const TextStyle(fontSize: 12, color: Colors.white);
  return Container(
      height: height,
      color: color,
      padding: const EdgeInsets.only(left: 6, right: 6),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
          Text(
            studyArea,
            textAlign: TextAlign.center,
            softWrap: true,
            style: style,
          ),
        ],
      ));
}

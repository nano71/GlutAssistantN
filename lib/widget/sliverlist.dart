import 'package:flutter/material.dart';
import 'package:glutnnbox/common/io.dart';
import 'package:glutnnbox/get/get.dart';

import '../config.dart';

class ToDayCourse extends StatefulWidget {
  const ToDayCourse({Key? key}) : super(key: key);

  @override
  ToDayCourseList createState() => ToDayCourseList();
}

class TomorrowCourse extends StatefulWidget {
  const TomorrowCourse({Key? key}) : super(key: key);

  @override
  TomorrowCourseList createState() => TomorrowCourseList();
}

class ToDayCourseList extends State<ToDayCourse> {
  Map _schedule = {};
  var toDay = [];
  String _week = "1";
  final List _startTimeList = [
    [8, 40],
    [9, 25],
    [10, 25],
    [11, 10],
    [14, 30],
    [15, 15],
    [16, 05],
    [16, 50],
    [19, 30],
    [20, 15],
    [21, 00]
  ];
  final List _endTimeList = [
    [9, 20],
    [10, 20],
    [11, 05],
    [11, 50],
    [15, 55],
    [16, 45],
    [17, 30],
    [20, 10],
    [20, 55],
    [21, 40]
  ];

  @override
  void initState() {
    super.initState();
    _getSchedule();
  }

  void _getSchedule() async {
    _next(Map value) {
      if (value["message"] != "fail") {
        setState(() {
          _schedule = value;
        });
        _getWeek();
      } else {
        print(value["message"]);
      }
    }

    await readSchedule().then((Map value) => _next(value));
  }

  void _getWeek() async {
    await getWeek().then((int day) => setState(() => _week = day.toString()));
    _listInit();
  }

  _listInit() {
    _schedule[_week][DateTime.now().weekday.toString()].forEach((k, v) => {
          if (v[1] != null) {v.add(k), toDay.add(v)}
        });
    print(toDay.isNotEmpty);
    if (toDay.isNotEmpty) {
      setState(() {
        Global.todaySchedule = true;
      });
    } else {
      setState(() {
        Global.todaySchedule = false;
      });
    }
    _getStartTime(10);
  }

  List _getStartTime(index) {
    var startH = _startTimeList[index][0];
    var endH = _endTimeList[index][0];
    var startM = _startTimeList[index][1];
    var endM = _endTimeList[index][1];
    var y = DateTime.now().year;
    var m = DateTime.now().month;
    var d = DateTime.now().day;
    var h = DateTime.now().hour;
    var mm = DateTime.now().minute;
    DateTime d4 = DateTime(y, m, d, h, mm);
    DateTime d5 = DateTime(y, m, d, startH, startM);
    var difference = d5.difference(d4);
    int returnM =
        difference.inMinutes < 0 ? difference.inMinutes % 60 - 60 : difference.inMinutes % 60;
    List returnList = [difference.inDays, difference.inHours, returnM];
    bool studying = false;
    for (int i = 0; i < returnList.length; i++) {
      studying = returnList[i] < 0;
      if (returnList[0] == returnList[1] && returnList[0] == returnList[2]) studying = true;
    }
    if (studying) {
      var difference2 = DateTime(y, m, d, endH, endM).difference(DateTime(y, m, d, h, mm));
      return [difference2.inDays, difference2.inHours, difference2.inMinutes];
    } else {
      return returnList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
            margin: EdgeInsets.fromLTRB(24, 16, 24, 16),
            // height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(
                  Icons.attachment,
                  color: Colors.blue,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(toDay[index][2],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      Text(toDay[index][0],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              color: Color(0xff333333))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('第${toDay[index][3]}节 | ',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                      Text(toDay[index][1],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                    ],
                  ),
                ],
              ),
              const Text("",
                  style: TextStyle(
                      decoration: TextDecoration.none, fontSize: 12, color: Color(0xff333333))),
            ]));
      }, childCount: toDay.length),
    );
  }
}

class TomorrowCourseList extends State<TomorrowCourse> {
  Map _schedule = {};
  var tomorrow = [];
  String _week = "1";

  @override
  void initState() {
    super.initState();
    _getSchedule();
  }

  void _getSchedule() async {
    _next(Map value) {
      if (value["message"] != "fail") {
        setState(() {
          _schedule = value;
        });
        _getWeek();
      } else {
        print(value["message"]);
      }
    }

    await readSchedule().then((Map value) => _next(value));
  }

  void _getWeek() async {
    await getWeek().then((int day) => setState(() => _week = day.toString()));
    _listInit();
  }

  String _getWeekDay() {
    if (DateTime.now().weekday < 7) {
      return (DateTime.now().weekday + 1).toString();
    } else {
      return "1";
    }
  }

  _listInit() {
    _schedule[_week][_getWeekDay()].forEach((k, v) => {
          if (v[1] != null) {v.add(k), tomorrow.add(v)}
        });
    print(tomorrow.isNotEmpty);
    if (tomorrow.isNotEmpty) {
      setState(() {
        Global.tomorrowSchedule = true;
      });
    } else {
      setState(() {
        Global.tomorrowSchedule = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(tomorrow[index][2],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      Text(tomorrow[index][0],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              color: Color(0xff333333))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('第${tomorrow[index][3]}节' '|',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                      Text(tomorrow[index][1],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                    ],
                  ),
                ],
              ),
              const Text("还有10分钟",
                  style: TextStyle(
                      decoration: TextDecoration.none, fontSize: 12, color: Color(0xff333333))),
            ]));
      }, childCount: tomorrow.length),
    );
  }
}

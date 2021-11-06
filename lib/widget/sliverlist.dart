import 'package:flutter/material.dart';

import '../data.dart';

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
    [15, 10],
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
    var difference = DateTime(y, m, d, startH, startM).difference(DateTime(y, m, d, h, mm));
    var difference2 = DateTime(y, m, d, endH, endM).difference(DateTime(y, m, d, h, mm));
    bool studying = false;
    List returnList = [
      difference.inDays,
      difference.inHours,
      difference.inMinutes < 0 ? difference.inMinutes % 60 - 60 : difference.inMinutes % 60
    ];
    for (int i = 0; i < returnList.length; i++) {
      studying = returnList[i] < 0;
      if (returnList[0] == returnList[1] && returnList[0] == returnList[2]) studying = true;
    }
    if (studying) {
      return [
        difference2.inDays,
        difference2.inHours,
        difference2.inMinutes < 0 ? difference2.inMinutes % 60 - 60 : difference2.inMinutes % 60,
        "after"
      ];
    } else {
      returnList.add("before");
      return returnList;
    }
  }

  IconData _icon(result) {
    if (result == "before") {
      return Icons.attachment;
    } else {
      return Icons.check;
    }
  }

  String _timeText(List value) {
    if (value[0] >= 1) {
      return "";
    } else if (value[1] >= 4) {
      return "";
    } else if (value[1] >= 1) {
      return "还有${value[1]}小时";
    } else {
      return "${value[2]}分钟后";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
            margin: EdgeInsets.fromLTRB(24, 16, 24, 16),
            // height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      _icon(_getStartTime(int.parse(todaySchedule[index][3]))[3]),
                      color: Colors.blue,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(todaySchedule[index][2],
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 14,
                                  color: Color(0xff333333))),
                          Text(todaySchedule[index][0],
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: Color(0xff333333))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${todaySchedule[index][3]}节 | ',
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: Color(0xff999999))),
                          Text(todaySchedule[index][1],
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: Color(0xff999999))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(_timeText(_getStartTime(int.parse(todaySchedule[index][3]))),
                        style: const TextStyle(
                            decoration: TextDecoration.none, fontSize: 14, color: Colors.red)),
                  )
                ],
              ),
            ]));
      }, childCount: todaySchedule.length),
    );
  }
}

class TomorrowCourseList extends State<TomorrowCourse> {
  @override
  void initState() {
    super.initState();
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
                      Text(tomorrowSchedule[index][2],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      Text(tomorrowSchedule[index][0],
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              color: Color(0xff333333))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('第${tomorrowSchedule[index][3]}节' '|',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                      Text(tomorrowSchedule[index][1],
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
      }, childCount: tomorrowSchedule.length),
    );
  }
}

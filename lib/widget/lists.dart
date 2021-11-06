import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';

String _courseText(String value) {
  if (value.contains("毛泽东思想和中国特色社会主义理论体系概论")) {
    return value.replaceAll("毛泽东思想和中国特色社会主义理论体系概论", "毛概");
  }

  return value;
}

List _getStartTime(index) {
  var startH = startTimeList[index][0];
  var endH = endTimeList[index][0];
  var startM = startTimeList[index][1];
  var endM = endTimeList[index][1];
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

String _timeText(int index) {
  List value = _getStartTime(int.parse(todaySchedule[index][3]));
  if (value[0] >= 1) {
    return "";
  } else if (value[1] >= 4) {
    return "";
  } else if (value[1] >= 1) {
    if (value[2] == 0) return "${value[1]}小时后";
    return "${value[1]}小时${value[2]}分后";
  } else if (value[3] == "after") {
    return "已结束";
  } else {
    return "${value[2]}分钟后";
  }
}

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
  @override
  void initState() {
    super.initState();
  }

  IconData _icon(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return Icons.attachment;
    } else {
      return Icons.check;
    }
  }

  Color _timeColors(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return Colors.blue;
    } else {
      return Colors.black26;
    }
  }

  Color _textColorsTop(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return const Color(0xff333333);
    } else {
      return Colors.black26;
    }
  }

  Color _textColorsDown(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return const Color(0xff999999);
    } else {
      return Colors.black26;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            // height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      _icon(index),
                      color: _timeColors(index),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(todaySchedule[index][2] + " ",
                              style: TextStyle(
                                  decoration: TextDecoration.none, color: _textColorsTop(index))),
                          Text(_courseText(todaySchedule[index][0]),
                              style: TextStyle(
                                  decoration: TextDecoration.none, color: _textColorsTop(index))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${todaySchedule[index][3]}节 | ',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: _textColorsDown(index))),
                          Text(todaySchedule[index][1],
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: _textColorsDown(index))),
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
                      child: Text(
                        _timeText(index),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            color: _timeColors(index)),
                      ))
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
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.attachment,
                      color: (tomorrowSchedule[index][3] == "1" && index == 0
                          ? Colors.orange[900]
                          : Colors.blue),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tomorrowSchedule[index][2] + " ",
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 14,
                                  color: Color(0xff333333))),
                          Text(_courseText(tomorrowSchedule[index][0]),
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: Color(0xff333333))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${tomorrowSchedule[index][3]}节 | ',
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
                ],
              ),
              Stack(alignment: Alignment.centerRight, children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text((tomorrowSchedule[index][3] == "1" && index == 0 ? "别睡懒觉😅" : ""),
                      style: TextStyle(fontSize: 14, color: Colors.orange[900])),
                )
              ]),
            ]));
      }, childCount: tomorrowSchedule.length),
    );
  }
}

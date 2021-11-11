import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data.dart';

List _getStartTime(index) {
  var startH = startTimeList[index - 1][0];
  var endH = endTimeList[index - 1][0];
  var startM = startTimeList[index - 1][1];
  var endM = endTimeList[index - 1][1];
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
  if (index == -1) return "-1";
  List value = _getStartTime(int.parse(todaySchedule[index][3]));
  if (value[0] >= 1) {
    return "";
  } else if (value[1] >= 4) {
    return "";
  } else if (value[1] >= 1) {
    if (value[2] == 0) return "${value[1]}小时后";
    return "${value[1]}小时${value[2]}分后";
  } else if (value[3] == "after") {
    if (value[2] < 46 && value[2] > 0) {
      if (value[1] == 0.0) {
        return "${value[2]}分后下课";
      } else {
        return "已结束";
      }
    } else {
      return "已结束";
    }
  } else {
    return "${value[2]}分后上课";
  }
}

List<String> _timeText2(int index) {
  if (index == -1) return ["0", "0"];
  List value = _getStartTime(int.parse(todaySchedule[index][3]));
  if (value[0] >= 1) {
    return ["0", "0"];
  } else if (value[1] >= 4) {
    return ["0", "0"];
  } else if (value[1] >= 1) {
    if (value[2] == 0) return [value[1].toString(), "0"];
    return [value[1].toString(), value[2].toString()];
  } else if (value[3] == "after") {
    if (value[2] < 46 && value[2] > 0) {
      if (value[1] == 0.0) {
        return ["0", value[2].toString()];
      } else {
        return ["0", "0"];
      }
    } else {
      return ["0", "0"];
    }
  } else {
    return ["0", value[2].toString()];
  }
}

class TodayCourseList extends StatefulWidget {
  const TodayCourseList({Key? key}) : super(key: key);

  @override
  TodayCourseListState createState() => TodayCourseListState();
}

class TomorrowCourseList extends StatefulWidget {
  const TomorrowCourseList({Key? key}) : super(key: key);

  @override
  TomorrowCourseListState createState() => TomorrowCourseListState();
}

GlobalKey<TodayCourseListState> todayCourseListKey = GlobalKey();
GlobalKey<TomorrowCourseListState> tomorrowCourseListKey = GlobalKey();

class TodayCourseListState extends State<TodayCourseList> {
  List _todaySchedule = todaySchedule;
  late StreamSubscription<ReTodayListState> eventBusFn;

  @override
  void initState() {
    super.initState();

    eventBusFn = pageBus.on<ReTodayListState>().listen((event) {
      reSate();
    });
  }

  reSate() {
    setState(() {
      _todaySchedule = todaySchedule;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return TodayCourseListItem(index: index);
      }, childCount: _todaySchedule.length),
    );
  }
}

class TodayCourseListItem extends StatefulWidget {
  final int index;

  const TodayCourseListItem({Key? key, this.index = -1}) : super(key: key);

  @override
  TodayCourseListItemState createState() => TodayCourseListItemState();
}

class TodayCourseListItemState extends State<TodayCourseListItem> {
  late Timer _timer;
  bool timerS = false;

  void timerRe(int index) {
    if (!timerS) {
      timerS = true;
      Future.delayed(const Duration(seconds: 1), () {
        List<String> list = _timeText2(index);
        if (list[0] != "0" || list[1] != "0") {
          print("$index : ${DateTime.now().second}");
          setState(() {});
        }
      });
    }
    // if (!timerS) {
    //   timerS = true;
    //
    //
    //
    //   List<String> list = _timeText2(index);
    //   if (list[0] != "0" || list[1] != "0") {
    //     _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //       print("$index : ${DateTime.now().second}");
    //       list = _timeText2(index);
    //       if (list[0] == "0" && list[1] == "0") {
    //         _timer.cancel();
    //       }
    //       setState(() {});
    //     });
    //   } else {
    //     print("已结束");
    //   }
    // }
  }

  IconData _icon(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return Icons.access_time;
    } else {
      if (_timeText(index).contains("下课")) {
        return Icons.menu_book;
      } else {
        return Icons.check;
      }
    }
  }

  Color _timeColors(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return Colors.blue;
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  Color _textColorsTop(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return const Color(0xff333333);
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  Color _textColorsDown(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][3]))[3];
    if (result == "before") {
      return const Color(0xff999999);
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    timerRe(widget.index);
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        // height: 50,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(
                  _icon(widget.index),
                  color: _timeColors(widget.index),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(todaySchedule[widget.index][2] + " ",
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: _textColorsTop(widget.index))),
                      Text(courseLongText2ShortName(todaySchedule[widget.index][0]),
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: _textColorsTop(widget.index))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('第${todaySchedule[widget.index][3]}节 | ',
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: _textColorsDown(widget.index))),
                      Text(todaySchedule[widget.index][1],
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: _textColorsDown(widget.index))),
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
                    (_timeText(widget.index - 1).contains("后") ? "" : _timeText(widget.index)),
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        color: _timeColors(widget.index)),
                  ))
            ],
          ),
        ]));
  }
}

class TomorrowCourseListState extends State<TomorrowCourseList> {
  List _tomorrowSchedule = tomorrowSchedule;
  late StreamSubscription<ReTomorrowListState> eventBusFn;

  @override
  void initState() {
    super.initState();

    eventBusFn = pageBus.on<ReTomorrowListState>().listen((event) {
      reSate();
    });
  }

  reSate() {
    setState(() {
      print(2);
      _tomorrowSchedule = tomorrowSchedule;
    });
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
                      color: (_tomorrowSchedule[index][3] == "1" && index == 0
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
                          Text(_tomorrowSchedule[index][2] + " ",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 14,
                                  color: (_tomorrowSchedule[index][3] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff333333)))),
                          Text(courseLongText2ShortName(_tomorrowSchedule[index][0]),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: (_tomorrowSchedule[index][3] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff333333)))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${_tomorrowSchedule[index][3]}节 | ',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][3] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff999999)))),
                          Text(_tomorrowSchedule[index][1],
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][3] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff999999)))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Stack(alignment: Alignment.centerRight, children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text((_tomorrowSchedule[index][3] == "1" && index == 0 ? "别睡懒觉😅" : ""),
                      style: TextStyle(fontSize: 14, color: Colors.orange[900])),
                )
              ]),
            ]));
      }, childCount: _tomorrowSchedule.length),
    );
  }
}

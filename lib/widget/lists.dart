import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/config.dart';

import '../data.dart';

GlobalKey<TodayCourseListState> todayCourseListKey = GlobalKey();
GlobalKey<TomorrowCourseListState> tomorrowCourseListKey = GlobalKey();

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
  List value = _getStartTime(int.parse(todaySchedule[index][4]));
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

// List<String> _timeText2(int index) {
//   if (index == -1) return ["0", "0"];
//   List value = _getStartTime(int.parse(todaySchedule[index][4]));
//   if (value[0] >= 1) {
//     return ["0", "0"];
//   } else if (value[1] >= 4) {
//     return ["0", "0"];
//   } else if (value[1] >= 1) {
//     if (value[2] == 0) return [value[1].toString(), "0"];
//     return [value[1].toString(), value[2].toString()];
//   } else if (value[3] == "after") {
//     if (value[2] < 46 && value[2] > 0) {
//       if (value[1] == 0.0) {
//         return ["0", value[2].toString()];
//       } else {
//         return ["0", "0"];
//       }
//     } else {
//       return ["0", "0"];
//     }
//   } else {
//     return ["0", value[2].toString()];
//   }
// }

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

class TodayCourseListState extends State<TodayCourseList> {
  List _todaySchedule = todaySchedule;
  late StreamSubscription<ReTodayListState> eventBusFn;

  @override
  void initState() {
    super.initState();

    eventBusFn = pageBus.on<ReTodayListState>().listen((event) {
      reSate();
    });
    print(_todaySchedule);
  }

  reSate() {
    setState(() {
      _todaySchedule = todaySchedule;
    });
  }

  @override
  void dispose() {
    eventBusFn.cancel();
    super.dispose();
  }

  bool timerS = false;
  int sum = 0;

  timerRe(int index) {
    // print("timerRe");
    if (!timerS && index == 0) {
      timerS = !timerS;
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (DateTime.now().second < 2) {
            sum++;
            if (writeData["threshold"] != "-1") if (sum > (int.parse(writeData["threshold"]) * 2))
              exit(0);
            print("$index : ${DateTime.now().second}");
            setState(() {
              timerS = !timerS;
            });
          } else {
            // print("timerRe End ${DateTime.now().second}");

            timerS = !timerS;
            timerRe(0);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        timerRe(index);
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
  IconData _icon(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][4]))[3];
    if (result == "before") {
      return FlutterRemix.timer_2_line;
    } else {
      if (_timeText(index).contains("下课")) {
        return FlutterRemix.quill_pen_line;
      } else {
        return FlutterRemix.check_line;
      }
    }
  }

  Color _timeColors(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][4]))[3];
    if (result == "before") {
      return readColor();
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  Color _textColorsTop(int index) {
    String result = _getStartTime(int.parse(todaySchedule[index][4]))[3];
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
    String result = _getStartTime(int.parse(todaySchedule[index][4]))[3];
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(
                  _icon(widget.index),
                  color: _timeColors(widget.index),
                  size: Global.listLeftIconSize,
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
                      Text('第${todaySchedule[widget.index][4]}节 | ',
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
                ),
              )
            ],
          ),
        ],
      ),
    );
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
    // print(_tomorrowSchedule[1]);
  }

  reSate() {
    setState(() {
      _tomorrowSchedule = tomorrowSchedule;
    });
  }

  @override
  void dispose() {
    eventBusFn.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
          padding: _tomorrowSchedule[index][3] == "1" && index == 0
              ? const EdgeInsets.fromLTRB(16, 0, 16, 4)
              : const EdgeInsets.fromLTRB(16, 0, 16, 0),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      // FlutterRemix.time_line,
                      Icons.hourglass_top_outlined,
                      color: (_tomorrowSchedule[index][4] == "1" && index == 0
                          ? Colors.orange[900]
                          : readColor()),
                      size: Global.listLeftIconSize,
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
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff333333)))),
                          Text(courseLongText2ShortName(_tomorrowSchedule[index][0]),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff333333)))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${_tomorrowSchedule[index][4]}节 | ',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff999999)))),
                          Text(_tomorrowSchedule[index][1],
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0
                                      ? Colors.orange[900]
                                      : const Color(0xff999999)))),
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
                    child: Text((_tomorrowSchedule[index][4] == "1" && index == 0 ? "别睡懒觉哦" : ""),
                        style: TextStyle(fontSize: 14, color: Colors.orange[900])),
                  ),
                ],
              ),
            ],
          ),
        );
      }, childCount: _tomorrowSchedule.length),
    );
  }
}

class ScoreList extends StatefulWidget {
  ScoreListState createState() => ScoreListState();
}

class ScoreListState extends State<ScoreList> {
  @override
  Widget build(BuildContext context) {
    if (queryScore.length == 1) {
      if (queryScore[0] == Global.socketError ||
          queryScore[0] == Global.timeOutError ||
          queryScore[0] == "登录过期") {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {},
          ),
        );
      }
    }
    if (queryScore.length == 0) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Container(
            color: Colors.white,
            height: 500,
          );
        }, childCount: 1),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 0, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0, color: Colors.white),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //科目
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 60 - 32,
                            child: Text(
                              queryScore[index][2],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            child: Text(
                              queryScore[index][3] == "" ? "慕课成绩不会被统计" : queryScore[index][3],
                              style: TextStyle(color: Colors.black45, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //成绩
                  Container(
                    width: 60,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                      // color: Global.homeCardsColor,
                      color: queryScore[index][4] == "不及格" ? Colors.red : randomColors(),
                    ),
                    child: Column(children: [
                      Text(
                          // "不及格",
                          queryScore[index][4],
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text(queryScore[index][5],
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
              child: Container(
                color: Color(0xfffafafa),
                height: 1,
              ),
            )
          ],
        );
      }, childCount: queryScore.length),
    );
  }
}

class ExamList extends StatefulWidget {
  ExamListState createState() => ExamListState();
}

class ExamListState extends State<ExamList> {
  _getColor(int index) {
    if (examListC[index]) {
      return Colors.grey;
    }
    return readColor();
  }

  _getColor2(int index) {
    if (examListC[index]) {
      return Colors.grey;
    }
    return Colors.black;
  }

  _getIcon(int index) {
    if (examListC[index]) {
      return FlutterRemix.check_line;
    }
    return FlutterRemix.timer_line;
  }

  @override
  Widget build(BuildContext context) {
    if (examList.length == 0) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Container(
            color: Colors.white,
            height: 500,
          );
        }, childCount: 1),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0, color: Colors.white),
          ),
          padding: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 0, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            _getIcon(index),
                            color: _getColor(index),
                            size: Global.listLeftIconSize,
                          )
                        ],
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseLongText2ShortName(examList[index][0]),
                            style: TextStyle(fontSize: 16, color: _getColor2(index)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            examList[index][1],
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    examList[index][2],
                    style: TextStyle(color: Colors.black45),
                  ),
                  // Text(examList[index][3]),
                ],
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
                child: Container(
                  color: Color(0xfffafafa),
                  height: 1,
                ),
              )
            ],
          ),
        );
      }, childCount: examList.length),
    );
  }
}

class ClassroomList extends StatefulWidget {
  ClassroomListState createState() => ClassroomListState();
}

class ClassroomListState extends State<ClassroomList> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {}, childCount: 0));
  }
}

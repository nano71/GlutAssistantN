import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '/config.dart';
import '../data.dart';
import 'bars.dart';

/// ```dart
/// 差多少天, 差多少小时, 差多少分, 是否已发生
/// ```
/// 获取第几节课还有多久上课的函数
/// 时间间隔
List timeUntilNextClass(dynamic index) {
  if (index is String) index = int.parse(index);
  var startHour = startTimeList[index - 1][0];
  var endHour = endTimeList[index - 1][0];
  var startMinute = startTimeList[index - 1][1];
  var endMinute = endTimeList[index - 1][1];
  var year = DateTime.now().year;
  var month = DateTime.now().month;
  var day = DateTime.now().day;
  var hour = DateTime.now().hour;
  var minute = DateTime.now().minute;
  var startTimeDifference = DateTime(year, month, day, startHour, startMinute).difference(DateTime(year, month, day, hour, minute));
  var endTimeDifference = DateTime(year, month, day, endHour, endMinute).difference(DateTime(year, month, day, hour, minute));
  bool studying = false;
  List returnList = [
    startTimeDifference.inDays,
    startTimeDifference.inHours,
    startTimeDifference.inMinutes < 0 ? startTimeDifference.inMinutes % 60 - 60 : startTimeDifference.inMinutes % 60
  ];
  for (int i = 0; i < returnList.length; i++) {
    studying = returnList[i] < 0;
    if (returnList[0] == returnList[1] && returnList[0] == returnList[2]) studying = true;
  }
  if (studying) {
    return [
      endTimeDifference.inDays,
      endTimeDifference.inHours,
      endTimeDifference.inMinutes < 0 ? endTimeDifference.inMinutes % 60 - 60 : endTimeDifference.inMinutes % 60,
      "after"
    ];
  } else {
    returnList.add("before");
    return returnList;
  }
}

String _timeText(int index) {
  if (index == -1) return "-1";
  List value = timeUntilNextClass(AppData.todaySchedule[index][4]);
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
//   List value = _getStartTime(todaySchedule[index][4]));
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
  TodayCourseList({Key? key}) : super(key: key);

  @override
  TodayCourseListState createState() => TodayCourseListState();
}

class TomorrowCourseList extends StatefulWidget {
  TomorrowCourseList({Key? key}) : super(key: key);

  @override
  TomorrowCourseListState createState() => TomorrowCourseListState();
}

class TodayCourseListState extends State<TodayCourseList> {
  List _todaySchedule = AppData.todaySchedule;
  bool isTimerInit = false;
  int thresholdCount = 0;
  late StreamSubscription<ReloadTodayListState> eventBusListener;

  @override
  void initState() {
    super.initState();

    eventBusListener = eventBus.on<ReloadTodayListState>().listen((event) {
      reloadState();
    });
    // print(115);
    // print(_todaySchedule[0]);
  }

  void reloadState() {
    setState(() {
      _todaySchedule = AppData.todaySchedule;
    });
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  //  刷新定时器
  void refreshTimer(int index) {
    void next() {
      isTimerInit = false;
      if (DateTime.now().second < 2) {
        thresholdCount++;
        if (AppData.isReleaseMode && AppData.persistentData["threshold"] != "-1") if (thresholdCount > (int.parse(AppData.persistentData["threshold"] ?? "") * 2)) exit(0);
        print("$index : ${DateTime.now().second}");
        setState(() {});
      } else {
        // print("timerRe End ${DateTime.now().second}");
        refreshTimer(0);
      }
    }

    if (!isTimerInit && index == 0) {
      isTimerInit = true;
      Future.delayed(
        Duration(seconds: 1),
        () => next(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        refreshTimer(index);
        return TodayCourseListItem(index: index);
      }, childCount: _todaySchedule.length),
    );
  }
}

class TodayCourseListItem extends StatefulWidget {
  final int index;

  TodayCourseListItem({Key? key, this.index = -1}) : super(key: key);

  @override
  TodayCourseListItemState createState() => TodayCourseListItemState();
}

class TodayCourseListItemState extends State<TodayCourseListItem> {
  IconData _icon(int index) {
    String result = timeUntilNextClass(AppData.todaySchedule[index][4])[3];
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
    String result = timeUntilNextClass(AppData.todaySchedule[index][4])[3];
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
    String result = timeUntilNextClass(AppData.todaySchedule[index][4])[3];
    if (result == "before") {
      return Color(0xff333333);
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  Color _textColorsDown(int index) {
    String result = timeUntilNextClass(AppData.todaySchedule[index][4])[3];
    if (result == "before") {
      return Color(0xff999999);
    } else {
      if (_timeText(index).contains("下课")) {
        return Colors.teal;
      } else {
        return Colors.black26;
      }
    }
  }

  List courseInfo() {
    return AppData.todaySchedule[widget.index];
  }

  TextStyle smallTextStyle() {
    return TextStyle(decoration: TextDecoration.none, fontSize: 12, color: _textColorsDown(widget.index));
  }

  TextStyle normTextStyle() {
    return TextStyle(decoration: TextDecoration.none, color: _textColorsTop(widget.index));
  }

  String timePreprocessor(String time) {
    List<String> parts = time.split(':');
    if (parts.length == 2) {
      String hour = parts[0];
      String minute = parts[1];

      int hourInt = int.parse(hour);
      int minuteInt = int.parse(minute);

      String formattedHour = hourInt < 10 ? "0$hourInt" : hour;
      String formattedMinute = minuteInt < 10 ? "0$minuteInt" : minute;

      String result = "$formattedHour:$formattedMinute";
      return result;
    } else {
      return time;
    }
  }

  bool isShowLessonTimeInList() {
    return AppData.persistentData["showLessonTimeInList"] == "1";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(
                  _icon(widget.index),
                  color: _timeColors(widget.index),
                  size: AppConfig.listLeftIconSize,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text((courseInfo()[2] + " ").replaceAll("未知 ", ""), style: normTextStyle()),
                      Text(courseLongText2Short(courseInfo()[0]), style: normTextStyle()),
                    ],
                  ),
                  Row(
                    children: [
                      Text('第${courseInfo()[4]}节', style: smallTextStyle()),
                      Baseline(baseline: 12, baselineType: TextBaseline.ideographic, child: Text(" | ", style: smallTextStyle())),
                      isShowLessonTimeInList()
                          ? Baseline(
                              baseline: 13,
                              baselineType: TextBaseline.ideographic,
                              child: Text(
                                  ('${timePreprocessor(startTimeList[int.parse(courseInfo()[4]) - 1].join(":"))} - ${timePreprocessor(endTimeList[int.parse(courseInfo()[4]) - 1].join(":"))}'),
                                  style: smallTextStyle()))
                          : Container(),
                      isShowLessonTimeInList() ? Baseline(baseline: 12, baselineType: TextBaseline.ideographic, child: Text(" | ", style: smallTextStyle())) : Container(),
                      Text(courseInfo()[1], style: smallTextStyle()),
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
                  style: TextStyle(decoration: TextDecoration.none, fontSize: 14, color: _timeColors(widget.index)),
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
  List _tomorrowSchedule = AppData.tomorrowSchedule;
  late StreamSubscription<ReloadTomorrowListState> eventBusListener;

  @override
  void initState() {
    super.initState();

    eventBusListener = eventBus.on<ReloadTomorrowListState>().listen((event) {
      reloadState();
    });
    // print(_tomorrowSchedule[1]);
  }

  reloadState() {
    setState(() {
      _tomorrowSchedule = AppData.tomorrowSchedule;
    });
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
          padding: _tomorrowSchedule[index][3] == "1" && index == 0 ? EdgeInsets.fromLTRB(16, 0, 16, 4) : EdgeInsets.fromLTRB(16, 0, 16, 0),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
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
                    margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      // FlutterRemix.time_line,
                      Icons.hourglass_top_outlined,
                      color: (_tomorrowSchedule[index][4] == "1" && index == 0 ? Colors.orange[900] : readColor()),
                      size: AppConfig.listLeftIconSize,
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
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0 ? Colors.orange[900] : Color(0xff333333)))),
                          Text(courseLongText2Short(_tomorrowSchedule[index][0]),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0 ? Colors.orange[900] : Color(0xff333333)))),
                        ],
                      ),
                      Row(
                        children: [
                          Text('第${_tomorrowSchedule[index][4]}节 | ',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0 ? Colors.orange[900] : Color(0xff999999)))),
                          Text(_tomorrowSchedule[index][1],
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 12,
                                  color: (_tomorrowSchedule[index][4] == "1" && index == 0 ? Colors.orange[900] : Color(0xff999999)))),
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
                    child: Text((_tomorrowSchedule[index][4] == "1" && index == 0 ? "别睡懒觉哦" : ""), style: TextStyle(fontSize: 14, color: Colors.orange[900])),
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
      if (queryScore[0] == AppConfig.socketError || queryScore[0] == AppConfig.timeOutError || queryScore[0] == "登录过期") {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return null;
            },
          ),
        );
      }
    }
    if (queryScore.isEmpty) {
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
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      // color: Global.homeCardsColor,
                      color: queryScore[index][4] == "不及格" ? Colors.red : randomColors(),
                    ),
                    child: Column(children: [
                      Text(
                          // "不及格",
                          queryScore[index][4],
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text(queryScore[index][5], style: TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(36, 16, 36, 16),
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
    if (examList.isEmpty) {
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
                            size: AppConfig.listLeftIconSize,
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
                            courseLongText2Short(examList[index][0]),
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
                padding: EdgeInsets.fromLTRB(36, 16, 36, 16),
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
  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadClassroomListState> eventBusListener;
  List<Map> _classroomList = classroomList;

  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusListener = eventBus.on<ReloadClassroomListState>().listen((event) {
      print("reloadState");
      setState(() {
        _classroomList = classroomList;
      });
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
    });
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  static String promptMessage(List<bool> boolList) {
    String message = "第";
    int j = 0;
    for (int i = 0; i < boolList.length; i++) {
      if (boolList[i]) {
        message += "${i + 1} , ";
        j++;
      }
    }
    if (j == 0) {
      message = "该教室全天为空";
    } else if (j == 11) {
      message = "该教室全天满课状态";
    } else {
      message = message.substring(0, message.length - 3);
      message += "节被占用";
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      Map item = _classroomList[index];
      // print(632);
      // print(item);
      return ClassroomListItem(item);
    }, childCount: _classroomList.length));
  }
}

class ClassroomListItem extends StatelessWidget {
  late final Map item;

  ClassroomListItem([item]) {
    this.item = item;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        color: item["todayEmpty"] ? Colors.grey : randomColors2(),
      ),
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: Row(
                  children: [
                    Text(
                      item["classroom"],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Icon(
                      FlutterRemix.arrow_right_s_line,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "敬请期待!"));
                },
              ),
              Text(
                item["type"],
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Text(
                "座位容量: " + item["seats"],
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                "考试容量: " + item["examSeats"],
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: readColorBegin(),
            ),
            padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
            margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["todayEmpty"] ? "占用情况 - 全天为空" : "占用情况",
                      style: TextStyle(color: Colors.white),
                    ),
                    InkWell(
                      child: Icon(
                        FlutterRemix.information_line,
                        color: Colors.white,
                        size: 18,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, ClassroomListState.promptMessage(item["occupancyList"]), 4, 22));
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: occupancyList(item["occupancyList"]),
                ),
                Row(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> occupancyList(List<bool> boolList) {
  List<Widget> list = [];
  for (int i = 0; i < boolList.length; i++) {
    String text = (i + 1).toString();
    list.add(Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: boolList[i] ? Colors.white : readColorBegin(), fontSize: 12),
      ),
    ));
  }
  return list;
}

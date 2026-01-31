import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '/common/get.dart';
import '/common/style.dart';
import '/custom/expansiontile.dart' as CustomExpansionTile;
import '/widget/bars.dart';
import '/widget/dialog.dart';
import '../config.dart';
import '../data.dart';

class CareerPage extends StatefulWidget {
  final int type;

  CareerPage({Key? key, this.type = 0}) : super(key: key);

  @override
  State<CareerPage> createState() => _CareerPageState(type: this.type);
}

class _CareerPageState extends State<CareerPage> {
  final int type;

  _CareerPageState({this.type = 0});

  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadCareerPageState> eventBusListener;
  GlobalKey<_DynamicCircularProgressBarState> indicatorKey = GlobalKey();
  GlobalKey<_DynamicProgressTextState> textKey = GlobalKey();
  int year = 0;
  int allYear = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
    print("type:");
    print(type);
    eventBusListener = eventBus.on<ReloadCareerPageState>().listen((event) {
      getData();
    });
  }

  getData() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "获取数据...", AppConfig.timeoutSecond * 2));
    getCareer().then(process);
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    _weekTimer?.cancel();

    super.dispose();
  }

  process(value) {
    if (value is String) {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, value, 4));
    } else {
      if (value) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "处理数据...", AppConfig.timeoutSecond));
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "数据已更新!", 1));
        totalExamCount = 0;
        totalCourseCount = 0;
        totalMajorCourseCount = 0;
        careerList.forEach((element) {
          if (element.contains("考试")) {
            totalExamCount++;
          }
          if (element.length > 3) {
            totalCourseCount++;
            if (element[5].contains("专业")) {
              totalMajorCourseCount++;
            }
          }
        });
        // Navigator.of(context).pop();

        _weekProgressAnimation();
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithAction(
          false,
          "需要验证",
          context,
          () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            eventBus.fire(ReloadCareerPageState());
            Navigator.pop(context);
          },
          duration: AppConfig.timeoutSecond,
        ));
      }
    }
  }

  Timer? _weekTimer;

  void _weekProgressAnimation() {
    double count = 0.0;
    const period = Duration(milliseconds: 10);
    final max = _weekProgressDouble();

    _weekTimer?.cancel();

    _weekTimer = Timer.periodic(period, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      count += 0.01;
      if (count > max) count = max;

      final indicatorState = indicatorKey.currentState;
      final textState = textKey.currentState;

      if (indicatorState == null || textState == null) {
        timer.cancel();
        return;
      }

      indicatorState.onPressed(count);
      textState.onPressed((count * 100).toInt());

      if (count >= max) {
        timer.cancel();
      }
    });
  }

  double _weekProgressDouble() {
    if (careerInfo[2] != "" && careerInfo[3] != "") {
      //年级
      year = int.parse(careerInfo[2].replaceAll("级", "").trim());
      // 全部学年

      allYear = int.parse(careerInfo[3].substring(careerInfo[3].toString().indexOf("年") - 1).replaceAll("年", ""));
      setState(() {});
    }
    print(year.toString() + "年9月开学," + (year + allYear).toString() + "年6月毕业");
    _next() {
      var d6 = new DateTime(year, 9);
      var d7 = new DateTime(year + allYear, 6);
      var d8 = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      var difference = d7.difference(d6);
      var difference2 = d8.difference(d6);
      var difference3 = d8.difference(d7);
      if (difference3.inDays > 1) return 1.00;
      return difference2.inDays / difference.inDays;
    }

    if (careerInfo[2] == "" && careerInfo[3] == "") return 0.0;
    return _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          TopNavigationBar(
            "我的大学生涯",
            InkWell(
              child: Icon(
                Remix.close_line,
                size: 24,
                color: readTextColor(),
              ),
              onTap: () {
                if (type == 0) {
                  Navigator.of(context).pop();
                } else if (type == 1) {
                  Navigator.of(context).pop(1);
                }
              },
            ),
            readBackgroundColor(),
            readTextColor(),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                // color: readCardColor(),
                gradient: readCardGradient(),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: Stack(
                          children: [
                            Align(
                              child: SizedBox(
                                //限制进度条的高度
                                height: 100,
                                //限制进度条的宽度
                                width: 100,
                                child: _DynamicCircularProgressBar(key: indicatorKey),
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _DynamicProgressText(key: textKey),
                                    Text("大学进程", style: TextStyle(color: Colors.white, fontSize: 12))
                                  ],
                                )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  totalCourseCount.toString() + "",
                                  style: TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w300),
                                ),
                                Text("全部课程", style: TextStyle(color: Colors.white)),
                                // Text("预估数量", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  totalMajorCourseCount.toString() + "",
                                  style: TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w300),
                                ),
                                Text("专业课程", style: TextStyle(color: Colors.white)),
                                // Text("预估数量", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5, //宽度
                          color: Colors.white60, //边框颜色
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("${careerCount[1]} 门", style: TextStyle(color: Colors.white)),
                          Text("成绩合格", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("${careerCount[0]} 门", style: TextStyle(color: Colors.white)),
                          Text("重修/补考", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("${careerCount[2]} 门", style: TextStyle(color: Colors.white)),
                          Text("成绩未知", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              return _AcademicYearList(index);
            }, childCount: allYear),
          ),
        ],
      ),
    );
  }
}

class _AcademicYearList extends StatefulWidget {
  final int index;

  _AcademicYearList(this.index, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AcademicYearListState(index);
}

class _AcademicYearListState extends State<_AcademicYearList> {
  bool _isExpanded = false;
  String title = "";
  final int index;
  final int startYear = int.parse(careerInfo[2].replaceAll("级", "").trim());

  _AcademicYearListState(this.index);

  @override
  initState() {
    super.initState();
  }

  String titleProcess() {
    // List chineseNumberCapitalization = ["一", "二", "三", "四", "五", "六", "七", "八"];
    //波浪号取整
    return " ${startYear + index} - ${startYear + 1 + index} 学年";
  }

  IconData iconProcess(index) {
    List<IconData> icons = [
      Icons.looks_one,
      Icons.looks_two,
      Icons.looks_3,
      Icons.looks_4,
    ];
    return icons[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: CustomExpansionTile.ExpansionTile(
        onExpansionChanged: (e) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        collapsedIconColor: Colors.black45,
        iconColor: readColor(),
        tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        title: Row(
          children: [
            Icon(
              _isExpanded ? Icons.school : iconProcess(index),
              color: _isExpanded ? readColor() : randomColors2(),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
              child: Text(
                titleProcess(),
                style: TextStyle(
                  fontSize: 16,
                  color: _isExpanded ? readColor() : readTextColor(),
                ),
              ),
            )
          ],
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    "课程列表 - 秋学期",
                    style: TextStyle(
                      color: readTextColor(),
                    ),
                  )
                ],
              ),
              TextButton(
                style: buttonStyle(),
                onPressed: () {
                  careerDialog(context, index, 1, startYear + index);
                },
                child: Text(
                  "view",
                  style: TextStyle(
                    color: readColor(),
                  ),
                ),
              )
            ],
          ),
          Container(
            color: readLineColor(),
            margin: EdgeInsets.fromLTRB(16, 4, 24, 4),
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    "课程列表 - 春学期",
                    style: TextStyle(
                      color: readTextColor(),
                    ),
                  )
                ],
              ),
              TextButton(
                style: buttonStyle(),
                onPressed: () {
                  careerDialog(context, index, 2, startYear + index + 1);
                },
                child: Text(
                  "view",
                  style: TextStyle(
                    color: readColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DynamicCircularProgressBar extends StatefulWidget {
  _DynamicCircularProgressBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DynamicCircularProgressBarState();
}

class _DynamicCircularProgressBarState extends State<_DynamicCircularProgressBar> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 4,
      value: _value,
      backgroundColor: Color.fromARGB(48, 255, 255, 255),
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void onPressed(double value) {
    setState(() => _value = value);
  }
}

class _DynamicProgressText extends StatefulWidget {
  _DynamicProgressText({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DynamicProgressTextState();
}

class _DynamicProgressTextState extends State<_DynamicProgressText> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Text((_value.toString() + "%"), style: TextStyle(color: Colors.white, fontSize: 20));
  }

  void onPressed(int value) {
    setState(() => _value = value);
  }
}

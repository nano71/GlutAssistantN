import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '/common/get.dart';
import '/pages/setting.dart';
import '/widget/bars.dart';
import '/widget/lists.dart';
import '../config.dart';
import '../data.dart';
import 'login.dart';

class QueryPage extends StatefulWidget {
  final String title;
  final int type;

  QueryPage({Key? key, this.title = "查询", this.type = 0}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: QueryBody(),
    );
  }
}

class QueryBody extends StatefulWidget {
  QueryBody({Key? key}) : super(key: key);

  @override
  State<QueryBody> createState() => _QueryBodyState();
}

class _QueryBodyState extends State<QueryBody> {
  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadScoreListState> eventBusListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusListener = eventBus.on<ReloadScoreListState>().listen((ReloadScoreListState event) async {
      await getScore().then(preprocess);
    });
  }

  void preprocess(value) {
    if (value is String) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    } else if (value is bool) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
        false,
        "需要验证",
        context,
        () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          eventBus.fire(ReloadScoreListState());
          Navigator.pop(context);
        },
        hideSnackBarSeconds: 10,
      ));
    } else if (value is List) {
      if (value.isEmpty) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "没有结果!", 5));
      } else {
        process(value);
      }
    }
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  process(List list) {
    queryScore = list;
    // 绩点
    double gradePointAverage = 0.0;
    double _avg = 0.0;
    double _weight = 0.0;
    double scoreSum = 0.0;
    //学分*成绩
    double weightScoreSum = 0.0;
    double gpaSum = 0.0;
    double credit = 0.0;
    int excluded = 0;
    for (int i = 0; i < list.length; i++) {
      int _score;
      try {
        _score = int.parse(levelToNumber(list[i]![4]));
      } catch (e) {
        break;
      }
      // 学分
      double _credit = double.parse(list[i]![5]);
      // 绩点
      double _gradePoint = double.parse(list[i]![6]);

      String _courseName = list[i]![2].toString();
      String _teacher = list[i]![3];
      if ((_courseName.contains("慕课") && _teacher == "") || isExcludedCourse(_courseName)) {
        excluded++;
      } else {
        if (list[i].length > 5) {
          print(list[i]);
          weightScoreSum += _score * _credit;
          credit += _credit;
          gpaSum += _gradePoint * _credit;
        }
        if (list[i].length > 4) {
          scoreSum += _score;
        }
      }
    }
    print(scoreSum);
    _avg = double.parse((scoreSum / (list.length - excluded)).toStringAsFixed(1));
    _weight = double.parse((weightScoreSum / credit).toStringAsFixed(1));
    gradePointAverage = double.parse((gpaSum / credit).toStringAsFixed(1));
    if (_avg.isNaN) _avg = 0.0;
    if (_weight.isNaN) _weight = 0.0;
    if (gradePointAverage.isNaN) gradePointAverage = 0.0;
    scores = [gradePointAverage, _avg, _weight];
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
    setState(() {});
  }

  void _query() async {
    // Global.cookie = {};
    print(AppData.persistentData["username"]);
    if (!isLoggedIn()) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
        false,
        AppConfig.notLoginError,
        context,
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        },
        hideSnackBarSeconds: 10,
        isDialogCallback: true,
      ));
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "查询中...", 10));
      await getScore().then(preprocess);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [readColor(), readColor(), Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent],
            stops: [0, .5, .50001, .6, .61, 1]),
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
              "成绩查询",
              InkWell(
                child: Icon(
                  FlutterRemix.close_line,
                  size: 24,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              readColor(),
              Colors.white,
              0),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: readColor(),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          DropdownButton(
                            enableFeedback: true,
                            icon: Icon(FlutterRemix.arrow_down_s_line),
                            iconSize: 16,
                            iconEnabledColor: Colors.white,
                            elevation: 0,
                            hint: SizedBox(
                              width: 40,
                              child: Text(
                                AppData.persistentData["queryYear"] ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            items: yearList(0),
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                AppData.persistentData["queryYear"] = value.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          DropdownButton(
                            enableFeedback: true,
                            icon: Icon(FlutterRemix.arrow_down_s_line),
                            iconSize: 16,
                            iconEnabledColor: Colors.white,
                            elevation: 0,
                            hint: SizedBox(
                              width: 40,
                              child: Text(
                                AppData.persistentData["querySemester"] ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            underline: Container(height: 0),
                            items: [
                              DropdownMenuItem(child: Text("全部"), value: "全部"),
                              DropdownMenuItem(child: Text("春"), value: "春"),
                              DropdownMenuItem(child: Text("秋"), value: "秋"),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                if (value != null) AppData.persistentData["querySemester"] = value;
                              });
                            },
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          _query();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            color: Color(0x1ff1f1f1),
                          ),
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            "查询",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "平均绩点: ${scores[0]}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "|",
                        style: TextStyle(color: readColor()),
                      ),
                      Text(
                        "算术平均分: ${scores[1]}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "|",
                        style: TextStyle(color: readColor()),
                      ),
                      Text(
                        "加权平均分: ${scores[2]}",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          ScoreList(),
        ],
      ),
    );
  }
}

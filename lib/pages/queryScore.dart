import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/dialog.dart';
import 'package:remixicon/remixicon.dart';

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
      backgroundColor: readBackgroundColor(),
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
    double gradePointSummary = 0.0;
    double scoreSummary = 0.0;
    double creditSummary = 0.0;

    int excluded = 0;

    for (int i = 0; i < list.length; i++) {
      int score;

      if (list[i]![9] == "免修") {
        list[i]![4] = "及格";
      }

      try {
        score = int.parse(levelToNumber(list[i]![4]));
      } catch (e) {
        break;
      }

      // 学分
      double credit = double.parse(list[i]![5]);
      // 绩点
      double gradePoint = double.parse(list[i]![6]);
      String courseName = list[i]![2].toString();
      String teacher = list[i]![3];
      String courseType = list[i]![7];
      String courseNumber = list[i]![8];

      if ((courseName.contains("慕课") && teacher == "")) {
        excluded++;
      } else {
        if (list[i].length > 5) {
          if (isContainCourse(courseNumber, courseType)) {
            print(list[i]);
            gradePointSummary += gradePoint * credit;
            creditSummary += credit;
          }
        }
        if (list[i].length > 4) {
          scoreSummary += score;
        }
      }
    }

    print(scoreSummary);

    double scoreAverage = double.parse((scoreSummary / (list.length - excluded)).toStringAsFixed(2));
    double gradePointAverage = double.parse((gradePointSummary / creditSummary).toStringAsFixed(2));

    if (gradePointAverage.isNaN) gradePointSummary = 0.0;
    if (scoreAverage.isNaN) scoreSummary = 0.0;

    scores = [gradePointAverage, scoreAverage];
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
    return CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBarWithInfoIcon(
              "成绩查询",
              InkWell(
                child: Icon(
                  Remix.close_line,
                  size: 24,
                  color: readTextColor(),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              () => infoDialog(context,
                  "2019级及以后的平均学分绩点计算方式:\n\n绩点 = ∑(课程学分 × 绩点) / ∑课程学分\n\n1.参与计算的课程仅为选课属性必修课和集中性实践教学环节, 体育等素质类必修课不参与学分绩点计算\n\n2.采用五级记分制的课程和集中性实践性教学环节、毕业设计(论文)成绩折算成百分制后再进行计算, 不及格为40分"),
              readListPageTopAreaBackgroundColor(),
              readTextColor(),
              0),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -1),
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: readListPageTopAreaBackgroundColor(),
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
                              icon: Icon(Remix.arrow_down_s_line),
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
                              icon: Icon(Remix.arrow_down_s_line),
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
                          style: TextStyle(color: Colors.transparent),
                        ),
                        Text(
                          "算术平均分: ${scores[1]}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "|",
                          style: TextStyle(color: Colors.transparent),
                        ),
                        Text(
                          "加权平均分: ${scores[1]}",
                          style: TextStyle(color: Colors.transparent),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          ScoreList(),
        ],
      );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glutassistantn/type/course.dart';
import 'package:glutassistantn/widget/dialog.dart';
import 'package:remixicon/remixicon.dart';

import '/common/get.dart';
import '/pages/setting.dart';
import '/widget/bars.dart';
import '/widget/lists.dart';
import '../config.dart';
import '../data.dart';
import 'login.dart';

class QueryScoresPage extends StatefulWidget {
  final String title;
  final int type;

  QueryScoresPage({Key? key, this.title = "查询", this.type = 0}) : super(key: key);

  @override
  State<QueryScoresPage> createState() => _QueryScoresPageState();
}

class _QueryScoresPageState extends State<QueryScoresPage> {
  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadScoreListState> eventBusListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusListener = eventBus.on<ReloadScoreListState>().listen((ReloadScoreListState event) async {
      await getScores().then(preprocess);
    });
  }

  void preprocess(value) {
    if (value is String) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, value, 4));
    }

    if (value is bool) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithAction(
        false,
        "需要验证",
        context,
        () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          eventBus.fire(ReloadScoreListState());
          Navigator.pop(context);
        },
        duration: 10,
      ));
    }

    if (value is List<CourseScore>) {
      if (value.isEmpty) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "没有结果!", 5));
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

  process(List<CourseScore> list) {
    courseScores = list;

    double totalGradePoint = 0.0;
    double totalScore = 0.0;
    double totalCredit = 0.0;
    int totalExcluded = 0;

    for (CourseScore courseScore in list) {
      if (courseScore.courseName.contains("慕课") && courseScore.teacher == "") {
        totalExcluded++;
      } else {
        if (isContainCourse(courseScore.courseCode, courseScore.courseCategory)) {
          totalGradePoint += courseScore.gradePoint * courseScore.credit;
          totalCredit += courseScore.credit;
        }
        totalScore += courseScore.score;
      }
    }
    double scoreAverage = double.parse((totalScore / (list.length - totalExcluded)).toStringAsFixed(2));
    double gradePointAverage = double.parse((totalGradePoint / totalCredit).toStringAsFixed(2));

    if (gradePointAverage.isNaN) totalGradePoint = 0.0;
    if (scoreAverage.isNaN) totalScore = 0.0;

    scores = [gradePointAverage, scoreAverage, 0.0];
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "数据已更新!", 1));
    setState(() {});
  }

  void getData() async {
    // Global.cookie = {};
    if (!AppData.isLoggedIn) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithAction(
        false,
        AppConfig.notLoggedInErrorMessage,
        context,
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        },
        duration: 10,
        isDialogCallback: true,
      ));
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "查询中...", 10));
      await getScores().then(preprocess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          TopNavigationBarWithTipIcon(
              "成绩查询",
              InkWell(
                child: Icon(
                  Remix.close_line,
                  size: 24,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              () => showInfoDialog(context,
                  "2019级及以后的平均学分绩点计算方式:\n\n绩点 = ∑(课程学分 × 绩点) / ∑课程学分\n\n1.参与计算的课程仅为选课属性必修课和集中性实践教学环节, 体育等素质类必修课不参与学分绩点计算\n\n2.采用五级记分制的课程和集中性实践性教学环节、毕业设计(论文)成绩折算成百分制后再进行计算, 不及格为40分"),
              readListPageTopAreaBackgroundColor(),
              Colors.white,
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
                                  AppData.queryYear,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              items: yearList(0),
                              underline: Container(height: 0),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    AppData.queryYear = value;
                                  });
                                }
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
                                  AppData.querySemester,
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
                                  if (value != null) {
                                    AppData.querySemester = value;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: getData,
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
      ),
    );
  }
}

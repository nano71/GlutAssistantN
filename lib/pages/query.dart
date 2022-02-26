import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/pages/setting.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../config.dart';
import '../data.dart';

class QueryPage extends StatefulWidget {
  final String title;
  final int type;

  const QueryPage({Key? key, this.title = "查询", this.type = 0}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: QueryBody());
  }
}

class QueryBody extends StatefulWidget {
  const QueryBody({Key? key}) : super(key: key);

  @override
  State<QueryBody> createState() => _QueryBodyState();
}

class _QueryBodyState extends State<QueryBody> {
  double _gpa = gpa;
  double _avg = avg;
  double _weight = weight;
  // ignore: cancel_subscriptions
  late StreamSubscription<QueryScoreRe> eventBusFn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusFn = pageBus.on<QueryScoreRe>().listen((event) async {
      _next(List list) {
        if (list.length == 0) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "没有结果!", 5));
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));

          queryScore = list;
          double sum = 0.0;
          double _q = 0.0;
          double _xf = 0.0;
          int no = 0;
          for (int i = 0; i < list.length; i++) {
            if (list[i][2].toString().contains("慕") && list[i][3] == "") {
              no++;
            } else {
              if (list[i].length > 5) {
                _q += (int.parse(levelToNumber(list[i]![4])) * double.parse(list[i]![5]));
                _xf += double.parse(levelToNumber(list[i][5]));
              }
              if (list[i].length > 4) {
                sum += int.parse(levelToNumber(list[i][4]));
              }
            }
          }
          _avg = double.parse((sum / (list.length - no)).toStringAsFixed(1));
          _weight = double.parse((_q / _xf).toStringAsFixed(1));

          if (_weight >= 90) {
            _gpa = 4.0;
          } else if (_weight >= 85) {
            _gpa = 3.7;
          } else if (_weight >= 82) {
            _gpa = 3.3;
          } else if (_weight >= 78) {
            _gpa = 3.0;
          } else if (_weight >= 75) {
            _gpa = 2.7;
          } else if (_weight >= 72) {
            _gpa = 2.3;
          } else if (_weight >= 68) {
            _gpa = 2.0;
          } else if (_weight >= 64) {
            _gpa = 1.5;
          } else if (_weight >= 60) {
            _gpa = 1.0;
          } else {}
          weight = _weight;
          gpa = _gpa;
          avg = _avg;
          setState(() {});
        }
      }

      await getScore().then((value) => _next(value));
    });
  }

  _query() async {
    // Global.cookie = {};

    _next(List list) {
      print(list);
      if (list.length == 1 && list[0] == "登录过期") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBarActionQ(
          false,
          "需要验证",
          context,
          10,
        ));
      } else if (list.length == 1 &&
          (list[0] == Global.socketError || list[0] == Global.timeOutError)) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, list[0], 4));
      } else if (list.length == 0) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "没有结果!", 5));
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
        queryScore = list;
        double sum = 0.0;
        double _q = 0.0;
        double _xf = 0.0;
        int no = 0;
        for (int i = 0; i < list.length; i++) {
          if (list[i][2].toString().contains("慕") && list[i][3] == "") {
            no++;
          } else {
            if (list[i].length > 5) {
              _q += (int.parse(levelToNumber(list[i]![4])) * double.parse(list[i]![5]));
              _xf += double.parse(levelToNumber(list[i][5]));
            }
            if (list[i].length > 4) {
              sum += int.parse(levelToNumber(list[i][4]));
            }
          }
        }
        _avg = double.parse((sum / (list.length - no)).toStringAsFixed(1));
        _weight = double.parse((_q / _xf).toStringAsFixed(1));
        if (_avg.isNaN) {
          _avg = 0.0;
        }
        if (_weight.isNaN) {
          _weight = 0.0;
        }
        if (_weight >= 90) {
          _gpa = 4.0;
        } else if (_weight >= 85) {
          _gpa = 3.7;
        } else if (_weight >= 82) {
          _gpa = 3.3;
        } else if (_weight >= 78) {
          _gpa = 3.0;
        } else if (_weight >= 75) {
          _gpa = 2.7;
        } else if (_weight >= 72) {
          _gpa = 2.3;
        } else if (_weight >= 68) {
          _gpa = 2.0;
        } else if (_weight >= 64) {
          _gpa = 1.5;
        } else if (_weight >= 60) {
          _gpa = 1.0;
        } else {}
        weight = _weight;
        gpa = _gpa;
        avg = _avg;

        setState(() {});
      }
    }

    print(writeData["username"]);
    if (writeData["username"] == "") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarActionL(
        false,
        "请先登录!",
        context,
        10,
      ));
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "查询中...", 10));
      await getScore().then((value) => _next(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      // color: readColor(),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [readColor(),readColor(),Colors.transparent,Colors.transparent,Colors.transparent,Colors.transparent],
            stops: [0,.5,.50001,.6,.61,1]
        ),
      ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
              "成绩查询",
              InkWell(
                child: const Icon(
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: readColor(),
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          DropdownButton(
                            iconEnabledColor: Colors.white,
                            elevation: 0,
                            hint: Text(
                              writeData["queryYear"],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            items: yearList(0),
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                writeData["queryYear"] = value;
                              });
                            },
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          DropdownButton(
                            iconEnabledColor: Colors.white,
                            isDense: true,
                            elevation: 0,
                            hint: Text(writeData["querySemester"],
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                            underline: Container(height: 0),
                            items: const [
                              DropdownMenuItem(child: Text("全部"), value: "全部"),
                              DropdownMenuItem(child: Text("春"), value: "春"),
                              DropdownMenuItem(child: Text("秋"), value: "秋"),
                            ],
                            onChanged: (value) {
                              setState(() {
                                writeData["querySemester"] = value;
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
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            color: Color(0x1ff1f1f1),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        "GPA绩点: $_gpa",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "|",
                        style: TextStyle(color: readColor()),
                      ),
                      Text(
                        "算术平均分: $_avg",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "|",
                        style: TextStyle(color: readColor()),
                      ),
                      Text(
                        "加权平均分: $_weight",
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

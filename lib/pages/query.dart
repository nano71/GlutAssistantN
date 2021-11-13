import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/pages/setting.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../config.dart';
import '../data.dart';

class QueryPage extends StatefulWidget {
  final String title;

  const QueryPage({Key? key, this.title = "查询"}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  double _gpa = gpa;
  double _avg = avg;
  double _weight = weight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _query(BuildContext context) async {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(jwSnackBar(true, "查询中...", 10));
    _next(List list) {
      if (list.length == 1 && list[0] == "登录过期") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBarActionQ(
          false,
          "需要验证",
          context,
          10,
        ));
      } else if (list.length == 0) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "无结果...", 5));
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
      }
      queryScore = list;
      double sum = 0.0;
      double _q = 0.0;
      double _xf = 0.0;
      int no = 0;
      for (int i = 0; i < list.length; i++) {
        if (list[i][2].toString().contains("慕") && list[i][3] == "") {
          no++;
        } else {
          _q += (int.parse(levelToNumber(list[i][4])) * double.parse(list[i][5]));
          _xf += double.parse(levelToNumber(list[i][5]));
          sum += int.parse(levelToNumber(list[i][4]));
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

    await getScore().then((value) => _next(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "成绩查询",
              InkWell(
                child: const Icon(Icons.close_outlined, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  // color: Global.homeCardsColor,
                  color: readColor(),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                              items: yearList(),
                              underline: Container(height: 0),
                              onChanged: (value) {
                                setState(() {
                                  writeData["queryYear"] = value;
                                });
                              },
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
                        Builder(builder: (BuildContext context) {
                          return InkWell(
                              onTap: () {
                                _query(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                                child: Text(
                                  "查询",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ));
                        })
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "GPA绩点: $_gpa",
                      style: TextStyle(),
                    ),
                    Text(
                      "|",
                      style: TextStyle(color: readColor()),
                    ),
                    Text(
                      "算术平均分: $_avg",
                      style: TextStyle(),
                    ),
                    Text(
                      "|",
                      style: TextStyle(color: readColor()),
                    ),
                    Text(
                      "加权平均分: $_weight",
                      style: TextStyle(),
                    )
                  ],
                ),
              ),
            ),
            QueryScore()
          ],
        ),
      ),
    );
  }
}

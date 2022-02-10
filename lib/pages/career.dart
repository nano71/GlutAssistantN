import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/style.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:noripple_overscroll/noripple_overscroll.dart';

import '../config.dart';
import '../data.dart';

class CareerPage extends StatefulWidget {
  final int type;
  const CareerPage({Key? key, this.type = 0}) : super(key: key);
  @override
  State<CareerPage> createState() => _CareerPageState(type: this.type);
}

class _CareerPageState extends State<CareerPage> {
  final int type;
  _CareerPageState({this.type = 0});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: CareerPageBody(type: type,));
  }
}

class CareerPageBody extends StatefulWidget {
  final int type;
  const CareerPageBody({Key? key, required this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CareerPageBodyState(type: this.type);
}

class _CareerPageBodyState extends State<CareerPageBody> {
  final int type;

  _CareerPageBodyState({required this.type });

  bool login = true;
  late StreamSubscription<CareerRe> eventBusFn;
  GlobalKey<CircularProgressDynamicStateForCareer> indicatorKey = GlobalKey();
  GlobalKey<TextProgressDynamicStateForCareer> textKey = GlobalKey();
  int year = 0;
  int allYear = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("type:");
    print(type);
    eventBusFn = pageBus.on<CareerRe>().listen((event) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context)
          .showSnackBar(jwSnackBar(true, "获取教务数据(可能需要半分钟)...", Global.timeOutSec * 2));
      getCareer().then((value) => process(value));
    });
    getCareer().then((value) => process(value));
  }

  process(String value) {
    if (value == "success") {
      login = false;
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(true, "处理返回数据...", Global.timeOutSec));
      setState(() {});
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(true, "数据已经更新", 1));
      examAllNumber = 0;
      careerNumber = 0;
      careerJobNumber = 0;
      careerList.forEach((element) {
        if (element.contains("考试")) {
          examAllNumber++;
        }
        if (element.length > 3) {
          careerNumber++;
          if (element[5].contains("专业")) {
            careerJobNumber++;
          }
        }
      });
      // Navigator.of(context).pop();

      _weekProgressAnimation();
    } else if (value == "fail") {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBarActionQ3(
        false,
        "需要验证",
        context,
        Global.timeOutSec,
      ));
    } else {
      print(value);
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(false, value, 4));
    }
  }

  void _weekProgressAnimation() {
    double _count = 0.0;
    const period = Duration(milliseconds: 10);
    final double max = _weekProgressDouble();
    Timer.periodic(period, (timer) {
      _count += 0.01;
      indicatorKey.currentState?.onPressed(_count);
      textKey.currentState?.onPressed((_count * 100).toInt());
      if (_count >= max) {
        timer.cancel();
      }
    });
  }

  double _weekProgressDouble() {
    if (careerInfo[2] != "" && careerInfo[3] != "") {
      //年级
      year = int.parse(careerInfo[2].replaceAll("级", "").trim());
      // 全部学年

      allYear = int.parse(
          careerInfo[3].substring(careerInfo[3].toString().indexOf("年") - 1).replaceAll("年", ""));
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
    Future.delayed(const Duration(seconds: 0), () {
      if (login) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context)
            .showSnackBar(jwSnackBar(true, "获取教务数据(可能需要半分钟)...", Global.timeOutSec * 2));
      }
    });
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
            "我的大学生涯",
            InkWell(
              child: const Icon(Icons.close_outlined, size: 24),
              onTap: () {
                if (type == 0) {
                  Navigator.of(context).pop();
                } else if (type == 1) {
                  Navigator.of(context).pop(1);
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              // margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              // padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              // decoration: BoxDecoration(
              //     borderRadius: const BorderRadius.all(Radius.circular(6.0)), color: readColor()),
              // child: Row(
              //   children: [
              //     Container(
              //       decoration: BoxDecoration(
              //           borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              //           color: readColor()),
              //       margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              //       padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              //       child: Icon(
              //         Icons.mood,
              //         size: 64,
              //         color: Colors.white,
              //       ),
              //     ),
              //     Expanded(
              //         child: Container(
              //       margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              //       padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              //       height: 80,
              //       decoration: BoxDecoration(
              //         borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              //       ),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             writeData["name"],
              //           ),
              //           Text(
              //             careerInfo[1],
              //           ),
              //           Text(
              //             careerInfo[2] + "  " + careerInfo[4],
              //           ),
              //         ],
              //       ),
              //     )),
              //   ],
              // ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)), color: readColor()),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 4, //宽度
                                  color: Colors.white, //边框颜色
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("课程总计", style: TextStyle(color: Colors.white)),
                                Row(
                                  children: [
                                    Text("预估", style: TextStyle(color: Colors.white)),
                                    Text(
                                      careerNumber.toString(),
                                      style: TextStyle(fontSize: 24, color: Colors.white),
                                    ),
                                    Text("门", style: TextStyle(color: Colors.white))
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            //限制进度条的高度
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 4, //宽度
                                  color: Colors.white, //边框颜色
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("专业课程", style: TextStyle(color: Colors.white)),
                                Row(
                                  children: [
                                    Text("预估", style: TextStyle(color: Colors.white)),
                                    Text(
                                      careerJobNumber.toString(),
                                      style: TextStyle(fontSize: 24, color: Colors.white),
                                    ),
                                    Text("门", style: TextStyle(color: Colors.white))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Stack(
                          children: [
                            Align(
                              child: SizedBox(
                                //限制进度条的高度
                                height: 100,
                                //限制进度条的宽度
                                width: 100,
                                child: CircularProgressDynamicForCareer(key: indicatorKey),
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextProgressDynamicForCareer(key: textKey),
                                    Text("大学进程",
                                        style: TextStyle(color: Colors.white, fontSize: 12))
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5, //宽度
                          color: Colors.white, //边框颜色
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("成绩合格", style: TextStyle(color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 8,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                                value: careerCount[1] == careerNumber
                                    ? 0.0
                                    : careerCount[1] / careerNumber, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("${careerCount[1]} 门", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("重修/补考", style: TextStyle(color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 8,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                                value: careerCount[0] == careerNumber
                                    ? 0.0
                                    : careerCount[0] / careerNumber, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("${careerCount[0]} 门", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("成绩未知", style: TextStyle(color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 8,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                                value: careerCount[2] == careerNumber
                                    ? 0.0
                                    : careerCount[2] / careerNumber, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("${careerCount[2]} 门", style: TextStyle(color: Colors.white)),
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
              return CareerListProcess(index);
            }, childCount: allYear),
          ),
        ],
      ),
    );
  }
}

class CareerListProcess extends StatefulWidget {
  final int index;

  const CareerListProcess(this.index, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CareerListProcessState(index);
}

class CareerListProcessState extends State<CareerListProcess> {
  bool _isExpanded = false;
  String title = "";
  final int index;
  final int startYear = int.parse(careerInfo[2].replaceAll("级", "").trim());

  CareerListProcessState(this.index);

  @override
  initState() {
    super.initState();
  }

  String titleProcess() {
    List chineseNumberCapitalization = ["一", "二", "三", "四", "五", "六", "七", "八"];
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ExpansionTile(
        onExpansionChanged: (e) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        collapsedIconColor: Colors.black45,
        iconColor: readColor(),
        tilePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        title: Row(
          children: [
            Icon(
              _isExpanded ? Icons.school : iconProcess(index),
              color: _isExpanded ? readColor() : randomColors2(),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
              child: Text(
                titleProcess(),
                style: TextStyle(
                  fontSize: 16,
                  color: _isExpanded ? readColor() : Colors.black,
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
                children: [SizedBox(width: 8), Text("课程列表 - 秋学期")],
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
            margin: const EdgeInsets.fromLTRB(16, 4, 24, 4),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1, //宽度
                  color: Color(0xfff1f1f1), //边框颜色
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [SizedBox(width: 8), Text("课程列表 - 春学期")],
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

careerDialog(context, index, type, year) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return NoRippleOverScroll(
        child: SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$year - ${type == 2 ? "春" : "秋"}学期"),
                  Text(
                    "课程计数: ${careerList2[(index * 2 + type / 2 >= 1 ? index * 2 + type / 2 : 0).toInt()].length} 门",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
              InkWell(
                child: const Icon(Icons.close_outlined, size: 32),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          titleTextStyle: TextStyle(
            color: readColor(),
            fontSize: 25,
          ),
          contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
          backgroundColor: Colors.white,
          children: careerDialogLoop(index, type),
        ),
      );
    },
  );
}

careerDialogLoop(int index, int semester) {
  List<Widget> list = [];
  double newIndex = 0;
  newIndex = index * 2 + semester / 2 >= 1 ? index * 2 + semester / 2 : 0;
  careerList2[newIndex.toInt()].forEach((element) {
    list.add(careerDialogItem(element));
  });
  return list;
}

careerDialogItem(element) {
  return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(color: randomColors()),
      height: 150,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Text(
                element[1][0],
                style: TextStyle(fontSize: 128, color: Color(0x66f1f1f1)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseLongText2ShortName(element[1]),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 8,
              ),
              Text(element[0], style: TextStyle(color: Colors.white)),
              Text(element[5], style: TextStyle(color: Colors.white)),
              Text("性质: " + element[2], style: TextStyle(color: Colors.white)),
              Text("学分: " + element[3], style: TextStyle(color: Colors.white)),
              Text(
                  "学时: " +
                      element[4]
                          .toString()
                          .replaceAll(" ", "")
                          .replaceAll(RegExp(r"\s+\b|\b\s\n"), "")
                          .trim(),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ));
}

class CircularProgressDynamicForCareer extends StatefulWidget {
  const CircularProgressDynamicForCareer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CircularProgressDynamicStateForCareer();
}

class CircularProgressDynamicStateForCareer extends State<CircularProgressDynamicForCareer> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 16,
      value: _value,
      backgroundColor: const Color.fromARGB(128, 255, 255, 255),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void onPressed(double value) {
    setState(() => _value = value);
  }
}

class TextProgressDynamicForCareer extends StatefulWidget {
  const TextProgressDynamicForCareer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TextProgressDynamicStateForCareer();
}

class TextProgressDynamicStateForCareer extends State<TextProgressDynamicForCareer> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Text((_value.toString() + "%"),
        style: const TextStyle(color: Colors.white, fontSize: 20));
  }

  void onPressed(int value) {
    setState(() => _value = value);
  }
}

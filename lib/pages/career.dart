import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '/common/get.dart';
import '/common/style.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CareerPageBody(
        type: type,
      ),
    );
  }
}

class CareerPageBody extends StatefulWidget {
  final int type;

  CareerPageBody({Key? key, required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CareerPageBodyState(type: this.type);
}

class _CareerPageBodyState extends State<CareerPageBody> {
  final int type;

  _CareerPageBodyState({required this.type});

  bool login = true;

  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadCareerPageState> eventBusListener;
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
    eventBusListener = eventBus.on<ReloadCareerPageState>().listen((event) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取数据...", AppConfig.timeOutSec * 2));
      getCareer().then(process);
    });
    getCareer().then(process);
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  process(value) {
    if (value is String) {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    } else {
      if (value) {
        login = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "处理数据...", AppConfig.timeOutSec));
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
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
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
          false,
          "需要验证",
          context,
          () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            eventBus.fire(ReloadCareerPageState());
            Navigator.pop(context);
          },
          hideSnackBarSeconds: AppConfig.timeOutSec,
        ));
      }
    }
  }

  void _weekProgressAnimation() {
    double _count = 0.0;
    Duration period = Duration(milliseconds: 10);
    final double max = _weekProgressDouble();
    Timer.periodic(period, (timer) {
      _count += 0.01;
      indicatorKey.currentState!.onPressed(_count);
      textKey.currentState!.onPressed((_count * 100).toInt());
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
    Future.delayed(Duration(seconds: 0), () {
      if (login) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取数据...", AppConfig.timeOutSec * 2));
      }
    });
    return Container(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
            "我的大学生涯",
            InkWell(
              child: Icon(FlutterRemix.close_line, size: 24),
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
                // margin:  EdgeInsets.fromLTRB(16, 0, 16, 0),
                // padding:  EdgeInsets.fromLTRB(8, 8, 8, 8),
                // decoration: BoxDecoration(
                //     borderRadius:  BorderRadius.all(Radius.circular(12.0)), color: readColor()),
                // child: Row(
                //   children: [
                //     Container(
                //       decoration: BoxDecoration(
                //           borderRadius:  BorderRadius.all(Radius.circular(12.0)),
                //           color: readColor()),
                //       margin:  EdgeInsets.fromLTRB(16, 0, 0, 0),
                //       padding:  EdgeInsets.fromLTRB(8, 8, 8, 8),
                //       child: Icon(
                //         FlutterRemix.checkbox_circle_line,
                //         size: 64,
                //         color: Colors.white,
                //       ),
                //     ),
                //     Expanded(
                //         child: Container(
                //       margin:  EdgeInsets.fromLTRB(0, 0, 16, 0),
                //       padding:  EdgeInsets.fromLTRB(8, 12, 8, 0),
                //       height: 80,
                //       decoration: BoxDecoration(
                //         borderRadius:  BorderRadius.all(Radius.circular(12.0)),
                //       ),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             AppData.writeData["name"],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 3.5, //宽度
                                  color: Colors.white, //边框颜色
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: Text(
                                    careerNumber.toString() + "",
                                    style: TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w300),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("全部课程总计", style: TextStyle(color: Colors.white)),
                                    Text("预估", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            //限制进度条的高度
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 3.5, //宽度
                                  color: Colors.white, //边框颜色
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: Text(
                                    careerJobNumber.toString() + "",
                                    style: TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w300),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("全部专业课程", style: TextStyle(color: Colors.white)),
                                    Text("预估", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                  children: [TextProgressDynamicForCareer(key: textKey), Text("大学进程", style: TextStyle(color: Colors.white, fontSize: 12))],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.fromLTRB(0, 18, 0, 12),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("成绩合格", style: TextStyle(color: Colors.white)),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 3.5,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Color.fromARGB(48, 255, 255, 255),
                                value: careerCount[1] == careerNumber ? 0.0 : careerCount[1] / careerNumber, //精确模式，进度20%
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
                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 3.5,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Color.fromARGB(48, 255, 255, 255),
                                value: careerCount[0] == careerNumber ? 0.0 : careerCount[0] / careerNumber, //精确模式，进度20%
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
                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 3.5,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Color.fromARGB(48, 255, 255, 255),
                                value: careerCount[2] == careerNumber ? 0.0 : careerCount[2] / careerNumber, //精确模式，进度20%
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

  CareerListProcess(this.index, {Key? key}) : super(key: key);

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
      child: ExpansionTile(
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
            margin: EdgeInsets.fromLTRB(16, 4, 24, 4),
            decoration: BoxDecoration(
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

class CircularProgressDynamicForCareer extends StatefulWidget {
  CircularProgressDynamicForCareer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CircularProgressDynamicStateForCareer();
}

class CircularProgressDynamicStateForCareer extends State<CircularProgressDynamicForCareer> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 3.5,
      value: _value,
      backgroundColor: Color.fromARGB(48, 255, 255, 255),
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void onPressed(double value) {
    setState(() => _value = value);
  }
}

class TextProgressDynamicForCareer extends StatefulWidget {
  TextProgressDynamicForCareer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TextProgressDynamicStateForCareer();
}

class TextProgressDynamicStateForCareer extends State<TextProgressDynamicForCareer> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Text((_value.toString() + "%"), style: TextStyle(color: Colors.white, fontSize: 20));
  }

  void onPressed(int value) {
    setState(() => _value = value);
  }
}

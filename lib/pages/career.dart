import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/widget/bars.dart';

import '../config.dart';
import '../data.dart';

class CareerPage extends StatefulWidget {
  final String title;

  const CareerPage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: CareerPageBody());
  }
}

class CareerPageBody extends StatefulWidget {
  const CareerPageBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CareerPageBodyState();
}

class _CareerPageBodyState extends State<CareerPageBody> {
  bool login = true;
  late StreamSubscription<CareerRe> eventBusFn;
  GlobalKey<CircularProgressDynamicStateForCareer> indicatorKey = GlobalKey();
  GlobalKey<TextProgressDynamicStateForCareer> textKey = GlobalKey();
  final int _week = int.parse(writeData["week"]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _weekProgressAnimation();
    eventBusFn = pageBus.on<CareerRe>().listen((event) {
      getCareer().then((value) => process(value));
    });
    getCareer().then((value) => process(value));
  }

  Widget careerListProcess(index) {
    if (careerList.length == 0) return Container();
    if (careerList[index].length > 3) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseLongText2ShortName(careerList[index][1]),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("性质: " + careerList[index][2], style: TextStyle()),
                SizedBox(
                  width: 25,
                ),
                Text("类型: " + careerList[index][5], style: TextStyle()),

                SizedBox(
                  width: 25,
                ),
                Text("学分: " + careerList[index][3], style: TextStyle()),

                // Text("性质: " + careerList[index][7], style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: [
            Text(careerList[index][0]),
            Text(careerList[index][1]),
          ],
        ),
      );
    }
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
      Navigator.of(context).pop();

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
      indicatorKey.currentState!.onPressed(_count);
      textKey.currentState!.onPressed((_count * 100).toInt());
      if (_count >= max) {
        timer.cancel();
      }
    });
  }

  double _weekProgressDouble() {
    int year = 0;
    int year2 = 0;
    print(careerInfo);
    if (careerInfo[2] != "" && careerInfo[3] != "") {
      year = int.parse(careerInfo[2].toString().replaceAll("级", "").trim());
      year2 = int.parse(careerInfo[3]
          .toString()
          .substring(careerInfo[3].toString().indexOf("年") - 1)
          .replaceAll("年", ""));
      setState(() {});
    }
    if (_week > 20 && DateTime.now().year == year + year2) {
      return 1.00;
    }
    if (careerInfo[2] == "" && careerInfo[3] == "") return 0.0;
    print(year2);
    print(year);
    if (year2 == 3) {
      if (writeData["semester"] == "秋") {
        return 1 -
            (year + year2 - DateTime.now().year) / year2 +
            ((_week * 5 / 100) - 0.05 + (DateTime.now().weekday / 7 * 5 / 100)) * 1 / 6;
      } else {
        return 1 - (year + year2 - DateTime.now().year) / year2 + 1 / 6;
      }
    } else {
      if (writeData["semester"] == "秋") {
        return 1 -
            (year + year2 - DateTime.now().year) / year2 +
            ((_week * 5 / 100) - 0.05 + (DateTime.now().weekday / 7 * 5 / 100)) * 1 / 4;
      } else {
        return 1 - (year + year2 - DateTime.now().year) / year2 + 1 / 4;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      if (login) {
        Scaffold.of(context).removeCurrentSnackBar();
        // Scaffold.of(context)
        //     .showSnackBar(jwSnackBar(true, "获取教务数据(可能需要半分钟)...", Global.timeOutSec * 2));
        Scaffold.of(context)
            .showSnackBar(jwSnackBar(false, "测试功能!暂不开放", Global.timeOutSec * 2));
      }
    });
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
            "课程生涯",
            InkWell(
              child: const Icon(Icons.close_outlined, size: 24),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  color: randomColors()),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        color: Colors.white),
                    margin: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Icon(
                      Icons.hotel,
                      size: 64,
                      color: randomColors2(),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        writeData["name"],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(careerInfo[1] + "  " + careerInfo[2],
                          style: TextStyle(color: Colors.white)),
                      Text(careerInfo[4], style: TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                  width: 2, //宽度
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
                                    Text("预计", style: TextStyle(color: Colors.white)),
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
                                  width: 2, //宽度
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
                                    Text("预计", style: TextStyle(color: Colors.white)),
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
                                value: .2, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("0 门", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("挂科/补考", style: TextStyle(color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: SizedBox(
                              height: 8,
                              width: 50,
                              child: LinearProgressIndicator(
                                color: Colors.white,
                                backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                                value: .2, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("0 门", style: TextStyle(color: Colors.white)),
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
                                value: .2, //精确模式，进度20%
                              ),
                            ),
                          ),
                          Text("0 门", style: TextStyle(color: Colors.white)),
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
            return careerListProcess(index);
          }, childCount: careerList.length)),
        ],
      ),
    );
  }
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

import 'dart:async';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventBusFn = pageBus.on<CareerRe>().listen((event) {
      getCareer().then((value) => process(value));
    });
    getCareer().then((value) => process(value));
  }

  Widget careerListProcess(index) {
    print(index);
    if (careerList.length == 0 || index == 0) return Container();
    if (careerList.length == 0 || index == 0) return Container();
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
            // Container(
            //   margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            //   color:Colors.white,
            //   child: Align(
            //     child: Text(courseLongText2ShortName(careerList[index][1])[0]),
            //   ),
            // ),
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
      careerList.forEach((element) {
        if (element.contains("考试")) {
          print(element);
          examAllNumber++;
        }
        if (element.length > 3) {
          careerNumber++;
        }
      });
      print(examAllNumber);
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
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Icon(
                      Icons.mood,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        writeData["name"],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      // Text("作为${careerList[0][1]}的一员"),
                      // Text("你会在3年内学习不低于$careerNumber门的课程"),
                      // Text("你勤奋学习,目前还任何一门课程绊倒过你"),
                      // Text("作为计算机的专业的一员,你将在3年内学习不低于80门课程"),
                      Text(careerList[0][1] + "  " + careerList[0][2],
                          style: TextStyle(color: Colors.white)),
                      Text(careerList[0][4], style: TextStyle(color: Colors.white)),
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

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
      getExam().then((value) => process(value));
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
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "获取教务数据...", 6));
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
              child: const Text(
                "你大学期间的全部课程都在这里",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height - 125,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "敬请期待...",
                        style: TextStyle(fontSize: 18, color: readColor()),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}

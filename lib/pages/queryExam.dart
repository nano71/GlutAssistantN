import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '/common/get.dart';
import '/config.dart';
import '/widget/bars.dart';
import '/widget/lists.dart';
import '../data.dart';
import 'career.dart';

class QueryExamPage extends StatefulWidget {
  final String title;

  QueryExamPage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<QueryExamPage> createState() => _QueryExamPageState();
}

class _QueryExamPageState extends State<QueryExamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: QueryExamBody(),
    );
  }
}

class QueryExamBody extends StatefulWidget {
  QueryExamBody({Key? key}) : super(key: key);

  @override
  State<QueryExamBody> createState() => _QueryExamBodyState();
}

class _QueryExamBodyState extends State<QueryExamBody> {
  bool login = true;

  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadExamListState> eventBusListener;
  int _examAllNumber = examAllNumber;

  @override
  void initState() {
    super.initState();
    eventBusListener = eventBus.on<ReloadExamListState>().listen((event) {
      getExam().then(process);
    });
    getExam().then(process);
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  void process(value) {
    if (value is bool) {
      if (value) {
        login = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "处理数据...", 10));
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
          false,
          "需要验证",
          context,
          () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            //  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "验证完成,请再次点击查询")),
            eventBus.fire(ReloadExamListState());
            Navigator.pop(context);
          },
          hideSnackBarSeconds: 10,
        ));
      }
    } else if (value is String) {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      if (login) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取数据...", 6));
      }
    });
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
              "我的考试",
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
              readColor(),
              Colors.white,
              0),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: readColor(),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50,
                              child: Text(
                                "$examListA",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Text(
                                "$examListB",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CareerPage(type: 1))).then((result) {
                                    print(examAllNumber);
                                    setState(() {
                                      _examAllNumber = examAllNumber;
                                    });
                                  });
                                },
                                child: Text(
                                  (_examAllNumber.toString() == "0" ? "获取" : _examAllNumber.toString()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 24),
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
                              "已经历的",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "即将到来",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "生涯预估",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ExamList(),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../data.dart';
import 'career.dart';

class QueryExamPage extends StatefulWidget {
  final String title;

  const QueryExamPage({Key? key, this.title = "生涯"}) : super(key: key);

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
  const QueryExamBody({Key? key}) : super(key: key);

  @override
  State<QueryExamBody> createState() => _QueryExamBodyState();
}

class _QueryExamBodyState extends State<QueryExamBody> {
  bool login = true;
  // ignore: cancel_subscriptions
  late StreamSubscription<QueryExamRe> eventBusFn;
  int _examAllNumber = examAllNumber;

  @override
  void initState() {
    super.initState();
    eventBusFn = pageBus.on<QueryExamRe>().listen((event) {
      getExam().then((value) => _process(value));
    });
    getExam().then((value) => _process(value));
  }
  @override
  void dispose(){
    eventBusFn.cancel();
    super.dispose();
  }
  void _process(String value) {
    if (value == "success") {
      login = false;
       ScaffoldMessenger.of(context).removeCurrentSnackBar();
       ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "处理数据...", 10));
      setState(() {});
       ScaffoldMessenger.of(context).removeCurrentSnackBar();
       ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
    } else if (value == "fail") {
       ScaffoldMessenger.of(context).removeCurrentSnackBar();
       ScaffoldMessenger.of(context).showSnackBar(jwSnackBarActionQ2(
        false,
        "需要验证",
        context,
        10,
      ));
    } else {
      // print(value);
       ScaffoldMessenger.of(context).removeCurrentSnackBar();
       ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      if (login) {
         ScaffoldMessenger.of(context).removeCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取数据...", 6));
      }
    });
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [readColor(),readColor(),Colors.transparent,Colors.transparent,Colors.transparent,Colors.transparent],
            stops: [0,.5,.50001,.6,.61,1]
        ),
      ),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
              "我的考试",
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
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => const CareerPage(
                                                type: 1,
                                              )))
                                      .then((result) {
                                    // print(examAllNumber);
                                    setState(() {
                                      _examAllNumber = examAllNumber;
                                    });
                                  });
                                },
                                child: Text(
                                  (_examAllNumber.toString() == "0"
                                      ? "获取"
                                      : _examAllNumber.toString()),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../data.dart';

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
  late StreamSubscription<QueryExamRe> eventBusFn;

  @override
  void initState() {
    super.initState();
    eventBusFn = pageBus.on<QueryExamRe>().listen((event) {
      getExam().then((value) => process(value));
    });
    getExam().then((value) => process(value));
  }

  process(String value) {
    if (value == "success") {
      login = false;
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(true, "处理返回数据...", 10));
      setState(() {});
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(true, "数据已经更新", 1));
    } else if (value == "fail") {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBarActionQ2(
        false,
        "需要验证",
        context,
        10,
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
              "我的考试",
              InkWell(
                child: const Icon(
                  Icons.close_outlined,
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
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
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
                              child: Text(
                                "NaN",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
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

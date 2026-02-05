import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../type/teachingPlan.dart';
import '/common/get.dart';
import '/config.dart';
import '/widget/bars.dart';
import '/widget/lists.dart';
import '../data.dart';
import 'teachingPlan.dart';

class QueryExamsPage extends StatefulWidget {

  QueryExamsPage({Key? key}) : super(key: key);

  @override
  State<QueryExamsPage> createState() => _QueryExamsPageState();
}

class _QueryExamsPageState extends State<QueryExamsPage> {
  // ignore: cancel_subscriptions
  late StreamSubscription<ReloadExamListState> eventBusListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "获取数据...", 6));
      getExams().then(process);
    });

    eventBusListener = eventBus.on<ReloadExamListState>().listen((event) {
      getExams().then(process);
    });
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  void process(value) {
    if (value is bool) {
      if (value) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "处理数据...", 10));
        setState(() {});
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "数据已更新!", 1));
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithAction(
          false,
          "需要验证",
          context,
          () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            //  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "验证完成,请再次点击查询")),
            eventBus.fire(ReloadExamListState());
            Navigator.pop(context);
          },
          duration: 10,
        ));
      }
    } else if (value is String) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, value, 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: readBackgroundColor(),
        body:  CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        TopNavigationBar(
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
            readListPageTopAreaBackgroundColor(),
            Colors.white,
            0),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -1),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: readListPageTopAreaBackgroundColor(),
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
                                "$completedExamCount",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Text(
                                "$upcomingExamCount",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) => teachingPlanPage(type: 1)))
                                      .then((result) {
                                    setState(() {});
                                  });
                                },
                                child: Text(
                                  (TeachingPlan.totalExamCount == 0 ? "获取" : TeachingPlan.totalExamCount.toString()),
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
        ),
        ExamList(),
      ],
    ),);
  }
}

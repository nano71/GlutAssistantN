import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '/widget/bars.dart';
import '../config.dart';

class ScheduleManagePage extends StatefulWidget {
  ScheduleManagePage({Key? key}) : super(key: key);

  @override
  State<ScheduleManagePage> createState() => _ScheduleManagePageState();
}

class _ScheduleManagePageState extends State<ScheduleManagePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          TopNavigationBar(
            "课程管理",
            InkWell(
              child: Icon(Remix.close_line, size: 24),
              onTap: () {
                Navigator.of(context).pop();
              },
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

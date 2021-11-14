import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/bars.dart';

import '../config.dart';

class ScheduleManagePage extends StatefulWidget {
  final String title;

  const ScheduleManagePage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<ScheduleManagePage> createState() => _ScheduleManagePageState();
}

class _ScheduleManagePageState extends State<ScheduleManagePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "课程管理",
              InkWell(
                child: const Icon(Icons.close_outlined, size: 24),
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
                    ))),
          ],
        ),
      ),
    );
  }
}

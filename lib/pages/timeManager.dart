import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '/common/io.dart';
import '/widget/bars.dart';
import '../config.dart';
import '../data.dart';
import 'layout.dart';

bool _isError = false;

class TimeManagePage extends StatefulWidget {
  final String title;

  TimeManagePage({Key? key, this.title = "时间"}) : super(key: key);

  @override
  State<TimeManagePage> createState() => _TimeManagePageState();
}

class _TimeManagePageState extends State<TimeManagePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getScore();
    endTimeListBk = endTimeList;
    startTimeListBk = startTimeList;
  }

  void reset() {
    startTimeList = [];
    startTimeListBk = [];
    endTimeList = [];
    endTimeListBk = [];
    for (List<int> value in startTimeListRestore) {
      startTimeList.add(value);
      startTimeListBk.add(value);
    }
    for (List<int> value in endTimeListRestore) {
      endTimeList.add(value);
      endTimeListBk.add(value);
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "已经恢复!", 2));
    print(startTimeListRestore);
    print(endTimeListRestore);
    print(startTimeList);
    print(endTimeList);
    print(startTimeListBk);
    print(endTimeListBk);
    writeConfig();
    eventBus.fire(SetPageIndex());
    Navigator.pushAndRemoveUntil(
      context,
      AppRouter(Layout()),
      (route) => false,
    );
  }

  void save() {
    if (_isError) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "请认真检查!", 2));
      return;
    }

    startTimeList = startTimeListBk;
    endTimeList = endTimeListBk;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "已经更改!", 2));
    writeConfig();
    eventBus.fire(SetPageIndex());
    Navigator.pushAndRemoveUntil(
      context,
      AppRouter(Layout()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            TopNavigationBar(
              "时间定义",
              InkWell(
                child: Icon(Remix.close_line, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "请严格按照预设格式进行编辑!",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: reset,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Color(0x8ff1f1f1),
                            ),
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              "恢复",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: save,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Color(0x8ff1f1f1),
                            ),
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              "保存",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return _TimeManagerItem(index);
              }, childCount: startTimeList.length),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class _TimeManagerItem extends StatefulWidget {
  final int index;

  _TimeManagerItem(this.index);

  @override
  State<StatefulWidget> createState() => _TimeManagerItemState(index);
}

class _TimeManagerItemState extends State<_TimeManagerItem> {
  final int index;

  _TimeManagerItemState(this.index);

  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  double width = 56;
  double height = 14;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String endTime = startTimeList[index][1].toString();
    String endTime2 = endTimeList[index][1].toString();
    if (int.parse(endTime) < 10) endTime = "0" + endTime;
    if (int.parse(endTime2) < 10) endTime2 = "0" + endTime2;
    controller.text = startTimeList[index][0].toString() + ":" + endTime;
    controller2.text = endTimeList[index][0].toString() + ":" + endTime2;
    print(endTime2);
  }

  void setStartTime(String value) {
    if (!value.contains(":") || value[value.length - 1] == ":" || value.isEmpty) {
      _isError = true;
      return;
    }
    _isError = false;
    int cache1 = int.parse(value.replaceAll(" ", "").split(":")[0]);
    int cache2 = int.parse(value.replaceAll(" ", "").split(":")[1]);
    startTimeListBk[index] = [cache1, cache2];
    print(startTimeListBk);
  }

  void _setEndTime(String value) {
    if (!value.contains(":") || value[value.length - 1] == ":" || value.isEmpty) {
      print("Error");
      _isError = true;
      return;
    }
    _isError = false;
    int cache1 = int.parse(value.replaceAll(" ", "").split(":")[0]);
    int cache2 = int.parse(value.replaceAll(" ", "").split(":")[1]);
    endTimeListBk[index] = [cache1, cache2];
    print(endTimeListBk);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
            child: Text(
              "第${index + 1}节",
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: width,
                child: TextField(
                  onChanged: setStartTime,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  controller: controller,
                  scrollPadding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    isDense: true,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  "-",
                  style: TextStyle(color: readColor()),
                ),
              ),
              SizedBox(
                width: width,
                child: TextField(
                  onChanged: _setEndTime,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  controller: controller2,
                  scrollPadding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    isDense: true,
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

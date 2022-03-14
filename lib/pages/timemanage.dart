import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/widget/bars.dart';

import '../config.dart';
import '../data.dart';
import 'init.dart';

bool _isError = false;

class TimeManagePage extends StatefulWidget {
  final String title;

  const TimeManagePage({Key? key, this.title = "时间"}) : super(key: key);

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

  void _reset() {
    startTimeList = [];
    startTimeListBk = [];
    endTimeList = [];
    endTimeListBk = [];
    for (List value in startTimeListRe) {
      startTimeList.add(value);
      startTimeListBk.add(value);
    }
    for (List value in endTimeListRe) {
      endTimeList.add(value);
      endTimeListBk.add(value);
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "已经恢复!", 2));
    // print(startTimeListRe);
    // print(endTimeListRe);
    // print(startTimeList);
    // print(endTimeList);
    // print(startTimeListBk);
    // print(endTimeListBk);
    writeConfig();
    pageBus.fire(SetPageIndex(0));
    Navigator.pushAndRemoveUntil(
      context,
      CustomRouteMs300(
        const Index(
          type: 0,
        ),
      ),
      (route) => false,
    );
  }

  void _save() {
    if (_isError) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "请认真检查!", 2));
      return;
    }

    // print("save");
    startTimeList = startTimeListBk;
    endTimeList = endTimeListBk;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "已经更改!", 2));
    // print(startTimeListRe);
    // print(endTimeListRe);
    // print(startTimeList);
    // print(endTimeList);
    // print(startTimeListBk);
    // print(endTimeListBk);
    writeConfig();
    pageBus.fire(SetPageIndex(0));
    Navigator.pushAndRemoveUntil(
      context,
      CustomRouteMs300(
        const Index(
          type: 0,
        ),
      ),
      (route) => false,
    );
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
              "时间定义",
              InkWell(
                child: const Icon(FlutterRemix.close_line, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                          onTap: _reset,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Color(0x8ff1f1f1),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              "恢复",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _save,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Color(0x8ff1f1f1),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                return TimeManagerItem(index);
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

class TimeManagerItem extends StatefulWidget {
  final int index;

  const TimeManagerItem(this.index);

  @override
  State<StatefulWidget> createState() => TimeManagerItemState(index);
}

class TimeManagerItemState extends State<TimeManagerItem> {
  final int index;

  TimeManagerItemState(this.index);

  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  double width = 56;
  double height = 14;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String endTime = startTimeList[index][1].toString();
    String endTime2 = endTimeList[index][1].toString();
    if (int.parse(endTime) < 10) endTime = "0" + endTime;
    if (int.parse(endTime2) < 10) endTime2 = "0" + endTime2;
    _controller.text = startTimeList[index][0].toString() + ":" + endTime;
    _controller2.text = endTimeList[index][0].toString() + ":" + endTime2;
    // print(endTime2);
  }

  void _setStartTime(String value) {
    if (!value.contains(":") || value[value.length - 1] == ":" || value.isEmpty) {
      // print("Error");
      _isError = true;
      return;
    }
    _isError = false;
    int cache1 = int.parse(value.replaceAll(" ", "").split(":")[0]);
    int cache2 = int.parse(value.replaceAll(" ", "").split(":")[1]);
    startTimeListBk[index] = [cache1, cache2];
    // print(startTimeListBk);
  }

  void _setEndTime(String value) {
    if (!value.contains(":") || value[value.length - 1] == ":" || value.isEmpty) {
      // print("Error");
      _isError = true;
      return;
    }
    _isError = false;
    int cache1 = int.parse(value.replaceAll(" ", "").split(":")[0]);
    int cache2 = int.parse(value.replaceAll(" ", "").split(":")[1]);
    endTimeListBk[index] = [cache1, cache2];
    // print(endTimeListBk);
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
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
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
                  onChanged: _setStartTime,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  controller: _controller,
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
                  controller: _controller2,
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

Widget doublePoint() {
  return Text(
    " : ",
    style: TextStyle(color: readColor()),
  );
}

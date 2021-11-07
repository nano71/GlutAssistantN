import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/data.dart';
import 'package:glutnnbox/widget/bars.dart';

Widget _rowHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //  decoration: ,
    children: _loopRowHeader(),
  );
}

List<Widget> _loopRowHeader() {
  List _weekDayList = ["一", "二", "三", "四", "五", "六", "日"];
  List<Widget> list = [];
  for (int i = 0; i < 8; i++) {
    if (i == 0) {
      list.add(const SizedBox(width: 20));
    } else {
      list.add(Expanded(
          child: Center(
              child: Text(
        "周${_weekDayList[i - 1]}",
        style: TextStyle(color: ((i) == DateTime.now().weekday ? Colors.blue : Colors.grey)),
      ))));
    }
  }
  return list;
}

Widget _leftGrid(String title) {
  return Container(
    width: 20,
    height: 75,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
          top: BorderSide(
            width: 0.75, //宽度
            color: Color(0xfff9f9f9), //边框颜色
          ),
          right: BorderSide(
            width: 0.75, //宽度
            color: Color(0xfff9f9f9), //边框颜色
          )),
    ),
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Colors.blue),
    ),
  );
}

List<Widget> _loopLeftGrid() {
  List<Widget> list = [];
  for (int i = 1; i < 12; i++) {
    list.add(_leftGrid(i.toString()));
  }
  return list;
}

class SchedulePage extends StatefulWidget  {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Column(
        children: [
          scheduleTopBar,
          Container(
            child: _rowHeader(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              scrollDirection: Axis.vertical,
              child: Row(
                children: [
                  Column(
                    children: _loopLeftGrid(),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _loopWeekDayCol(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}

List<Widget> _loopWeekDayCol() {
  List<Widget> list = [];
  for (int i = 1; i < 8; i++) {
    list.add(_col(i.toString()));
  }
  return list;
}

//星期几
Widget _col(String weekDay) {
  return Expanded(
    child: Column(
      children: _loopWeekDayColGrid(weekDay),
    ),
  );
}

List<Widget> _loopWeekDayColGrid(String weekDay) {
  List<Widget> list = [];
  Map _schedule = schedule[writeData["week"]][weekDay];
  for (int i = 1; i < 12; i++) {
    String courseName = _schedule[i.toString()][0];
    String studyArea = _schedule[i.toString()][2];
    courseName = courseLongText2ShortName(courseName);
    if (courseName != "null") {
      if (i > 1 &&
          courseLongText2ShortName(_schedule[(i - 1).toString()][0]) == courseName &&
          courseLongText2ShortName(_schedule[(i - 1).toString()][0]) != "null") {
        list.removeLast();
        list.add(_grid(courseName, studyArea, randomColors(), 75 * 2));
      } else {
        list.add(_grid(courseName, studyArea, randomColors()));
      }
    } else {
      list.add(_grid("", "", Colors.white));
    }
  }
  return list;
}

Widget _grid(String title, String studyArea, Color color, [double height = 75.0]) {
  TextStyle style = const TextStyle(fontSize: 12, color: Colors.white);
  return Container(
      height: height,
      color: color,
      padding: const EdgeInsets.only(left: 6, right: 6),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: style,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            studyArea,
            textAlign: TextAlign.center,
            softWrap: true,
            style: style,
          ),
        ],
      ));
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/widget/bars.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
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
              child: Container(
                color: Colors.white,
                child: Column(
                  children: _loopRow(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _row(int index) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: _loopRowGrid(index.toString()));
}

Widget _grid(String title, int weekDay) {
  return Container(
    height: 75,
    alignment: Alignment.center,
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
  );
}

Widget _leftGrid(String title) {
  return Container(
    width: 20,
    height: 75,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.white),
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: Colors.blue),
    ),
  );
}

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

List<Widget> _loopRow() {
  List<Widget> list = [];
  for (int i = 0; i < 11; i++) {
    list.add(_row(i + 1));
  }
  return list;
}

List<Widget> _loopRowGrid(String firstTitle) {
  List<Widget> list = [];
  for (int i = 0; i < 8; i++) {
    if (i == 0) {
      list.add(_leftGrid(firstTitle));
    } else {
      list.add(Expanded(child: _grid("45", i)));
    }
  }
  return list;
}

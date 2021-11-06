import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/widget/bars.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

double numRowWidth = 50.0; //单个表宽
double numRowHeight = 100; //表格高

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
              child: Column(children: [
            Table(children: <TableRow>[
              tableHeader(),
            ])
          ])),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Table(children: _buildTableRow()),
                  )))
        ],
      ),
    );
  }
}

//创建tableRows
List<TableRow> _buildTableRow() {
  List<TableRow> returnList = [];
  for (int i = 0; i < 11; i++) {
    returnList.add(_buildSingleRow(i + 1));
  }
  return returnList;
}

//创建第一列tableRow

//创建一行tableRow
TableRow _buildSingleRow(int index) {
  return TableRow(
      //第一行样式 添加背景色
      children: [
        _buildSideBox("$index", 1),
        _buildSideBox("45", 2),
        _buildSideBox("45", 3),
        _buildSideBox("45", 4),
        _buildSideBox("45", 5),
        _buildSideBox("45", 6),
        _buildSideBox("45", 7),
        _buildSideBox("45", 8),
      ]);
}

//创建单个表格
Widget _buildSideBox(String title, int index) {
  return SizedBox(
      height: numRowHeight,
      width: (index == 1 ? 10 : 50),
      child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF000000),
                width: 1.0,
                style: BorderStyle.solid,
              ),
              color: Colors.white),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: (index == 1 ? Colors.blue : Colors.grey)),
          )));
}

TableRow tableHeader() {
  return const TableRow(
    //  decoration: ,
    children: <Widget>[
      Text(""),
      Text("周一"),
      Text("周二"),
      Text("周三"),
      Text("周四"),
      Text("周五"),
      Text("周六"),
      Text("周日"),
    ],
  );
}

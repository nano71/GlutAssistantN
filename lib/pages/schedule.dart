import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Table(
          border: TableBorder(
            // 内部的水平线
            horizontalInside: BorderSide(
              color: Colors.blue,
              width: 1,
              style: BorderStyle.solid,
            ),
            // 内部的垂直线
            verticalInside: BorderSide(
              color: Colors.red,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          children: <TableRow>[
            buildTableRow(),
            buildTableRow(),
            buildTableRow(),
            buildTableRow(),
          ],
        ));
  }
}

TableRow buildTableRow() {
  return TableRow(
    //  decoration: ,
    children: <Widget>[
      Text("data"),
      Text("data"),
      Text("data"),
      Text("data"),
      Text("data"),
      Text("data"),
    ],
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/widget/bars.dart';
import 'package:glutnnbox/widget/icons.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  MinePageState createState() => MinePageState();
}

class MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            mineTopBar,
            SliverToBoxAdapter(
                child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                textDirection: TextDirection.ltr,
                children: [
                  mineItem(
                      Icons.account_box_outlined, const EdgeInsets.fromLTRB(16, 14, 0, 14), "登录教务"),
                  mineItem(
                      Icons.workspaces_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "课程生涯"),
                  mineItem(
                      Icons.list_alt_rounded, const EdgeInsets.fromLTRB(16, 14, 0, 14), "成绩查询"),
                  topLine,
                  mineItem(Icons.info_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "说明"),
                  mineItem(Icons.settings_outlined, const EdgeInsets.fromLTRB(16, 14, 0, 14), "设置"),
                ],
              ),
            )),
          ]),
    );
  }
}

Container topLine = Container(
  width: double.infinity,
  margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
  decoration: const BoxDecoration(
    border: Border(
      top: BorderSide(
        width: 1, //宽度
        color: Color(0xfff1f1f1), //边框颜色
      ),
    ),
  ),
);

Widget mineItem(IconData icon, EdgeInsets padding, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon),
          Container(
            padding: padding,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      chevronRight
    ],
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/pages/career.dart';
import 'package:glutassistantn/pages/query.dart';
import 'package:glutassistantn/pages/setting.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/icons.dart';

import '../data.dart';
import 'info.dart';
import 'init.dart';
import 'login.dart';

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
            publicTopBar(writeData["name"] != "" ? "Hi! " + writeData["name"] : "请先登录教务"),
            SliverToBoxAdapter(
                child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                textDirection: TextDirection.ltr,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        // 在FormPage()里传入参数
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: mineItem(
                        Icons.account_box_outlined,
                        const EdgeInsets.fromLTRB(16, 14, 0, 14),
                        (writeData["name"] != "" ? "更换账号" : "登录教务")),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          // 在FormPage()里传入参数
                          MaterialPageRoute(builder: (context) => const CareerPage()));
                    },
                    child: mineItem(
                        Icons.workspaces_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "课程生涯"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          // 在FormPage()里传入参数
                          MaterialPageRoute(builder: (context) => const QueryPage()));
                    },
                    child: mineItem(
                        Icons.list_alt_rounded, const EdgeInsets.fromLTRB(16, 14, 0, 14), "成绩查询"),
                  ),
                  topLine,
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          // 在FormPage()里传入参数
                          MaterialPageRoute(builder: (context) => const InfoPage()));
                    },
                    child: mineItem(
                        Icons.info_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "说明"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          // 在FormPage()里传入参数
                          MaterialPageRoute(builder: (context) => const SettingPage(title: "设置2")));
                    },
                    child: mineItem(
                        Icons.settings_outlined, const EdgeInsets.fromLTRB(16, 14, 0, 14), "设置"),
                  ),
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
Widget mineItem2(IconData icon, EdgeInsets padding, String title) {
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
      chevronDown
    ],
  );
}

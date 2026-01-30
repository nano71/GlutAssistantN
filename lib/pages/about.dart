import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/widget/cards.dart';
import 'package:remixicon/remixicon.dart';

import '/custom/expansiontile.dart' as CustomExpansionTile;
import '/widget/bars.dart';

class AboutPage extends StatefulWidget {
  final String title;

  AboutPage({Key? key, this.title = "说明"}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: readBackgroundColor(),
        body: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "说明",
              InkWell(
                child: Icon(
                  Remix.close_line,
                  size: 24,
                  color: readTextColor(),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              readBackgroundColor(),
              readTextColor(),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  "一些有必要的说明",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 64),
                    child: CustomCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomExpansionTile.ExpansionTile(
                              initiallyExpanded: true,
                              collapsedIconColor: readColor(),
                              iconColor: readColor(),
                              textColor: readTextColor(),
                              collapsedTextColor: readTextColor(),
                              tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              title: _infoItem(Icons.privacy_tip_outlined, EdgeInsets.fromLTRB(16, 14, 0, 14), "隐私"),
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    "本 APP 没有申请任何权限，且所有网络通信只请求教务服务器数据、日活数据收集以及版本更新检查，不会对其他任何用户相关的数据进行采集",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]),
                          CustomExpansionTile.ExpansionTile(
                              initiallyExpanded: true,
                              collapsedIconColor: readColor(),
                              iconColor: readColor(),
                              textColor: readTextColor(),
                              collapsedTextColor: readTextColor(),
                              tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              title: _infoItem(Icons.insert_emoticon_sharp, EdgeInsets.fromLTRB(16, 14, 0, 14), "可信"),
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    "我是一名本校学生，也是学校计算机应用系官网唯一前端开发者，编写此 APP 是出于对学校的热爱，如果你并不信任此 APP，卸载即可",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]),
                          CustomExpansionTile.ExpansionTile(
                              initiallyExpanded: true,
                              collapsedIconColor: readColor(),
                              iconColor: readColor(),
                              textColor: readTextColor(),
                              collapsedTextColor: readTextColor(),
                              tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              title: _infoItem(Icons.check_circle_outline, EdgeInsets.fromLTRB(16, 14, 0, 14), "验证"),
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    "初次使用时需要进行一次登录，以后执行的任何操作只需要输入验证码即可，每验证一次可以获得15分钟的免验证操作",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]),
                          // CustomExpansionTile.ExpansionTile(
                          //     initiallyExpanded: true,
                          //     collapsedIconColor: readColor(),
                          //     iconColor: readColor(),
                          //     textColor: Colors.black,
                          //     collapsedTextColor: readTextColor(),
                          //     tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          //     title: infoItem(Icons.check_circle_outline, EdgeInsets.fromLTRB(16, 14, 0, 14), "成绩"),
                          //     children: [
                          //       Container(
                          //         padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          //         child: Text(
                          //           "2019级及以后的平均学分绩点=∑(课程学分数×绩点数)/∑课程学分数, 注意: 参与计算的课程仅为选课属性必修课和集中性实践教学环节, 以及同一门课程选修多次的, 取最高成绩",
                          //           style: TextStyle(color: Colors.grey),
                          //         ),
                          //       ),
                          //     ]),
                          CustomExpansionTile.ExpansionTile(
                              initiallyExpanded: true,
                              collapsedIconColor: readColor(),
                              iconColor: readColor(),
                              textColor: readTextColor(),
                              collapsedTextColor: readTextColor(),
                              tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              title: _infoItem(Icons.feedback_outlined, EdgeInsets.fromLTRB(16, 14, 0, 14), "反馈"),
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Text(
                                    "鼓励大家在 Github 上给这个项目提 issue，你也可以点击下面的 QQ 号或 WX 号来联系我😋",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "QQ:",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          Builder(
                                            builder: (BuildContext context) {
                                              return TextButton(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(text: "1742968988"));
                                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "复制成功!"));
                                                },
                                                child: Text(
                                                  "1742968988",
                                                  style: TextStyle(color: Colors.blue),
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "WX:",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          Builder(builder: (BuildContext context) {
                                            return TextButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: "13520944872"));
                                                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                                ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "复制成功!"));
                                              },
                                              child: Text(
                                                "13520944872",
                                                style: TextStyle(color: Colors.green),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ])
                        ],
                      ),
                    )))
          ],
        ));
  }
}

Widget _infoItem(IconData icon, EdgeInsets padding, String title) {
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
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/widget/bars.dart';

class InfoPage extends StatefulWidget {
  final String title;

  InfoPage({Key? key, this.title = "说明"}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "说明",
              InkWell(
                child: Icon(FlutterRemix.close_line, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
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
              padding: EdgeInsets.fromLTRB(16, 42, 16, 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpansionTile(
                      initiallyExpanded: true,
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.black45,
                      textColor: Colors.black,
                      tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: infoItem(Icons.privacy_tip_outlined, EdgeInsets.fromLTRB(16, 14, 0, 14), "隐私"),
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            "此APP没有请求任何的权限,所有网络通信只请求教务服务器数据以及Github版本更新,不会对其他服务器数据上传.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]),
                  ExpansionTile(
                      initiallyExpanded: true,
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.black45,
                      textColor: Colors.black,
                      tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: infoItem(Icons.insert_emoticon_sharp, EdgeInsets.fromLTRB(16, 14, 0, 14), "可信"),
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            "我是一名本校学生,也是学校计算机应用系官网唯一前端开发,编写此APP是出于对学校的热爱,如果你并不信任此APP,请卸载就行.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]),
                  ExpansionTile(
                      initiallyExpanded: true,
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.black45,
                      textColor: Colors.black,
                      tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: infoItem(Icons.check_circle_outline, EdgeInsets.fromLTRB(16, 14, 0, 14), "验证"),
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            "初次使用时需要进行一次登录,以后执行的任何操作只需要输入验证码即可,每验证一次可以维持15分钟免验证操作.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]),
                  ExpansionTile(
                      initiallyExpanded: true,
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.black45,
                      textColor: Colors.black,
                      tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: infoItem(Icons.feedback_outlined, EdgeInsets.fromLTRB(16, 14, 0, 14), "反馈"),
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Text(
                            "可以在`酷安APP`搜索桂工助手N,在应用详情下方评论,或者在Github搜索GlutAssistantN,也可以点击下面的文本联系我:",
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
            ))
          ],
        ),
      ),
    );
  }
}

Widget infoItem(IconData icon, EdgeInsets padding, String title) {
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

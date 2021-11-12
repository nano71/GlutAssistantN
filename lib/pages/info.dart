import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/icons.dart';

class InfoPage extends StatefulWidget {
  final String title;

  const InfoPage({Key? key, this.title = "说明"}) : super(key: key);

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
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "说明",
              InkWell(
                child: const Icon(Icons.close_outlined, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: const Text(
                  "澄清下一些容易被误解的点",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoItem(Icons.info_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "隐私"),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: const Text(
                      "此APP没有请求任何的权限,所有网络通信只请求教务服务器数据以及Github版本更新,不会对其他服务器数据上传.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  infoItem(Icons.info_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "验证"),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: const Text(
                      "初次使用时需要进行一次登录,以后执行的任何操作只需要输入验证码即可,每验证一次可以维持15分钟免验证操作.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  infoItem(Icons.info_outline, const EdgeInsets.fromLTRB(16, 14, 0, 14), "建议"),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: const Text(
                      "可以在`酷安APP`搜索桂工助手N,在应用详情下方评论,或点击以下的方式联系我:",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        const Text(
                          "企鹅:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: "1742968988"));
                                Scaffold.of(context).removeCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(jwSnackBar(true, "已复制到剪切板"));
                              },
                              child: const Text(
                                "1742968988",
                                style: TextStyle(color: Colors.blue),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        const Text(
                          "微信:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Builder(builder: (BuildContext context) {
                          return TextButton(
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: "13520944872"));
                              Scaffold.of(context).removeCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(jwSnackBar(true, "已复制到剪切板"));
                            },
                            child: const Text(
                              "13520944872",
                              style: TextStyle(color: Colors.blue),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
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
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      chevronDown
    ],
  );
}

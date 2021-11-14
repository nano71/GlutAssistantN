import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

class UpdatePage extends StatefulWidget {
  final String title;

  const UpdatePage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getScore();
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
              "获取新版本",
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
                  "会调用浏览器访问",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height - 125,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            launch("https://github.com/ChinaGamer/GlutAssistantN/releases/latest");
                          },
                          child: Text(
                            "点我获取更新",
                            style: TextStyle(fontSize: 18, color: readColor()),
                          ),
                        )
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}

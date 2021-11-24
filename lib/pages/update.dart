import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'mine.dart';

class UpdatePage extends StatefulWidget {
  final String title;

  const UpdatePage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String appName = "";

  String packageName = "";

  String version = "";

  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      print(packageInfo.appName);
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      setState(() {});
    });
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
              child: SizedBox(
                height: 64,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  children: [
                    Image.asset(
                      'images/g.png',
                      width: 72,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      appName,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      version,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(0, 64, 0, 16),
                      child: Text(
                        "选择以下渠道获取更新",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        launch("https://www.coolapk.com/apk/289253");
                      },
                      child: mineItem(Icons.local_mall, const EdgeInsets.fromLTRB(16, 14, 0, 14),
                          "酷安", Colors.green),
                    ),
                    InkWell(
                      onTap: () {
                        launch("https://github.com/ChinaGamer/GlutAssistantN/releases/latest");
                      },
                      child: mineItem(Icons.face, const EdgeInsets.fromLTRB(16, 14, 0, 14),
                          "Github", Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

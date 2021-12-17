import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'mine.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: UpdatePageBody(),
    );
  }
}

class UpdatePageBody extends StatefulWidget {
  const UpdatePageBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UpdatePageBodyState();
}

class UpdatePageBodyState extends State<UpdatePageBody> {
  String appName = "";

  String packageName = "";

  String version = "";

  String buildNumber = "";
  bool newVersion = false;
  bool networkError = false;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      print(packageInfo.appName);
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      if (writeData["newVersion"] != "" && version != writeData["newVersion"]) {
        newVersion = true;
      }
      setState(() {});
    });
    if ("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}" !=
        writeData["newTime"]) {
      getUpdate().then((value) => _next(value));
    }
  }

  _next(List value) {
    if (value.length > 1 && value[1].toString().trim() == version) {
      print("与当前版本一致");
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(true, "暂无新版本更新", 5));
    } else if (value.length == 1) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(false, value[0], 5));
      networkError = true;
    } else {
      if (!newVersion) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "有新版本更新!", 5));
      }
      newVersion = true;
      writeData["newVersion"] = value[1];
      writeData["newBody"] = value[3];
      writeData["githubDownload"] = value[4];
      writeData["newTime"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      writeConfig();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      if (!newVersion) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "获取版本更新数据...", 6));
      }
    });
    return Container(
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
                  InkWell(
                    onTap: () {
                      getUpdate().then((value) => _next(value));
                    },
                    child: Image.asset(
                      'images/g.png',
                      width: 72,
                    ),
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
                  ),
                  newVersion
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mineItem4(Icons.file_upload, const EdgeInsets.fromLTRB(16, 14, 0, 14),
                                "有新版本可以更新!", Colors.red),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                              child: Text(
                                "版本号:" + version + "  >  " + writeData["newVersion"],
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            Text(
                              writeData["newBody"],
                              style: TextStyle(color: Colors.grey),
                            ),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 32, 0, 8),
                              child: Text(
                                "选择以下渠道获取更新",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://www.coolapk.com/apk/289253");
                              },
                              child: mineItem(Icons.local_mall,
                                  const EdgeInsets.fromLTRB(16, 14, 0, 14), "酷安", Colors.green),
                            ),
                            InkWell(
                              onTap: () {
                                launch(writeData["githubDownload"]);
                              },
                              child: mineItem(Icons.face, const EdgeInsets.fromLTRB(16, 14, 0, 14),
                                  "Github", Colors.blueGrey),
                            ),
                          ],
                        )
                      : Container(),
                  (networkError && !newVersion)
                      ? Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 32, 0, 8),
                              child: Text(
                                "选择以下渠道手动获取更新",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://www.coolapk.com/apk/289253");
                              },
                              child: mineItem(Icons.local_mall,
                                  const EdgeInsets.fromLTRB(16, 14, 0, 14), "酷安", Colors.green),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://github.com/nano71/GlutAssistantN/releases/latest");
                              },
                              child: mineItem(Icons.face, const EdgeInsets.fromLTRB(16, 14, 0, 14),
                                  "Github", Colors.blueGrey),
                            ),
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool networkError = false;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    getUpdate().then((value) => _next(value));
  }

  _next(List value) {
    print(value);
    updating = true;
    if (value.length <= 1) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value[0], 5));
      networkError = true;
    }
    setState(() {
      writeData["newVersion"] = value[1];
      writeData["newBody"] = value[3];
      writeData["githubDownload"] = value[4];
    });
    writeConfig();
    checkNewVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      if (!hasNewVersion && !updating) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取更新...", 24));
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
              child: const Icon(FlutterRemix.close_line, size: 24),
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
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取更新...", 24));
                      getUpdate().then((value) => _next(value));
                    },
                    child: Image.asset(
                      'images/ic_launcher-playstore.png',
                      width: 72,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    packageInfo["appName"],
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    packageInfo["version"],
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(0, 64, 0, 16),
                  ),
                  hasNewVersion
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mineItem4(FlutterRemix.lightbulb_flash_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "有新版本可以更新!", Colors.red),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                              child: Text(
                                "版本号:" + packageInfo["version"] + "  >  " + writeData["newVersion"],
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
                              child: mineItem(FlutterRemix.store_2_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "酷安", Colors.green),
                            ),
                            InkWell(
                              onTap: () {
                                launch(writeData["githubDownload"]);
                              },
                              child: mineItem(FlutterRemix.github_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "Github", Colors.blueGrey),
                            ),
                          ],
                        )
                      : Container(),
                  (!networkError && !hasNewVersion)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mineItem4(FlutterRemix.lightbulb_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "当前版本变更", Colors.blue),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                              child: Text(
                                "版本号:" + packageInfo["version"],
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
                                "以下方式,关注项目",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://www.coolapk.com/apk/289253");
                              },
                              child: mineItem(FlutterRemix.store_2_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "酷安", Colors.green),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://github.com/nano71/GlutAssistantN");
                              },
                              child: mineItem(FlutterRemix.github_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "Github", Colors.blueGrey),
                            ),
                          ],
                        )
                      : Container(),
                  (networkError && !hasNewVersion)
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
                              child: mineItem(FlutterRemix.store_2_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "酷安", Colors.green),
                            ),
                            InkWell(
                              onTap: () {
                                launch("https://github.com/nano71/GlutAssistantN/releases/latest");
                              },
                              child: mineItem(FlutterRemix.github_line, const EdgeInsets.fromLTRB(16, 14, 0, 14), "Github", Colors.blueGrey),
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

void checkNewVersion(BuildContext context, {bool skipShowSnackBar = false}) {
  if (writeData["newVersion"] != "") {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    late String message;
    int currentVersion = int.parse(packageInfo["version"].replaceAll(".", ""));
    int compareVersion = int.parse(writeData["newVersion"].replaceAll(".", ""));
    if (currentVersion < compareVersion) {
      hasNewVersion = true;
      message = "发现新版本!";
    } else if (currentVersion == compareVersion) {
      hasNewVersion = false;
      message = "暂无更新!";
    } else {
      hasNewVersion = false;
      message = "测试版本!";
    }
    if (!skipShowSnackBar) ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, message, 5));
  }
}

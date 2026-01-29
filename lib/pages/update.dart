// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

import '/common/get.dart';
import '/common/io.dart';
import '/config.dart';
import '/data.dart';
import '/widget/bars.dart';
import '../type/packageInfo.dart';
import '../widget/dialog.dart';
import 'person.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: UpdatePageBody(),
    );
  }
}

class UpdatePageBody extends StatefulWidget {
  UpdatePageBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UpdatePageBodyState();
}

class UpdatePageBodyState extends State<UpdatePageBody> {
  bool networkError = false;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    getUpdate().then((dynamic result) => _next(result));
  }

  _next(dynamic result) {
    print(result);
    updating = true;
    if (result is String) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, result, 5));
      networkError = true;
    }
    setState(() {
      AppData.persistentData["newVersion"] = result["newVersion"];
      AppData.persistentData["newBody"] = result["newBody"];
      AppData.persistentData["githubDownload"] = result["githubDownload"];
    });
    writeConfig();
    checkNewVersion(false, context);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      if (!AppData.hasNewVersion && !updating) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取更新...", 24));
      }
    });
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        publicTopBar(
            "获取新版本",
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
            readTextColor()),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 64,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: readCardBackgroundColor2(),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取更新...", 24));
                      getUpdate().then((value) => _next(value));
                      // throw UnimplementedError();
                    },
                    child: Image.asset(
                      'images/Frame 1000002879-4.png',
                      width: 72,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  PackageInfo.appName,
                  style: TextStyle(fontSize: 20, color: readTextColor()),
                ),
                Text(
                  PackageInfo.version,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 64, 0, 16),
                ),
                AppData.hasNewVersion
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mineItem4(Remix.lightbulb_flash_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "有新版本可以更新!", Colors.red),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
                            child: Text(
                              "版本号:" + PackageInfo.version + "  >  " + (AppData.persistentData["newVersion"] ?? ""),
                              style: TextStyle(color: readTextColor2()),
                            ),
                          ),
                          Text(
                            AppData.persistentData["newBody"] ?? "",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 32, 0, 8),
                            child: Text(
                              "选择以下渠道获取更新",
                              style: TextStyle(color: readTextColor()),
                            ),
                          ),
                          customInkWell("https://nano71.com/gan/GlutAssistantN.apk", Remix.download_2_line, "直接下载", readColor()),
                          // coolapk(),
                          customInkWell("", Remix.earth_line, "学校官网（暂不可用）", Colors.blueAccent),
                          customInkWell(AppData.persistentData["githubDownload"] ?? "", Remix.github_line, "Github", Colors.blueGrey)
                        ],
                      )
                    : Container(),
                (!networkError && !AppData.hasNewVersion)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mineItem4(Remix.lightbulb_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "当前版本变更", Colors.blue),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
                            child: Text(
                              "版本号:" + PackageInfo.version,
                              style: TextStyle(color: readTextColor2()),
                            ),
                          ),
                          Text(
                            AppData.persistentData["newBody"] ?? "",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 32, 0, 8),
                            child: Text(
                              "以下方式,关注项目",
                              style: TextStyle(color: readTextColor()),
                            ),
                          ),
                          // coolapk(),
                          customInkWell("https://github.com/nano71/GlutAssistantN", Remix.github_line, "Github", Colors.blueGrey),
                          customInkWell("https://nano71.com/gan", Remix.earth_line, "项目官网", Colors.blueAccent)
                        ],
                      )
                    : Container(),
                (networkError && !AppData.hasNewVersion)
                    ? Column(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 32, 0, 8),
                            child: Text(
                              "选择以下渠道手动获取更新",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          customInkWell("https://github.com/nano71/GlutAssistantN/releases/latest", Remix.github_line, "Github", Colors.blueGrey),
                          customInkWell("https://nano71.com/gan", Remix.earth_line, "项目官网", Colors.blueAccent)
                          // coolapk(),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void checkImportantUpdate() {
  print("checkImportantUpdate");
  AppData.canCheckImportantUpdate = false;
  if (AppData.persistentData["newBody"]?.contains("重要更新") ?? false) {
    eventBus.fire(SetPageIndex(index: AppConfig.pageIndex));
    importantUpdateDialog(AppData.homeContext);
  }
}

void checkNewVersion([bool skipShowSnackBar = true, BuildContext? context]) {
  print('checkNewVersion');
  if ((AppData.persistentData["newVersion"] ?? "").isNotEmpty) {
    print('AppData.writeData["newVersion"]:');
    print(AppData.persistentData["newVersion"] ?? "空");
    // print(AppData.persistentData);
    if (!skipShowSnackBar) ScaffoldMessenger.of(context!).removeCurrentSnackBar();
    late String message;
    int currentVersion = int.parse(PackageInfo.version.replaceAll(".", ""));
    int compareVersion = int.parse(AppData.persistentData["newVersion"]!.replaceAll(".", ""));
    if (currentVersion < compareVersion) {
      AppData.hasNewVersion = true;
      message = "发现新版本!";
    } else if (currentVersion == compareVersion) {
      AppData.hasNewVersion = false;
      message = "暂无更新!";
    } else {
      AppData.hasNewVersion = false;
      message = "测试版本!";
    }
    if (!skipShowSnackBar) ScaffoldMessenger.of(context!).showSnackBar(jwSnackBar(1, message, 5));
  }
  print('checkNewVersion end');
}

InkWell coolapk() {
  return customInkWell("https://www.coolapk.com/apk/289253", Remix.store_2_line, "酷安", Colors.green);
}

InkWell customInkWell(String url, IconData icon, String title, Color color) {
  final EdgeInsets padding = EdgeInsets.fromLTRB(16, 14, 0, 14);
  return InkWell(
    onTap: () {
      launch(url);
    },
    child: mineItem(icon, padding, title, color),
  );
}

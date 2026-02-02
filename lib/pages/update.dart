// ignore_for_file: deprecated_member_use


import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

import '/common/get.dart';
import '/config.dart';
import '/data.dart';
import '/widget/bars.dart';
import '../widget/dialog.dart';
import 'mine.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool networkError = false;
  bool updating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!AppData.hasNewVersion){
        checkUpdate();
      }
    });
  }


  checkUpdate(){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "获取更新...", 24));
    if (!updating) {
      updating = true;
      getUpdate().then(next);
    }
  }

  next(dynamic result) {
    if (result is String) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, result, 5));
      networkError = true;
    } else {
      checkNewVersion(false, context);
      networkError = false;
    }

    setState(() {});
    updating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: readBackgroundColor(),
        body:  CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        TopNavigationBar(
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
                      checkUpdate();
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
                  AppData.packageInfo.appName,
                  style: TextStyle(fontSize: 20, color: readTextColor()),
                ),
                Text(
                  AppData.packageInfo.version,
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
                          mineItem4(
                              Remix.lightbulb_flash_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "有新版本可以更新!", Colors.red),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
                            child: Text(
                              "版本号:" + AppData.packageInfo.version + "  >  " + AppData.newVersionNumber,
                              style: TextStyle(color: readTextColor2()),
                            ),
                          ),
                          Text(
                            AppData.newVersionChangelog,
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
                          _CustomInkWell(
                              "https://nano71.com/gan/GlutAssistantN.apk", Remix.download_2_line, "直接下载", readColor()),
                          // coolapk(),
                          _CustomInkWell("", Remix.earth_line, "学校官网（暂不可用）", Colors.blueAccent),
                          _CustomInkWell(AppData.newVersionDownloadUrl, Remix.github_line, "Github", Colors.blueGrey)
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
                              "版本号:" + AppData.packageInfo.version,
                              style: TextStyle(color: readTextColor2()),
                            ),
                          ),
                          Text(
                            AppData.newVersionChangelog,
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
                          _CustomInkWell(
                              "https://github.com/nano71/GlutAssistantN", Remix.github_line, "Github", Colors.blueGrey),
                          _CustomInkWell("https://nano71.com/gan", Remix.earth_line, "项目官网", Colors.blueAccent)
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
                          _CustomInkWell("https://github.com/nano71/GlutAssistantN/releases/latest", Remix.github_line,
                              "Github", Colors.blueGrey),
                          _CustomInkWell("https://nano71.com/gan", Remix.earth_line, "项目官网", Colors.blueAccent)
                          // coolapk(),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ],
    ),);
  }
}

void checkImportantUpdate() {
  print("checkImportantUpdate");
  AppData.canCheckImportantUpdate = false;
  if (AppData.newVersionChangelog.contains("重要更新")) {
    eventBus.fire(SetPageIndex(index: AppConfig.pageIndex));
    importantUpdateDialog(AppData.homeContext);
  }
}

void checkNewVersion([bool skipShowSnackBar = true, BuildContext? context]) {
  print('checkNewVersion');
  if (AppData.newVersionNumber.isNotEmpty) {
    print('newVersion:' + AppData.newVersionNumber);
    // print(AppData.persistentData);
    if (!skipShowSnackBar && context != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
    late String message;
    int currentVersion = int.parse(AppData.packageInfo.version.replaceAll(".", ""));
    int compareVersion = int.parse(AppData.newVersionNumber.replaceAll(".", ""));

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
    if (!skipShowSnackBar && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, message, 5));
    }
  }
  print('checkNewVersion end');
}

InkWell coolapk() {
  return _CustomInkWell("https://www.coolapk.com/apk/289253", Remix.store_2_line, "酷安", Colors.green);
}

InkWell _CustomInkWell(String url, IconData icon, String title, Color color) {
  final EdgeInsets padding = EdgeInsets.fromLTRB(16, 14, 0, 14);
  return InkWell(
    onTap: () {
      launch(url);
    },
    child: LinkItem(icon, padding, title, color),
  );
}

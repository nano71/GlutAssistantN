import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/common/cookie.dart';
import 'package:glutnnbox/config.dart';
import 'package:glutnnbox/get/get.dart';
import 'package:glutnnbox/login/login.dart';
import 'package:glutnnbox/widget/appbars.dart';
import 'package:glutnnbox/widget/sliverlist.dart';
import 'package:http/http.dart';

import 'homecards.dart';

class MaterialAppPageBody extends StatefulWidget {
  const MaterialAppPageBody({Key? key}) : super(key: key);

  @override
  MaterialAppBody createState() => MaterialAppBody();
}

class MaterialAppHome extends StatelessWidget {
  const MaterialAppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: MaterialAppPageBody(),
      appBar: null,
      bottomNavigationBar: PageControl(),
    );
  }
}

class MaterialAppBody extends State<MaterialAppPageBody> {
  final TextEditingController _textFieldController = TextEditingController();

  Uint8List _codeImgSrc = const Base64Decoder().convert(
      "iVBORw0KGgoAAAANSUhEUgAAAEgAAAAeCAYAAACPOlitAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAHYcAAB2HAY/l8WUAAABYSURBVGhD7dChAcAgEMDAb/ffGSpqIQvcmfg86zMcvX85MCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBl3NbAiZBDiX3e/AAAAAAElFTkSuQmCC");
  Map<String, String> headers = {"cookie": ""};
  int _week = 1;

  @override
  void initState() {
    super.initState();
    _getCode();
  }

  void _getCode() async {
    try {
      setState(() {
        _textFieldController.text = "";
      });
      print("getCode...");
      var response = await get(Global.getCodeUrl).timeout(const Duration(milliseconds: 6000));
      parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _codeImgSrc = response.bodyBytes;
      });
    } catch (e) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(false, "网络错误"));
    }
  }

  void _codeCheck() async {
    void _next(String value) {
      if (value == "success") {
        _loginJW();
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        setState(() {
          _textFieldController.text = "";
        });
      }
    }

    await codeCheck(_textFieldController.text.toString()).then((String value) => _next(value));
  }

  void _loginJW() async {
    void _next(String value) {
      if (value == "success") {
        Global.logined = true;
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "登陆成功"));
        _getWeek();
      } else if (value == "fail") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "请重试"));
        _getCode();
      } else {
        if (Global.logined) {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(jwSnackBar(false, "登录成功,但程序发生了错误"));
          _getCode();
        }
      }
    }

    print(_textFieldController.text.toString());
    await login("5191963403", "sr20000923++", _textFieldController.text.toString())
        .then((String value) => _next(value));
  }

  void _getWeek() async {
    setState(() {
      _textFieldController.text = "";
    });
    print("_getWeek...");
    await getWeek().then((int day) => setState(() => _week = day));
    getSchedule();
  }

  String _tomorrowText() {
    print(Global.tomorrowSchedule);
    return Global.tomorrowSchedule ? "明天" : "明天没课哦";
  }

  String _todayText() {
    return Global.todaySchedule ? "今天的" : "今天没课哦";
  }

  TextStyle _tomorrowAndTodayTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black54, decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(physics: const NeverScrollableScrollPhysics(), controller: Global.pageControl,
        // onPageChanged: (int index) {
        //   setState(() {
        //     if (Global.pageIndex != index) Global.pageIndex = index;
        //   });
        //   print(Global.pageIndex);
        // },
        children: [
          Container(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  indexZeroAppBar,
                  SliverToBoxAdapter(
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        textDirection: TextDirection.ltr,
                        children: [
                          // InkWell(
                          //   child: _codeImgSrc.length > 1
                          //       ? Image.memory(_codeImgSrc, height: 25)
                          //       : Container(
                          //           height: 25,
                          //         ),
                          //   onTap: () {
                          //     _getCode();
                          //   },
                          // ),
                          // TextField(
                          //   controller: _textFieldController,
                          // ),
                          // FlatButton(
                          //   child: const Text('提交'),
                          //   onPressed: () {
                          //     if (Global.logined) {
                          //       _getWeek();
                          //     } else {
                          //       _codeCheck();
                          //     }
                          //   },
                          // ),
                          HomeCard(),
                          HomeCards(),
                          Container(
                              child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_todayText(), style: _tomorrowAndTodayTextStyle()),
                          ))
                        ]),
                  )),
                  ToDayCourse(),
                  SliverToBoxAdapter(
                      child: Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_tomorrowText(), style: _tomorrowAndTodayTextStyle())),
                  )),
                  TomorrowCourse(),
                ],
              )),
          Container(
            color: Colors.blue,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text("2"),
          ),
          Container(
            color: Colors.red,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text("3"),
          )
        ]);
  }
}

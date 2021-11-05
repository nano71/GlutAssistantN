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
  int weekDay = 12;

  @override
  void initState() {
    super.initState();
    _getCode();
  }

  void _getCode() async {
    try {
      print("getCode...");
      var response = await get(Global.getCodeUrl).timeout(const Duration(milliseconds: 6000));
      parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _codeImgSrc = response.bodyBytes;
      });
      print(response.bodyBytes.length);
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
    setState(() {
      _textFieldController.text = "";
    });
    print("loginJW...");
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

    await login("5191963403", "sr20000923++", _textFieldController.text.toString())
        .then((String value) => _next(value));
  }

  String _weekProgressText() {
    return (weekDay * 5).toString() + "%";
  }

  double _weekProgressDouble() {
    return weekDay * 5 / 100;
  }

  String _weekText() {
    if (weekDay >= 10) {
      return "学期过半,珍惜当下";
    } else if (weekDay >= 17) {
      return "期末来临,复习为重";
    } else if (weekDay >= 1) {
      return "开学不久,好好玩吧";
    } else if (weekDay == 20) {
      return "学期即将结束";
    } else {
      return "";
    }
  }


  void _getWeek() async {
    print("_getWeek...");
    await getWeek().then((int day) => setState(() => weekDay = day));
    getSchedule();
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        textDirection: TextDirection.ltr,
                        children: [
                          InkWell(
                            child: _codeImgSrc.length > 1
                                ? Image.memory(_codeImgSrc, height: 25)
                                : Container(
                                    height: 25,
                                  ),
                            onTap: () {
                              _getCode();
                            },
                          ),
                          TextField(
                            controller: _textFieldController,
                          ),
                          FlatButton(
                            child: const Text('提交'),
                            onPressed: () {
                              if (Global.logined) {
                                _getWeek();
                              } else {
                                _codeCheck();
                              }
                            },
                          ),
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Colors.blue,
                            ),
                            child: Stack(children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 18, 0),
                                  child: SizedBox(
                                    //限制进度条的高度
                                    height: 60.0,
                                    //限制进度条的宽度
                                    width: 60,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 8,
                                        //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
                                        value: _weekProgressDouble(),
                                        //背景颜色
                                        backgroundColor: Color.fromARGB(128, 255, 255, 255),
                                        //进度颜色
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(Colors.white)),
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 32, 0),
                                    child: Text(_weekProgressText(),
                                        style: TextStyle(color: Colors.white)),
                                  )),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 24, 90, 0),
                                  child: Text(
                                    "第$weekDay周",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 90, 24),
                                    child: Text(_weekText(), style: TextStyle(color: Colors.white)),
                                  )),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      // height: 40,
                                      width: 60,
                                      // decoration: const BoxDecoration(
                                      //   borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                      //   color: Color.fromARGB(32, 0, 0, 0),
                                      // ),
                                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                      child: Center(
                                          child: Text(DateTime.now().weekday.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14)))))
                            ]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                                height: 100,
                                width: MediaQuery.of(context).size.width / 3 - 48 / 3,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                    color: Color(0xfffafafa)),
                                child: Stack(children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(0, 0, 0, 24),
                                          child: Icon(
                                            Icons.create,
                                            color: Colors.blue,
                                          ))),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(0, 24, 0, 0),
                                          child: Text("课程修改")))
                                ]),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                                height: 100,
                                width: MediaQuery.of(context).size.width / 3 - 48 / 3,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                    color: Color(0xfffafafa)),
                                child: Stack(children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(0, 0, 0, 24),
                                          child: Icon(
                                            Icons.create,
                                            color: Colors.blue,
                                          ))),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(0, 24, 0, 0),
                                          child: Text("考试一览")))
                                ]),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
                                height: 100,
                                width: MediaQuery.of(context).size.width / 3 - 48 / 3,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                    color: Color(0xfffafafa)),
                                child: Stack(children: [
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                                          child: const Icon(
                                            Icons.library_books_sharp,
                                            color: Colors.blue,
                                          ))),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                          margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                                          child: const Text("我的考试")))
                                ]),
                              )
                            ],
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("接下来",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    decoration: TextDecoration.none)),
                          )
                        ]),
                  )),
                  MaterialAppSliverList(),
                  SliverToBoxAdapter(
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("明天",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              decoration: TextDecoration.none)),
                    ),
                  )),
                  MaterialAppSliverList(),
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

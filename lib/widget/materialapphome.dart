import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutnnbox/common/global.dart';
import 'package:glutnnbox/widget/appbars.dart';
import 'package:glutnnbox/widget/sliverlist.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;
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

  late Uint8List _codeImgSrc;
  Map<String, String> headers = {"cookie": ""};
  num _week = 12;

  @override
  void initState() {
    super.initState();
    _getCode();
    print(DateTime
        .now()
        .weekday);
  }

  void _getCode() async {
    Map<String, String> headers = {};
    try {
      print("_getCode");
      var response = await get(Global.getCodeUrl, headers: headers)
          .timeout(const Duration(milliseconds: 6000));
      _parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _codeImgSrc = response.bodyBytes;
      });
    } catch (e) {
      print(e);
    }
  }

  void _codeCheck() async {
    final _url4 = Uri.http("jw.glutnn.cn", "/academic/checkCaptcha.do",
        {"captchaCode": _textFieldController.text.toString()});
    var postData = {
      "captchaCode": _textFieldController.text.toString(),
    };
    var response = await post(_url4, body: postData, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(milliseconds: 6000));

    if (response.body == "true") {
      _loginJW();
    } else {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Row(
          children: const <Widget>[
            Icon(
              Icons.mood_bad,
              color: Colors.red,
            ),
            Text('验证码错误')
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        _textFieldController.text = "";
      });
    }
  }

  void _loginJW() async {
    try {
      print("_loginJW");
      var postData = {
        "j_username": "5191963403",
        "j_password": "sr20000923++",
        "j_captcha": _textFieldController.text.toString()
      };
      var response =
      await post(Global.loginUrl, body: postData, headers: {"cookie": mapCookieToString()})
          .timeout(const Duration(milliseconds: 6000));
      if (response.headers['location'] == "/academic/index_new.jsp") {
        // 获取新令牌
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(Global.jwSuccessSnackBar);
        setState(() {
          _textFieldController.text = "";
        });
        _parseRawCookies(response.headers['set-cookie']);
        _loginJW2();
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(Global.jwErrorReSnackBar);
        setState(() {
          _textFieldController.text = "";
        });
        _getCode();
      }
    } catch (e) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(Global.jwErrorSnackBar);
      _getCode();
      setState(() {
        _textFieldController.text = "";
      });
    }
  }

  String _weekProgressText() {
    return (_week * 5).toString() + "%";
  }

  num _weekProgressNum() {
    return 1;
  }

  double _weekProgressDouble() {
    return _week * 5 / 100;
  }

  _weekText() {
    if (_week >= 10) {
      return "学期过半,珍惜当下";
    } else if (_week >= 17) {
      return "期末来临,复习为重";
    } else if (_week >= 1) {
      return "开学不久,好好玩吧";
    } else if (_week == 20) {
      return "学期即将结束";
    }
  }

  void _loginJW2() async {
    print("_loginJW2");
    // var response = await get(_url3, headers: {"cookie": mapCookieToString()})
    //     .timeout(const Duration(milliseconds: 6000));
    _getWeek();
  }

  Future _getWeek() async {
    print("_getLeftList");
    var response = await get(Global.getWeekUrl, headers: {"cookie": ''})
        .timeout(const Duration(milliseconds: 6000));
    Dom.Document document = parse(gbk.decode(response.bodyBytes));
    String weekHtml = document.querySelector("#date p span")!.innerHtml.trim();
    setState(() =>
    {
      _week =
          int.parse(weekHtml.substring(weekHtml.indexOf("第") + 1, weekHtml.indexOf("周")).trim())
    });
    _getKB();
  }

  List<List<List<List<String>>>> kb = [];

  void _getKB() async {
    print("_getKB");
    final _courseUrl = Uri.http("jw.glutnn.cn", "/academic/student/currcourse/currcourse.jsdo",
        {"year": "41", "term": "1"});
    var response = await get(_courseUrl, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(milliseconds: 6000));
    Dom.Document document = parse(gbk.decode(response.bodyBytes));
    var list = document.querySelectorAll(".infolist_common");
    //时间,地点 querySelectorAll("table.none>tbody>tr")
    num listLength = document
        .querySelectorAll(".infolist_common")
        .length - 23;
    Map<String, dynamic> weekList = {
      "星期一": 1,
      "星期二": 2,
      "星期三": 3,
      "星期四": 4,
      "星期五": 5,
      "星期六": 6,
      "星期日": 7
    };
    for (var i = 1; i < 21; i++) {
      kb[i] = [];
      for (var j = 1; j < 8; j++) {
        kb[i][j] = [];
        for (var k = 1; k < 12; k++) {
          kb[i][j][k] = ["null", "null", "null"];
        }
      }
    }
    for (var i = 0; i < listLength; i++) {
      for (var j = 0; j < list[i]
          .querySelectorAll("table.none>tbody>tr")
          .length; j++) {
        //课节
        String kj = list[i]
            .querySelectorAll("table.none>tbody>tr")[j]
            .querySelectorAll("td")[2]
            .innerHtml
            .trim();
        //周次
        String zc = list[i]
            .querySelectorAll("table.none>tbody>tr")[j]
            .querySelectorAll("td")[0]
            .innerHtml
            .trim();
        kj = kj.substring(kj.indexOf("第") + 1, kj.length - 1);
        List kjList = kj.trim().split('-');
        zc = zc.substring(0, zc.length - 1);
        List zcList = zc.trim().split('-');
        String week = list[i]
            .querySelectorAll("table.none>tbody>tr")[j]
            .querySelectorAll("td")[1]
            .innerHtml
            .trim();
        String area = list[i]
            .querySelectorAll("table.none>tbody>tr")[j]
            .querySelectorAll("td")[3]
            .innerHtml
            .trim();

        if (kjList.length > 1 && week != "&nbsp;") {
          for (var k = int.parse(kjList[0]); k < int.parse(kjList[1]) + 1; k++) {
            if (zcList.length > 1) {
              for (var l = int.parse(zcList[0]); l < int.parse(zcList[1]) + 1; l++) {
                setState(() {
                  kb[l][int.parse(weekList[list[i]
                      .querySelectorAll("table.none>tbody>tr")[j]
                      .querySelectorAll("td")[1]
                      .innerHtml
                      .trim()
                      .toString()])][k] = [
                    //课程名
                    list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                    //老师名字
                    list[i]
                        .querySelectorAll("a.infolist")
                        .length > 1
                        ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim()
                        : "null",
                    //上课地点
                    area != "&nbsp" ? area : "null"
                  ];
                });
              }
            } else {
              setState(() {
                kb[int.parse(zc.substring(kj.indexOf("第") + 1, zc.length - 1))][int.parse(weekList[
                list[i]
                    .querySelectorAll("table.none>tbody>tr")[j]
                    .querySelectorAll("td")[1]
                    .innerHtml
                    .trim()
                    .toString()])][k] = [
                  //课程名
                  list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                  //老师名字
                  list[i]
                      .querySelectorAll("a.infolist")
                      .length > 1
                      ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim()
                      : "null",
                  //上课地点
                  area != "&nbsp" ? area : "null"
                ];
              });
            }
          }
        }
      }
    }
    // final directory = await getApplicationDocumentsDirectory();
    // print(directory.path);

    print(kb[10][4][1]);
  }

  String mapCookieToString() {
    String result = '';
    Global.cookie.forEach((key, value) {
      result += '$key=$value; ';
    });
    return result;
  }

  void _parseRawCookies(dynamic rawCookie) {
    for (var item in rawCookie.split(',')) {
      List<String> cookie = item.split(';')[0].split('=');
      Global.cookie[cookie[0]] = cookie[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(physics: NeverScrollableScrollPhysics(), controller: Global.pageControl,
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
                              // InkWell(
                              //   child: Image.memory(_codeImgSrc, height: 25),
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
                              //     _codeCheck();
                              //   },
                              // ),
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
                                        "第$_week周",
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
                                        child: Text(
                                            _weekText(), style: TextStyle(color: Colors.white)),
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
                                              child: Text(DateTime
                                                  .now()
                                                  .weekday
                                                  .toString(),
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
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 3 - 48 / 3,
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
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 3 - 48 / 3,
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
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 3 - 48 / 3,
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

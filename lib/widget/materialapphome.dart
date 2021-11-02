import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/widget/sliverappbar.dart';
import 'package:glutnnbox/widget/sliverlist.dart';
import 'package:http/http.dart';

class MaterialAppPageControl extends StatefulWidget {
  const MaterialAppPageControl({Key? key}) : super(key: key);

  @override
  MaterialAppBottomNavigationBar createState() =>
      MaterialAppBottomNavigationBar();
}

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
      bottomNavigationBar: MaterialAppPageControl(),
    );
  }
}

class MaterialAppBottomNavigationBar extends State<MaterialAppPageControl> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      border: const Border(
          top: BorderSide(
        color: Colors.white,
      )),
      backgroundColor: Colors.white,
      currentIndex: _index,
      onTap: (index) {
        setState(() {
          _index = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.home,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.business,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.mood,
            ),
            label: ''),
      ],
    );
  }
}

class MaterialAppBody extends State<MaterialAppPageBody> {
  Map<String, String> _cookie = Map();
  late Uint8List _imgUrl;
  TextEditingController _textFieldController = new TextEditingController();
  final _url = Uri.http("jw.glutnn.cn", "/academic/getCaptcha.do");
  final _url2 = Uri.http("jw.glutnn.cn", "/academic/j_acegi_security_check");
  final _url3 = Uri.http("jw.glutnn.cn", "/academic/index_new.jsp");
  final _url5 = Uri.http("jw.glutnn.cn", "/academic/listLeft.do");
  Map<String, String> headers = {"cookie": ""};
  num _week = 12;

  @override
  void initState() {
    super.initState();
    _getCode();
  }

  Future<Map<String, dynamic>> _getCode() async {
    Map<String, String> headers = {};
    try {
      print("_getCode");
      var response = await get(_url, headers: headers)
          .timeout(const Duration(milliseconds: 6000));
      _parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _imgUrl = response.bodyBytes;
      });
      var data = {'image': response.bodyBytes};
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<dynamic> _codeCheck() async {
    final _url4 = Uri.http("jw.glutnn.cn", "/academic/checkCaptcha.do",
        {"captchaCode": _textFieldController.text.toString()});
    var postData = {
      "captchaCode": _textFieldController.text.toString(),
    };
    var response = await post(_url4,
            body: postData, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(milliseconds: 6000));
    print("request");
    print(response.request);
    print("body");
    print(response.body);
    if (response.body == "true") {
      print(_cookie);
      _loginJW();
    }
  }

  Future<dynamic> _loginJW() async {
    try {
      print("_loginJW");
      var postData = {
        "j_username": "5191963403",
        "j_password": "sr20000923++",
        "j_captcha": _textFieldController.text.toString()
      };
      var response = await post(_url2,
              body: postData, headers: {"cookie": mapCookieToString()})
          .timeout(const Duration(milliseconds: 6000));
      print(response.headers['location']);
      if (response.headers['location'] == "/academic/index_new.jsp") {
        // 获取新令牌
        _parseRawCookies(response.headers['set-cookie']);
        print("yes");
        _loginJW2();
        return {'success': true, 'cookie': mapCookieToString()};
      } else
        print("no");
      _textFieldController.text = "";
      _getCode();
      return {'success': false, 'cookie': ''};
    } catch (e) {
      return {'success': false, 'cookie': ''};
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

  Future<dynamic> _loginJW2() async {
    print("_loginJW2");
    print(_cookie);
    var response = await get(_url3, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(milliseconds: 6000));
    _getLeftList();
  }

  Future _getLeftList() async {
    print("_getLeftList");
    var response = await get(_url5, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(milliseconds: 6000));
    // print(response.body.indexOf('<span>'));
    // print(response.body.indexOf('</span>') - response.body.indexOf('<span>') );
    setState(() => {
          _week = int.parse(response.body
                  .trim()
                  .substring(response.body.indexOf('<span>'),
                      response.body.indexOf('</span>') - 50)
                  .trim()[2] +
              response.body
                  .trim()
                  .substring(response.body.indexOf('<span>'),
                      response.body.indexOf('</span>') - 50)
                  .trim()[3])
        });
  }

  String mapCookieToString() {
    String result = '';
    _cookie.forEach((key, value) {
      result += '$key=$value; ';
    });
    return result;
  }

  void _parseRawCookies(dynamic rawCookie) {
    for (var item in rawCookie.split(',')) {
      List<String> cookie = item.split(';')[0].split('=');
      _cookie[cookie[0]] = cookie[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(scrollDirection: Axis.horizontal, children: [
      Container(
          color: Colors.white,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              MaterialAppSliverAppBar(),
              SliverToBoxAdapter(
                  child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    textDirection: TextDirection.ltr,
                    children: [
                      // Image.memory(_imgUrl),
                      // TextField(
                      //   controller: _textFieldController,
                      // ),
                      // FlatButton(
                      //   child: Text('提交'),
                      //   onPressed: () {
                      //     print("提交");
                      //     print(_textFieldController.text);
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
                                    backgroundColor:
                                        Color.fromARGB(128, 255, 255, 255),
                                    //进度颜色
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white)),
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
                                child: Text(_weekText(),
                                    style: TextStyle(color: Colors.white)),
                              )),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  color: Color.fromARGB(32, 0, 0, 0),
                                ),
                                margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: const Icon(
                                  Icons.create,
                                  color: Colors.white,
                                )),
                          )
                        ]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                            height: 100,
                            width:
                                MediaQuery.of(context).size.width / 3 - 48 / 3,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6.0)),
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
                            width:
                                MediaQuery.of(context).size.width / 3 - 48 / 3,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6.0)),
                                color: Color(0xfffafafa)),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
                            height: 100,
                            width:
                                MediaQuery.of(context).size.width / 3 - 48 / 3,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6.0)),
                                color: Color(0xfffafafa)),
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
        child: Text("2"),
      ),
      Container(
        color: Colors.red,
        child: Text("3"),
      )
    ]);
  }
}

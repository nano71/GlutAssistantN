import 'package:flutter/cupertino.dart';
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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _index,
      onTap: (index) {
        setState(() {
          _index = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '首页'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.business,
            ),
            label: '课表'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.mood,
            ),
            label: '我的'),
      ],
    );
  }
}

class MaterialAppBody extends State<MaterialAppPageBody> {
  dynamic _cookie;
  dynamic _imgUrl;
  TextEditingController _textFieldController = new TextEditingController();
  final _url = Uri.http("jw.glutnn.cn", "/academic/getCaptcha.do");
  final _url2 = Uri.http("jw.glutnn.cn", "/academic/j_acegi_security_check");
  Map<String, String> headers = {"cookie": ""};

  @override
  void initState() {
    super.initState();
    _getCode();
  }

  Future<Map<String, dynamic>> _getCode() async {
    Map<String, String> headers = {"cookie": ""};
    try {
      //无cookie
      var response = await get(_url, headers: headers);
      _parseRawCookies(response.headers['set-cookie'].toString());
      _imgUrl = response.bodyBytes;
      var data = {'image': response.bodyBytes};
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'data': e};
    }
  }

  Future<dynamic> _loginJW() async {
    try {
      var postData = {
        "j_username": "5191963403",
        "j_password": "sr20000923++",
        "j_captcha": _textFieldController.text.toString()
      };
      var response =
          await post(_url2, body: postData, headers: {"cookie": _cookie});
      print(response.headers['location']);
      if (response.headers['location']!=null) {
        // 获取新令牌
        _parseRawCookies(response.headers['set-cookie'].toString());
        print("yes");
        return {'success': true, 'cookie': mapCookieToString()};
      } else
        print("no");
        return {'success': false, 'cookie': ''};
    } catch (e) {
      return {'success': false, 'cookie': ''};
    }
  }

  String mapCookieToString() {
    String result = '';
    _cookie.forEach((key, value) {
      result += '$key=$value; ';
    });
    return result;
  }

  void _parseRawCookies(String rawCookie) {
    for (var item in rawCookie.split(',')) {
      List<String> cookie = item.split(';')[0].split('=');
      _cookie = cookie[1];
    }
    print(_cookie);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(scrollDirection: Axis.horizontal, children: [
      Container(
          color: Colors.white,
          child: CustomScrollView(
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
                      Image.memory(_imgUrl),
                      TextField(
                        controller: _textFieldController,
                      ),
                      FlatButton(
                        child: Text('提交'),
                        onPressed: () {
                          print("提交");
                          print(_textFieldController.text);
                          _loginJW();

                        },
                      ),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                            color: Color(0xfffafafa)),
                        child: Stack(overflow: Overflow.clip, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 100,
                                decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xffDCF3FF),
                                          offset: Offset(10.0, 0.0),
                                          //阴影xy轴偏移量
                                          blurRadius: 8.0,
                                          //阴影模糊程度
                                          spreadRadius: 0 //阴影扩散程度
                                          )
                                    ],
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6.0),
                                        bottomLeft: Radius.circular(6.0)),
                                    color: Colors.lightBlue),
                              )
                            ],
                          ),
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
                        child: Text("接下来的课",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
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
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                          decoration: TextDecoration.none)),
                ),
              )),
              MaterialAppSliverList()
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

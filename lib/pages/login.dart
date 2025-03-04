import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:remixicon/remixicon.dart';

import '/common/cookie.dart';
import '/common/get.dart';
import '/common/io.dart';
import '/common/login.dart';
import '/widget/bars.dart';
import '../config.dart';
import '../data.dart';
import 'layout.dart';

class LoginPage extends StatefulWidget {
  final String title;

  LoginPage({Key? key, this.title = "表单"}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final ScrollController _scrollController = ScrollController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final checkCodeController = TextEditingController();
  String message = "不辜负每一次相遇";
  Color messageColor = Colors.grey;
  Uint8List _codeImgSrc = Base64Decoder().convert(
      "iVBORw0KGgoAAAANSUhEUgAAAEgAAAAeCAYAAACPOlitAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAHYcAAB2HAY/l8WUAAABYSURBVGhD7dChAcAgEMDAb/ffGSpqIQvcmfg86zMcvX85MCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBl3NbAiZBDiX3e/AAAAAAElFTkSuQmCC");
  String buttonTitle = "即刻登录";
  bool logged = false;

  FocusNode studentIdFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode checkCodeFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    studentIdController.text = AppData.persistentData["username"] ?? "";
    passwordController.text = AppData.persistentData["password"] ?? "";
    _getCode();
  }

  void _check() {
    if (!logged) {
      FocusScope.of(context).requestFocus(FocusNode());
      if (passwordController.text.isEmpty && studentIdController.text.isEmpty) {
        setState(() {
          messageColor = Colors.red;
          message = "学号和密码不为空...";
        });
      } else if (studentIdController.text.length != 10) {
        setState(() {
          messageColor = Colors.red;
          message = "学号长度不对...";
        });
      } else if (passwordController.text.isEmpty) {
        setState(() {
          messageColor = Colors.red;
          message = "你忘输密码了...";
        });
      } else {
        _codeCheck();
      }
    }
  }

  void _getCode() async {
    try {
      print("getCode...");
      var response = await get(AppConfig.getCodeUrl).timeout(Duration(milliseconds: 6000));
      parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _codeImgSrc = response.bodyBytes;
      });
    } catch (e) {
      setState(() {
        messageColor = Colors.red;
        message = "网络错误";
      });
    }
  }

  void _codeCheck() async {
    void _next(String value) {
      if (value == "success") {
        setState(() {
          buttonTitle = "马上就好,获取数据中...";
        });
        _loginJW();
      } else {
        setState(() {
          messageColor = Colors.red;
          message = "验证码错误!";
          buttonTitle = "请检查后再试一次";
        });
      }
    }

    await codeCheck(checkCodeController.text.toString()).then((String value) => _next(value));
  }

  void _loginJW() async {
    String _studentId = studentIdController.text.toString();
    String _password = passwordController.text.toString();
    Future<void> _next(String value) async {
      if (value == "success") {
        AppConfig.login = true;
        logged = true;
        setState(() {
          messageColor = Colors.blue;
          message = "登录成功";
          buttonTitle = "马上就好,处理数据中...";
        });
        AppData.persistentData["username"] = _studentId;
        AppData.persistentData["password"] = _password;
        await getName();
        await writeConfig();
        print("initSchedule End");
        eventBus.fire(SetPageIndex());
        Navigator.pushAndRemoveUntil(
          context,
          AppRouter(Layout(refresh: true)),
          (route) => false,
        );
      } else if (value == "fail") {
        setState(() {
          messageColor = Colors.red;
          message = "学号或密码有误";
          buttonTitle = "请检查后再试一次";
        });
        _getCode();
      } else {
        if (AppConfig.login) {
          setState(() {
            messageColor = Colors.yellow;
            message = "登录成功,但程序发生了错误";
          });
          _getCode();
        }
      }
    }

    await login(studentIdController.text.toString(), passwordController.text.toString(), checkCodeController.text.toString()).then((String value) => _next(value));
  }

  void _tap() {
    _scrollController.animateTo(
      56.0, //滚动到底部
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
                "桂工助手N",
                InkWell(
                  child: Icon(Remix.close_line, size: 24),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  message,
                  style: TextStyle(color: messageColor),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7 - 125,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0, //宽度
                            color: Color(0xfff1f1f1), //边框颜色
                          ),
                        ),
                      ),
                      child: TextField(
                        onTap: () {
                          _tap();
                        },
                        cursorColor: readColor(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        focusNode: studentIdFocusNode,
                        controller: studentIdController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Remix.user_3_line,
                            color: studentIdFocusNode.hasFocus ? readColor() : null,
                          ),
                          border: InputBorder.none,
                          hintText: "请输入学号", //类似placeholder效果
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0, //宽度
                            color: Color(0xfff1f1f1), //边框颜色
                          ),
                        ),
                      ),
                      child: TextField(
                        onTap: () {
                          _tap();
                        },
                        focusNode: passwordFocusNode,
                        cursorColor: readColor(),
                        controller: passwordController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Remix.key_line,
                            color: passwordFocusNode.hasFocus ? readColor() : null,
                          ),
                          border: InputBorder.none,
                          hintText: "请输入密码", //类似placeholder效果
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              onTap: () {
                                _tap();
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: readColor(),
                              focusNode: checkCodeFocusNode,
                              controller: checkCodeController,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Remix.magic_line,
                                  color: checkCodeFocusNode.hasFocus ? readColor() : null,
                                ),
                                border: InputBorder.none,
                                hintText: "请输入验证码", //类似placeholder效果
                              ),
                            ),
                          ),
                          InkWell(
                            child: _codeImgSrc.length > 1
                                ? Image.memory(
                                    _codeImgSrc,
                                    height: 25,
                                    width: 80,
                                  )
                                : Container(
                                    height: 25,
                                  ),
                            onTap: () {
                              _getCode();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              //设置水波纹颜色
                              overlayColor: WidgetStateProperty.all(Colors.yellow),
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                return readColor();
                              }),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                            ),
                            child: Text(
                              buttonTitle,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {
                              _check();
                            }),
                      ),
                    )
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

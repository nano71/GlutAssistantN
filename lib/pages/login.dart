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
  final ScrollController scrollController = ScrollController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final checkCodeController = TextEditingController();
  String message = "不辜负每一次相遇";
  Color messageColor = Colors.grey;
  Uint8List verificationCodeImageBytes = Base64Decoder().convert(
      "iVBORw0KGgoAAAANSUhEUgAAAEgAAAAeCAYAAACPOlitAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAHYcAAB2HAY/l8WUAAABYSURBVGhD7dChAcAgEMDAb/ffGSpqIQvcmfg86zMcvX85MCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBl3NbAiZBDiX3e/AAAAAAElFTkSuQmCC");
  String buttonTitle = "即刻登录";
  bool logged = false;

  FocusNode studentIdFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode checkCodeFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    studentIdController.text = AppData.studentId;
    passwordController.text = AppData.password;
    getVerificationCode();
  }

  void precheck() {
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
        checking();
      }
    }
  }

  void getVerificationCode() async {
    try {
      print("getCode...");
      var response = await get(AppConfig.getCodeUrl).timeout(Duration(milliseconds: 6000));
      parseRawCookies(response.headers['set-cookie']);
      setState(() {
        verificationCodeImageBytes = response.bodyBytes;
      });
    } catch (e) {
      print('LoginPageState._getCode Error');
      print(e);
      setState(() {
        messageColor = Colors.red;
        message = AppConfig.retryError;
      });
    }
  }

  void checking() async {
    void next(String value) {
      if (value == "success") {
        setState(() {
          buttonTitle = "马上就好,获取数据中...";
        });
        logging();
      } else {
        setState(() {
          messageColor = Colors.red;
          message = "验证码错误!";
          buttonTitle = "请检查后再试一次";
        });
      }
    }

    await checkVerificationCode(checkCodeController.text).then(next);
  }

  void logging() async {
    String studentId = studentIdController.text;
    String password = passwordController.text;
    Future<void> next(String value) async {
      if (value == "success") {
        AppData.isLoggedIn = true;
        logged = true;
        setState(() {
          messageColor = Colors.blue;
          message = "登录成功";
          buttonTitle = "马上就好,处理数据中...";
        });
        AppData.studentId = studentId;
        AppData.password = password;
        await getStudentName();
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
        getVerificationCode();
      } else {
        if (AppData.isLoggedIn) {
          setState(() {
            messageColor = Colors.yellow;
            message = "登录成功,但应用程序发生了异常";
          });
          getVerificationCode();
        }
      }
    }

    await login(studentIdController.text, passwordController.text, checkCodeController.text).then(next);
  }

  void onInputTap() {
    scrollController.animateTo(
      56.0, //滚动到底部
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: CustomScrollView(
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          TopNavigationBar(
              "桂工助手N",
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
                    child: TextField(
                      onTap: onInputTap,
                      style: TextStyle(color: readTextColor()),
                      cursorColor: readColor(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      focusNode: studentIdFocusNode,
                      controller: studentIdController,
                      decoration: InputDecoration(
                          icon: Icon(
                            Remix.user_3_line,
                            color: studentIdFocusNode.hasFocus ? readColor() : readTextColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "请输入学号", //类似placeholder效果
                          hintStyle: TextStyle(color: readTextColor2())),
                    ),
                  ),
                  _line,
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: TextField(
                      onTap: onInputTap,
                      style: TextStyle(color: readTextColor()),
                      focusNode: passwordFocusNode,
                      cursorColor: readColor(),
                      controller: passwordController,
                      decoration: InputDecoration(
                          icon: Icon(
                            Remix.key_line,
                            color: passwordFocusNode.hasFocus ? readColor() : readTextColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "请输入密码", //类似placeholder效果
                          hintStyle: TextStyle(color: readTextColor2())),
                    ),
                  ),
                  _line,
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            onTap: onInputTap,
                            style: TextStyle(color: readTextColor()),
                            keyboardType: TextInputType.number,
                            cursorColor: readColor(),
                            focusNode: checkCodeFocusNode,
                            controller: checkCodeController,
                            decoration: InputDecoration(
                                icon: Icon(
                                  Remix.magic_line,
                                  color: checkCodeFocusNode.hasFocus ? readColor() : readTextColor(),
                                ),
                                border: InputBorder.none,
                                hintText: "请输入验证码", //类似placeholder效果
                                hintStyle: TextStyle(color: readTextColor2())),
                          ),
                        ),
                        InkWell(
                          child: verificationCodeImageBytes.length > 1
                              ? Image.memory(
                                  verificationCodeImageBytes,
                                  height: 25,
                                  width: 80,
                                )
                              : Container(
                                  height: 25,
                                ),
                          onTap: getVerificationCode,
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
                          shape:
                              WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                        ),
                        child: Text(
                          buttonTitle,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                        onPressed: precheck,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Container _line = Container(
  width: double.infinity,
  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
  color: readLineColor(),
  height: 1,
);

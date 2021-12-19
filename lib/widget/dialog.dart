import 'package:flutter/material.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/login.dart';
import 'package:glutassistantn/common/style.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/pages/init.dart';
import 'package:http/http.dart';

import '../config.dart';
import 'bars.dart';

class CodeCheckDialog {
  static final checkCodeController = TextEditingController();
  static String message = "不辜负每一次相遇";
  static Color messageColor = Colors.grey;
}

codeCheckDialog(BuildContext context) async {
  TextEditingController textFieldController = TextEditingController();
  var response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
  bool clicked = false;
  getCode(Function fn) async {
    response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
    parseRawCookies(response.headers['set-cookie']);
    fn(() {});
  }

  parseRawCookies(response.headers['set-cookie']);
  void _codeCheck(Function fn) async {
    Future<void> _next2(String value) async {
      if (value == "success") {
        await getSchedule().then((value) => {
              if (value == "success")
                {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomRouteMs300(
                      const Index(
                        type: 1,
                      ),
                    ),
                    (route) => false,
                  )
                }
            });
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text)
            .then((String value) => _next2(value));
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        fn(() {
          clicked = !clicked;
        });
      }
    }

    if (!clicked) {
      fn(() {
        clicked = !clicked;
      });
      print(textFieldController.text);
      await codeCheck(textFieldController.text).then((String value) => _next(value));
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            title: Text('提示'),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  "输入验证码后继续",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: textFieldController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.code_outlined,
                            color: readColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "验证码", //类似placeholder效果
                        ),
                      ),
                    ),
                    InkWell(
                      child: Image.memory(response.bodyBytes, height: 25),
                      onTap: () {
                        getCode(setState);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      !clicked ? "取消" : "",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 24, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      _codeCheck(setState);
                    },
                    child: Text(
                      !clicked ? "继续" : "稍等...",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      );
    },
  );
}

codeCheckDialogQ(BuildContext context) async {
  print("codeCheckDialogQ");
  TextEditingController textFieldController = TextEditingController();
  var response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
  bool clicked = false;
  getCode(Function fn) async {
    response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
    parseRawCookies(response.headers['set-cookie']);
    fn(() {});
  }

  parseRawCookies(response.headers['set-cookie']);
  void _codeCheck(Function fn) async {
    Future<void> _next2(String value) async {
      if (value == "success") {
        Scaffold.of(context).removeCurrentSnackBar();
        // Scaffold.of(context).showSnackBar(jwSnackBar(true, "验证完成,请再次点击查询")),
        pageBus.fire(QueryScoreRe(1));
        Navigator.pop(context);
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, value, 4));
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text)
            .then((String value) => _next2(value));
      } else if (value == "fail") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, value, 4));
        Navigator.pop(context);
      }
    }

    if (!clicked) {
      fn(() {
        clicked = !clicked;
      });
      print(textFieldController.text);
      await codeCheck(textFieldController.text).then((String value) => _next(value));
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            title: Text('提示'),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  "输入验证码后继续",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: textFieldController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.code_outlined,
                            color: readColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "验证码", //类似placeholder效果
                        ),
                      ),
                    ),
                    InkWell(
                      child: Image.memory(response.bodyBytes, height: 25),
                      onTap: () {
                        getCode(setState);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      !clicked ? "取消" : "",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 24, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      _codeCheck(setState);
                    },
                    child: Text(
                      !clicked ? "继续" : "稍等...",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      );
    },
  );
}

codeCheckDialogQ2(BuildContext context) async {
  TextEditingController textFieldController = TextEditingController();
  var response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
  bool clicked = false;
  getCode(Function fn) async {
    response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
    parseRawCookies(response.headers['set-cookie']);
    fn(() {});
  }

  parseRawCookies(response.headers['set-cookie']);
  void _codeCheck(Function fn) async {
    Future<void> _next2(String value) async {
      if (value == "success") {
        Scaffold.of(context).removeCurrentSnackBar();
        // Scaffold.of(context).showSnackBar(jwSnackBar(true, "验证完成,请再次点击查询")),
        pageBus.fire(QueryExamRe(1));
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text)
            .then((String value) => _next2(value));
      } else if (value == "fail") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, value, 4));
        Navigator.pop(context);
      }
    }

    if (!clicked) {
      fn(() {
        clicked = !clicked;
      });
      print(textFieldController.text);
      await codeCheck(textFieldController.text).then((String value) => _next(value));
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            title: Text('提示'),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  "输入验证码后继续",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: textFieldController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.code_outlined,
                            color: readColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "验证码", //类似placeholder效果
                        ),
                      ),
                    ),
                    InkWell(
                      child: Image.memory(response.bodyBytes, height: 25),
                      onTap: () {
                        getCode(setState);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      !clicked ? "取消" : "",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 24, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      _codeCheck(setState);
                    },
                    child: Text(
                      !clicked ? "继续" : "稍等...",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      );
    },
  );
}

codeCheckDialogQ3(BuildContext context) async {
  TextEditingController textFieldController = TextEditingController();
  var response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
  bool clicked = false;
  getCode(Function fn) async {
    response = await get(Global.getCodeUrl).timeout(const Duration(seconds: 3));
    parseRawCookies(response.headers['set-cookie']);
    fn(() {});
  }

  parseRawCookies(response.headers['set-cookie']);
  void _codeCheck(Function fn) async {
    Future<void> _next2(String value) async {
      if (value == "success") {
        Scaffold.of(context).removeCurrentSnackBar();
        pageBus.fire(CareerRe(1));
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text)
            .then((String value) => _next2(value));
      } else if (value == "fail") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, value, 4));
        Navigator.pop(context);
      }
    }

    if (!clicked) {
      fn(() {
        clicked = !clicked;
      });
      print(textFieldController.text);
      await codeCheck(textFieldController.text).then((String value) => _next(value));
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            title: Text('提示'),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  "输入验证码后继续",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: textFieldController,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.code_outlined,
                            color: readColor(),
                          ),
                          border: InputBorder.none,
                          hintText: "验证码", //类似placeholder效果
                        ),
                      ),
                    ),
                    InkWell(
                      child: Image.memory(response.bodyBytes, height: 25),
                      onTap: () {
                        getCode(setState);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      !clicked ? "取消" : "",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 24, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      _codeCheck(setState);
                    },
                    child: Text(
                      !clicked ? "继续" : "稍等...",
                      style: TextStyle(color: readColor()),
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      );
    },
  );
}

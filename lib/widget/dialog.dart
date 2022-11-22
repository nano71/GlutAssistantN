import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/login.dart';
import 'package:glutassistantn/common/noripple.dart';
import 'package:glutassistantn/common/style.dart';
import 'package:glutassistantn/data.dart';
import 'package:http/http.dart';

import '../config.dart';
import 'bars.dart';

class CodeCheckDialog {
  static final checkCodeController = TextEditingController();
  static String message = "不辜负每一次相遇";
  static Color messageColor = Colors.grey;
}

codeCheckDialog(BuildContext context, Function callback) async {
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
        callback();
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text).then((String value) => _next2(value));
      } else if (value == "fail") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "验证码错误!"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
                            FlutterRemix.magic_line,
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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        //  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "验证完成,请再次点击查询")),
        eventBus.fire(ReloadScoreListState());
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text).then((String value) => _next2(value));
      } else if (value == "fail") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "验证码错误!"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
                            FlutterRemix.magic_line,
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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        //  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "验证完成,请再次点击查询")),
        eventBus.fire(ReloadExamListState());
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      print(value);
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text).then((String value) => _next2(value));
      } else if (value == "fail") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "验证码错误!"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
                            FlutterRemix.magic_line,
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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        eventBus.fire(ReloadCareerPageState());
        Navigator.pop(context);
      }
    }

    Future<void> _next(String value) async {
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text).then((String value) => _next2(value));
      } else if (value == "fail") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "验证码错误!"));
        fn(() {
          clicked = !clicked;
        });
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
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
                            FlutterRemix.magic_line,
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

scheduleDialogItem(title, time, teacher, position) {
  List _list = time.split(",");
  return Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    decoration: BoxDecoration(
      color: randomColors(),
      borderRadius: const BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    height: 160,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            child: Text(
              title[0],
              style: TextStyle(fontSize: 128, color: Color(0x66f1f1f1)),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseLongText2ShortName(title),
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "教师: " + teacher,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "地点: " + position,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "周数: " + _list[0],
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "时间: " + _list[1],
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "课节: " + _list[2],
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}

scheduleDialog(BuildContext context, String week, String weekDay, String index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List _schedule = schedule[week][weekDay][index];
      List<String> _temp = _schedule[3].split(";").toSet().toList();
      String _time = "";
      _temp.removeLast();
      _temp.forEach((element) {
        if (element.trim() != "") {
          // _list.add(element);
          _time += element.trim() + ",";
        }
      });
      return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("课程信息"),
                Text(
                  "Course information",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
            InkWell(
              child: const Icon(FlutterRemix.close_line, size: 32),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        titleTextStyle: TextStyle(
          color: readColor(),
          fontSize: 25,
        ),
        contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
        backgroundColor: Colors.white,
        children: [scheduleDialogItem(_schedule[0], _time, _schedule[1], _schedule[2])],
      );
    },
  );
}

careerDialog(context, index, type, year) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return NoRippleOverScroll(
          child: SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$year - ${type == 2 ? "春" : "秋"}学期"),
                Text(
                  "课程计数: ${careerList2[(index * 2 + type / 2 >= 1 ? index * 2 + type / 2 : 0).toInt()].length} 门",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
            InkWell(
              child: const Icon(FlutterRemix.close_line, size: 32),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        titleTextStyle: TextStyle(
          color: readColor(),
          fontSize: 25,
        ),
        contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
        backgroundColor: Colors.white,
        children: careerDialogLoop(index, type),
      ));
    },
  );
}

careerDialogLoop(int index, int semester) {
  List<Widget> list = [];
  double newIndex = 0;
  newIndex = index * 2 + semester / 2 >= 1 ? index * 2 + semester / 2 : 0;
  careerList2[newIndex.toInt()].forEach((element) {
    list.add(careerDialogItem(element));
  });
  return list;
}

careerDialogItem(element) {
  return Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    decoration: BoxDecoration(
      color: randomColors(),
      borderRadius: const BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    height: 150,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            child: Text(
              element[1][0],
              style: TextStyle(fontSize: 128, color: Color(0x66f1f1f1)),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseLongText2ShortName(element[1]),
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(
              height: 8,
            ),
            Text(element[0], style: TextStyle(color: Colors.white)),
            Text(element[5], style: TextStyle(color: Colors.white)),
            Text("性质: " + element[2], style: TextStyle(color: Colors.white)),
            Text("学分: " + element[3], style: TextStyle(color: Colors.white)),
            Text("学时: " + element[4].toString().replaceAll(" ", "").replaceAll(RegExp(r"\s+\b|\b\s\n"), "").trim(), style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    ),
  );
}

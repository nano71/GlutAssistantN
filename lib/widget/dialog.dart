import 'package:flutter/material.dart';
import 'package:glutassistantn/type/teachingPlan.dart';
import 'package:glutassistantn/widget/lists.dart';
import 'package:http/http.dart';
import 'package:remixicon/remixicon.dart';

import '/common/cookie.dart';
import '/common/login.dart';
import '/common/noRipple.dart';
import '/common/style.dart';
import '/data.dart';
import '../config.dart';
import '../pages/update.dart';
import '../type/course.dart';
import 'bars.dart';

showImportantUpdateDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(scale: animation, child: child);
      },
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("版本更新"),
                  Text(
                    "Version update",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
              InkWell(
                child: Icon(Remix.close_line, size: 32),
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
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                  color: readColorEnd(),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      AppData.newVersionChangelog,
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Container(
                        child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(Colors.yellow),
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                return readColor();
                              }),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                            ),
                            child: Text(
                              "即刻更新",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdatePage()));
                            }),
                      ),
                    )
                  ],
                )),
          ],
        );
      });
}

showInfoDialog(BuildContext context, String text) {
  showGeneralDialog(
      context: context,
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(scale: animation, child: child);
      },
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("有必要的说明"),
                  Text(
                    "Necessary clarifications",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
              InkWell(
                child: Icon(
                  Remix.close_line,
                  size: 32,
                  color: readTextColor(),
                ),
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
          backgroundColor: readCardBackgroundColor(),
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                  color: readTextContentBackgroundColor(),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      text.trim(),
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Container(
                        child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(Colors.yellow),
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                return readColor();
                              }),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                            ),
                            child: Text(
                              "我知道了",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ),
                    )
                  ],
                )),
          ],
        );
      });
}

showCaptchaDialog(BuildContext context, Function callback) async {
  TextEditingController textFieldController = TextEditingController();
  var response = await get(AppConfig.captchaUri).timeout(Duration(seconds: 3));
  bool checking = false;
  getCode(Function fn) async {
    response = await get(AppConfig.captchaUri).timeout(Duration(seconds: 3));
    parseRawCookies(response.headers['set-cookie']);
    fn(() {});
  }

  parseRawCookies(response.headers['set-cookie']);

  void check(Function fn) async {
    Future<void> next2(String value) async {
      if (value == "success") {
        callback();
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, value, 4));
        Navigator.pop(context);
      }
    }

    Future<void> next(String value) async {
      if (value == "success") {
        await login(AppData.studentId, AppData.password, textFieldController.text).then(next2);
      } else if (value == "fail") {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "验证码错误!"));
        fn(() {
          checking = !checking;
        });
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, value, 4));
        Navigator.pop(context);
      }
    }

    if (!checking) {
      fn(() {
        checking = !checking;
      });
      await checkCaptcha(textFieldController.text).then(next);
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text('提示', style: TextStyle(color: readTextColor())),
            backgroundColor: readCardBackgroundColor(),
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  "输入验证码后继续",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(24, 4, 24, 0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        controller: textFieldController,
                        style: TextStyle(color: readTextColor()),
                        decoration: InputDecoration(
                            icon: Icon(
                              Remix.magic_line,
                              color: readColor(),
                            ),
                            border: InputBorder.none,
                            hintText: "验证码", //类似placeholder效果
                            hintStyle: TextStyle(color: readTextColor2())),
                      ),
                    ),
                    InkWell(
                      child: Image.memory(
                        response.bodyBytes,
                        height: 25,
                        width: 80,
                      ),
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
                !checking
                    ? Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: TextButton(
                          style: buttonStyle(),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "取消",
                            style: TextStyle(color: readColor()),
                          ),
                        ),
                      )
                    : Container(),
                RowGap(AppData.isDarkTheme ? 8 : 0),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 8, 24, 0),
                  child: TextButton(
                    style: buttonStyle(),
                    onPressed: () {
                      check(setState);
                    },
                    child: Text(
                      !checking ? "继续" : "稍等...",
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

_CourseInfoDialogContent(title, time, teacher, position) {
  List infos = time.split(",");
  return Container(
    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
    margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
    decoration: BoxDecoration(
      color: randomColors(),
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
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
              courseLongText2Short(title),
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
              "周数: " + infos[0],
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "时间: " + infos[1],
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "课节: " + infos[2],
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}

showCourseInfoDialog(BuildContext context, int week, int weekDay, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Course course = AppData.schedule[week][weekDay][index];
      List<String> _temp = course.extra.split(";").toSet().toList();
      String time = "";
      _temp.removeLast();
      _temp.forEach((element) {
        if (element.trim() != "") {
          // _list.add(element);
          time += element.trim() + ",";
        }
      });
      return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
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
              child: Icon(
                Remix.close_line,
                size: 32,
                color: readTextColor(),
              ),
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
        backgroundColor: readCardBackgroundColor(),
        children: [_CourseInfoDialogContent(course.name, time, course.teacher, course.location)],
      );
    },
  );
}

showCourseListDialog(BuildContext context, int academicYearNumber, int semesterNumber) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        backgroundColor: readCardBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$academicYearNumber - ${semesterNumber % 2 == 0 ? "春" : "秋"}学期"),
                Text(
                  "课程计数: ${TeachingPlan.courseInfoListBySemester[semesterNumber - 1].length} 门",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
            InkWell(
              child: Icon(
                Remix.close_line,
                size: 32,
                color: readTextColor(),
              ),
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
        children: _CourseList(semesterNumber),
      );
    },
  );
}

List<Widget> _CourseList(int semesterNumber) {
  List<Widget> result = [];
  for (CourseInfo courseInfo in TeachingPlan.courseInfoListBySemester[semesterNumber - 1]) {
    result.add(Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: randomColors(),
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      height: 150,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Text(
                courseInfo.name[0],
                style: TextStyle(fontSize: 128, color: Color(0x66f1f1f1)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseLongText2Short(courseInfo.name),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 8,
              ),
              Text(courseInfo.code, style: TextStyle(color: Colors.white)),
              Text(courseInfo.category, style: TextStyle(color: Colors.white)),
              Text("性质: " + courseInfo.assessmentType, style: TextStyle(color: Colors.white)),
              Text("学分: " + courseInfo.credit, style: TextStyle(color: Colors.white)),
              Text("学时: " + courseInfo.hours, style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    ));
  }
  return result;
}

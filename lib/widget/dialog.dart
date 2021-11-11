import 'package:flutter/material.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/login.dart';
import 'package:glutassistantn/data.dart';
import 'package:http/http.dart';

import '../config.dart';

class CodeCheckDialog {
  static final checkCodeController = TextEditingController();
  static String message = "不辜负每一次相遇";
  static Color messageColor = Colors.grey;
}

void codeCheckDialog(BuildContext context) async {
  TextEditingController textFieldController = TextEditingController();
  var response = await get(Global.getCodeUrl).timeout(const Duration(milliseconds: 6000));
  parseRawCookies(response.headers['set-cookie']);
  void _codeCheck() async {
    void _next(String value) async {
      if (value == "success") {
        await login(writeData["username"], writeData["password"], textFieldController.text)
            .then((String value) => _next(value));
      } else {}
    }

    await codeCheck(textFieldController.text).then((String value) => _next(value));
  }

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textFieldController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.code_outlined),
                        border: InputBorder.none,
                        hintText: "验证码", //类似placeholder效果
                      ),
                    ),
                  ),
                  InkWell(
                    child: Image.memory(response.bodyBytes, height: 25),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                onPressed: () {
                  _codeCheck();
                },
                child: const Text(
                  "继续",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ]),
          ],
        );
      });
}

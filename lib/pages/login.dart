// void _getCode() async {
//   try {
//     setState(() {
//       _textFieldController.text = "";
//     });
//     print("getCode...");
//     var response = await get(Global.getCodeUrl).timeout(const Duration(milliseconds: 6000));
//     parseRawCookies(response.headers['set-cookie']);
//     setState(() {
//       _codeImgSrc = response.bodyBytes;
//     });
//   } catch (e) {
//     Scaffold.of(context).removeCurrentSnackBar();
//     Scaffold.of(context).showSnackBar(jwSnackBar(false, "网络错误"));
//   }
// }
//
// void _codeCheck() async {
//   void _next(String value) {
//     if (value == "success") {
//       _loginJW();
//     } else {
//       Scaffold.of(context).removeCurrentSnackBar();
//       Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
//       setState(() {
//         _textFieldController.text = "";
//       });
//     }
//   }
//
//   await codeCheck(_textFieldController.text.toString()).then((String value) => _next(value));
// }
//
// void _loginJW() async {
//   void _next(String value) {
//     if (value == "success") {
//       Global.logined = true;
//       Scaffold.of(context).removeCurrentSnackBar();
//       Scaffold.of(context).showSnackBar(jwSnackBar(true, "登陆成功"));
//       _getWeek();
//     } else if (value == "fail") {
//       Scaffold.of(context).removeCurrentSnackBar();
//       Scaffold.of(context).showSnackBar(jwSnackBar(false, "请重试"));
//       _getCode();
//     } else {
//       if (Global.logined) {
//         Scaffold.of(context).removeCurrentSnackBar();
//         Scaffold.of(context).showSnackBar(jwSnackBar(false, "登录成功,但程序发生了错误"));
//         _getCode();
//       }
//     }
//   }
//
//   await login("5191963403", "sr20000923++", _textFieldController.text.toString())
//       .then((String value) => _next(value));
// }
//
// void _getWeek() async {
//   setState(() {
//     _textFieldController.text = "";
//     _week = int.parse(writeData["week"]);
//   });
//   // print("_getWeek...");
//   getSchedule();
// }
//
// final TextEditingController _textFieldController = TextEditingController();
//
// Uint8List _codeImgSrc = const Base64Decoder().convert(
//     "iVBORw0KGgoAAAANSUhEUgAAAEgAAAAeCAYAAACPOlitAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAHYcAAB2HAY/l8WUAAABYSURBVGhD7dChAcAgEMDAb/ffGSpqIQvcmfg86zMcvX85MCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBl3NbAiZBDiX3e/AAAAAAElFTkSuQmCC");
// Map<String, String> headers = {"cookie": ""};
// int _week = int.parse(writeData["week"]);

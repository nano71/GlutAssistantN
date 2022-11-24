import 'package:html/dom.dart' as dom;

List<String> lessonParser(dom.Element element) {
  return element.innerHtml.trim().replaceAll("第", "").replaceAll("节", "").replaceAll("周", "").replaceAll("单", "").replaceAll("双", "").split('-');
}

String innerHtmlTrim(dom.Element element) {
  return element.innerHtml.trim();
}

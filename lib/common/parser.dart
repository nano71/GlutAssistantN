import 'package:html/dom.dart' as dom;

List<String> teachTimeParser(dom.Element element) {
  return element.innerHtml.trim().replaceAll(RegExp(r'([第节周单双])'), "").split('-');
}

String innerHtmlTrim(dom.Element element) {
  return element.innerHtml.trim();
}

String teachLocation(String location) {
  if (location.contains("nbsp")) return "未知";
  return location;
}



List<int> teachTimeParser(String value) {
  if (value == "&nbsp;") {
    return [];
  }
  return value.replaceAll(RegExp(r'([第节周单双])'), "").split('-').map(int.parse).toList();
}

String teachLocation(String location) {
  if (location.contains("nbsp")) return "未知";
  return location;
}

int weekDifference(DateTime nowDate, DateTime pastDate) {
  // 计算 date1 所在周的周一
  DateTime monday1 = nowDate.subtract(Duration(days: nowDate.weekday - 1));

  // 计算 date2 所在周的周一
  DateTime monday2 = pastDate.subtract(Duration(days: pastDate.weekday - 1));

  // 计算周数差
  int weekDiff = monday1.difference(monday2).inDays ~/ 7;
  return weekDiff;
}

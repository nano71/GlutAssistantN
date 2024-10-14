int getWeekOfYear(DateTime date) {
  // 获取该年的第1天
  DateTime firstDayOfYear = DateTime(date.year, 1, 1);

  // 计算 date 与该年第一天之间的差距（以天为单位）
  int daysDifference = date.difference(firstDayOfYear).inDays;

  // 计算 date 所在的周数（从0开始）
  return (daysDifference / 7).floor();
}

int getWeekDifference(DateTime nowDate, DateTime pastDate) {
  // 获取两个日期的年份
  int nowYear = nowDate.year;
  int pastYear = pastDate.year;

  // 如果年份相同，直接比较周数
  if (nowYear == pastYear) {
    int nowWeek = getWeekOfYear(nowDate);
    int pastWeek = getWeekOfYear(pastDate);
    return nowWeek - pastWeek;
  }

  // 如果年份不同，需要考虑跨年的情况
  else {
    // 获取过去那一年的最后一周数
    DateTime lastDayOfPastYear = DateTime(pastYear, 12, 31);
    int pastYearLastWeek = getWeekOfYear(lastDayOfPastYear);

    // 获取当前年的周数
    int nowWeek = getWeekOfYear(nowDate);

    // 获取过去日期所在的周数
    int pastWeek = getWeekOfYear(pastDate);

    // 计算跨年的周差
    return (pastYearLastWeek - pastWeek) + 1 + nowWeek;
  }
}

import 'course.dart';

List<List<List<Course>>> createEmptySchedule() {
  return List.generate(
    21,
    (_) => List.generate(
      8,
      (_) => List.generate(
        12,
        (i) => Course(index: i),
      ),
    ),
  );
}

List<List<List<Course>>> parseNewSchedule(dynamic raw) {
  return (raw as List)
      .map((week) => (week as List)
          .map((day) => (day as List).map((c) => Course.fromJson(Map<String, dynamic>.from(c))).toList())
          .toList())
      .toList();
}

List<List<List<Course>>> migrateOldSchedule(
  Map<dynamic, dynamic> old,
) {
  final schedule = createEmptySchedule();

  old.forEach((weekKey, weekValue) {
    final week = int.tryParse(weekKey);
    if (week == null || weekValue is! Map) return;

    weekValue.forEach((dayKey, dayValue) {
      final day = int.tryParse(dayKey);
      if (day == null || dayValue is! Map) return;

      dayValue.forEach((lessonKey, lessonValue) {
        final lesson = int.tryParse(lessonKey);
        if (lesson == null || lessonValue is! List) return;

        final list = List<String>.from(lessonValue);

        schedule[week][day][lesson] = Course(
          name: list.length > 0 ? list[0] : '',
          teacher: list.length > 1 ? list[1] : '',
          location: list.length > 2 ? list[2] : '',
          extra: list.length > 3 ? list[3] : '',
          index: lesson,
        );
      });
    });
  });

  return schedule;
}

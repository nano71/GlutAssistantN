class Course {
  final String name;
  final String teacher;
  final String location;
  final String extra;
  final int index;

  bool get isEmpty => name.isEmpty || name == "null";

  const Course({this.name = "", this.teacher = "", this.location = "", this.extra = "", required this.index});

  Map<String, dynamic> toJson() => {
        "name": name,
        "teacher": teacher,
        "location": location,
        "extra": extra,
        "index": index,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        name: json["name"] ?? "",
        teacher: json["teacher"] ?? "",
        location: json["location"] ?? "",
        extra: json["extra"] ?? "",
        index: json["index"] ?? "",
      );
}

class CourseTimeSlot {
  final String week;
  final int weekDay;
  final List<int> periods;

  const CourseTimeSlot({required this.week, required this.weekDay, required this.periods});

  Map<String, dynamic> toJson() => {
        "week": week,
        "weekDay": weekDay,
        "lessonList": periods,
      };
}

class CourseInfo {
  final String number;
  final String name;
  final String evaluationMethod;
  final String creditPoints;
  final String hours;
  final String category;

  const CourseInfo(
      {required this.number,
      required this.name,
      required this.evaluationMethod,
      required this.creditPoints,
      required this.hours,
      required this.category});
}

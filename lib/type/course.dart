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
  final String code;
  final String name;
  final String assessmentType;
  final String credit;
  final String hours;
  final String category;

  const CourseInfo(
      {required this.code,
      required this.name,
      required this.assessmentType,
      required this.credit,
      required this.hours,
      required this.category});
}

class CourseScore {
  final String courseCode;
  final String courseName;
  final String teacher;
  final double credit;
  final double gradePoint;
  final double score;
  final String rawScore;
  final String courseCategory;

  const CourseScore({
    required this.courseCode,
    required this.courseName,
    required this.teacher,
    required this.credit,
    required this.gradePoint,
    required this.score,
    required this.courseCategory,
    required this.rawScore,
  });
}

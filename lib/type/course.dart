class Course {
  final String name;
  final String teacher;
  final String location;
  final String extra;
  final int index;

  bool get isEmpty => name.isEmpty;

  const Course({
    this.name = "",
    this.teacher = "",
    this.location = "",
    this.extra = "",
    required this.index
  });

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




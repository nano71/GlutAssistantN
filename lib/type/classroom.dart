class Classroom {
  final String roomNumber;
  final int seatCount;
  final int examSeatCount;
  final String type;
  final List<bool> occupancy;
  final bool isAllDayFree;

  Classroom({
    required this.roomNumber,
    required this.seatCount,
    required this.examSeatCount,
    required this.type,
    required this.occupancy,
    required this.isAllDayFree,
  });
}

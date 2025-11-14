/// Course data model
/// Maps to/from JSON for API communication
class CourseModel {
  final int id;
  final String courseCode;
  final String courseName;
  final String? description;
  final int credits;
  final String? instructor;
  final int maxStudents;
  final int currentStudents;
  final String? prerequisites;
  final String? schedule;
  final String? semester;
  final int? availableSeats;
  final bool? isFull;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.description,
    required this.credits,
    this.instructor,
    this.maxStudents = 50,
    this.currentStudents = 0,
    this.prerequisites,
    this.schedule,
    this.semester,
    this.availableSeats,
    this.isFull,
    this.createdAt,
    this.updatedAt,
  });

  /// Create CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      description: json['description'] as String?,
      credits: json['credits'] as int,
      instructor: json['instructor'] as String?,
      maxStudents: json['maxStudents'] as int? ?? 50,
      currentStudents: json['currentStudents'] as int? ?? 0,
      prerequisites: json['prerequisites'] as String?,
      schedule: json['schedule'] as String?,
      semester: json['semester'] as String?,
      availableSeats: json['availableSeats'] as int?,
      isFull: json['isFull'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert CourseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'credits': credits,
      'instructor': instructor,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'prerequisites': prerequisites,
      'schedule': schedule,
      'semester': semester,
      'availableSeats': availableSeats,
      'isFull': isFull,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get computed available seats
  int get computedAvailableSeats => maxStudents - currentStudents;

  /// Check if course is full
  bool get computedIsFull => currentStudents >= maxStudents;
}

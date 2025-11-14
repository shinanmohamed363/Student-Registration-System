/// Course model representing a course entity
class Course {
  final int? id;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Course({
    this.id,
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
    this.createdAt,
    this.updatedAt,
  });

  /// Create Course from database row
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      courseCode: map['course_code'] as String,
      courseName: map['course_name'] as String,
      description: map['description']?.toString(),
      credits: map['credits'] as int,
      instructor: map['instructor']?.toString(),
      maxStudents: map['max_students'] as int? ?? 50,
      currentStudents: map['current_students'] as int? ?? 0,
      prerequisites: map['prerequisites']?.toString(),
      schedule: map['schedule']?.toString(),
      semester: map['semester']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : null,
    );
  }

  /// Convert Course to JSON
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'availableSeats': maxStudents - currentStudents,
      'isFull': currentStudents >= maxStudents,
    };
  }

  /// Check if course has available seats
  bool get hasAvailableSeats => currentStudents < maxStudents;
}

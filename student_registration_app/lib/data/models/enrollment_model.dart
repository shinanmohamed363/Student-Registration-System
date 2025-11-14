/// Enrollment data model
/// Maps to/from JSON for API communication
class EnrollmentModel {
  final int id;
  final int studentId;
  final int courseId;
  final DateTime enrollmentDate;
  final String? grade;
  final String status;
  final double? finalMarks;

  // Course details (when joined)
  final String? courseName;
  final String? courseCode;
  final int? credits;
  final String? instructor;
  final String? schedule;
  final String? semester;
  final String? description;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    this.grade,
    this.status = 'active',
    this.finalMarks,
    this.courseName,
    this.courseCode,
    this.credits,
    this.instructor,
    this.schedule,
    this.semester,
    this.description,
  });

  /// Create EnrollmentModel from JSON
  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      courseId: json['courseId'] as int,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      grade: json['grade'] as String?,
      status: json['status'] as String? ?? 'active',
      finalMarks: json['finalMarks'] != null
          ? double.parse(json['finalMarks'].toString())
          : null,
      courseName: json['courseName'] as String?,
      courseCode: json['courseCode'] as String?,
      credits: json['credits'] as int?,
      instructor: json['instructor'] as String?,
      schedule: json['schedule'] as String?,
      semester: json['semester'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Convert EnrollmentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'grade': grade,
      'status': status,
      'finalMarks': finalMarks,
      'courseName': courseName,
      'courseCode': courseCode,
      'credits': credits,
      'instructor': instructor,
      'schedule': schedule,
      'semester': semester,
      'description': description,
    };
  }

  /// Check if enrollment is active
  bool get isActive => status == 'active';

  /// Check if enrollment is completed
  bool get isCompleted => status == 'completed';

  /// Check if enrollment is dropped
  bool get isDropped => status == 'dropped';
}

/// Enrollment model representing student course enrollment
class Enrollment {
  final int? id;
  final int studentId;
  final int courseId;
  final DateTime enrollmentDate;
  final String? grade;
  final String status;
  final double? finalMarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields that might be joined from other tables
  final String? courseName;
  final String? courseCode;
  final int? credits;
  final String? instructor;

  Enrollment({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    this.grade,
    this.status = 'active',
    this.finalMarks,
    this.createdAt,
    this.updatedAt,
    this.courseName,
    this.courseCode,
    this.credits,
    this.instructor,
  });

  /// Create Enrollment from database row
  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      courseId: map['course_id'] as int,
      enrollmentDate: map['enrollment_date'] != null
          ? DateTime.parse(map['enrollment_date'].toString())
          : DateTime.now(),
      grade: map['grade'] as String?,
      status: map['status'] as String? ?? 'active',
      finalMarks: map['final_marks'] != null
          ? double.parse(map['final_marks'].toString())
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : null,
      courseName: map['course_name'] as String?,
      courseCode: map['course_code'] as String?,
      credits: map['credits'] as int?,
      instructor: map['instructor'] as String?,
    );
  }

  /// Convert Enrollment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'grade': grade,
      'status': status,
      'finalMarks': finalMarks,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (courseName != null) 'courseName': courseName,
      if (courseCode != null) 'courseCode': courseCode,
      if (credits != null) 'credits': credits,
      if (instructor != null) 'instructor': instructor,
    };
  }
}

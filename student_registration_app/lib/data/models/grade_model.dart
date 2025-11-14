/// Grade data model for course grades and assignments
class GradeModel {
  final int enrollmentId;
  final int courseId;
  final String courseCode;
  final String courseName;
  final int credits;
  final String? grade;
  final double? finalMarks;
  final String status;
  final List<AssignmentModel> assignments;

  GradeModel({
    required this.enrollmentId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    this.grade,
    this.finalMarks,
    required this.status,
    this.assignments = const [],
  });

  /// Create GradeModel from JSON
  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      enrollmentId: json['enrollmentId'] as int,
      courseId: json['courseId'] as int,
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      credits: json['credits'] as int,
      grade: json['grade'] as String?,
      finalMarks: json['finalMarks'] != null
          ? double.parse(json['finalMarks'].toString())
          : null,
      status: json['status'] as String,
      assignments: (json['assignments'] as List<dynamic>?)
              ?.map((a) => AssignmentModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert GradeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'grade': grade,
      'finalMarks': finalMarks,
      'status': status,
      'assignments': assignments.map((a) => a.toJson()).toList(),
    };
  }

  /// Calculate average assignment marks
  double? get averageAssignmentMarks {
    if (assignments.isEmpty) return null;
    final withMarks = assignments.where((a) => a.marks != null);
    if (withMarks.isEmpty) return null;
    final total = withMarks.fold<double>(0, (sum, a) => sum + a.marks!);
    return total / withMarks.length;
  }
}

/// Assignment data model
class AssignmentModel {
  final int assignmentId;
  final String assignmentName;
  final double maxMarks;
  final double? marks;
  final DateTime? submittedAt;
  final String? feedback;

  AssignmentModel({
    required this.assignmentId,
    required this.assignmentName,
    required this.maxMarks,
    this.marks,
    this.submittedAt,
    this.feedback,
  });

  /// Create AssignmentModel from JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      assignmentId: json['assignmentId'] as int,
      assignmentName: json['assignmentName'] as String,
      maxMarks: double.parse(json['maxMarks'].toString()),
      marks: json['marks'] != null
          ? double.parse(json['marks'].toString())
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      feedback: json['feedback'] as String?,
    );
  }

  /// Convert AssignmentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'assignmentName': assignmentName,
      'maxMarks': maxMarks,
      'marks': marks,
      'submittedAt': submittedAt?.toIso8601String(),
      'feedback': feedback,
    };
  }

  /// Calculate percentage
  double? get percentage {
    if (marks == null) return null;
    return (marks! / maxMarks) * 100;
  }

  /// Check if submitted
  bool get isSubmitted => submittedAt != null;
}

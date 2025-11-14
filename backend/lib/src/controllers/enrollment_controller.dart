import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../models/enrollment.dart';
import '../utils/response_helper.dart';

/// Enrollment controller handling course enrollment operations
class EnrollmentController {
  final _db = Database.instance;

  /// Enroll in a course (requires authentication)
  Future<Response> enrollInCourse(Request request, String courseId) async {
    try {
      final studentId = request.context['studentId'] as int;
      final courseIdInt = int.tryParse(courseId);

      if (courseIdInt == null) {
        return ResponseHelper.validationError(
          message: 'Invalid course ID',
        );
      }

      // Check if course exists
      final courseRow = await _db.queryOne(
        'SELECT * FROM courses WHERE id = ?',
        [courseIdInt],
      );

      if (courseRow == null) {
        return ResponseHelper.notFound(message: 'Course not found');
      }

      // Check if course is full
      final currentStudents = courseRow.fields['current_students'] as int;
      final maxStudents = courseRow.fields['max_students'] as int;

      if (currentStudents >= maxStudents) {
        return ResponseHelper.error(
          message: 'Course is full',
          statusCode: 409,
        );
      }

      // Check if already enrolled
      final existingEnrollment = await _db.query(
        'SELECT id FROM enrollments WHERE student_id = ? AND course_id = ?',
        [studentId, courseIdInt],
      );

      if (existingEnrollment.isNotEmpty) {
        return ResponseHelper.error(
          message: 'Already enrolled in this course',
          statusCode: 409,
        );
      }

      // Create enrollment
      final enrollmentId = await _db.insert(
        'INSERT INTO enrollments (student_id, course_id, status) VALUES (?, ?, ?)',
        [studentId, courseIdInt, 'active'],
      );

      // Update course student count
      await _db.execute(
        'UPDATE courses SET current_students = current_students + 1 WHERE id = ?',
        [courseIdInt],
      );

      // Fetch enrollment with course details
      final enrollmentRow = await _db.queryOne(
        '''
        SELECT e.*, c.course_code, c.course_name, c.credits, c.instructor
        FROM enrollments e
        JOIN courses c ON e.course_id = c.id
        WHERE e.id = ?
        ''',
        [enrollmentId],
      );

      final enrollment = Enrollment.fromMap(enrollmentRow!.fields);

      return ResponseHelper.success(
        message: 'Successfully enrolled in course',
        data: enrollment.toJson(),
        statusCode: 201,
      );
    } catch (e) {
      print('Error in enrollInCourse: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to enroll in course',
      );
    }
  }

  /// Get student's enrolled courses (requires authentication)
  Future<Response> getStudentCourses(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      final results = await _db.query(
        '''
        SELECT e.*, c.course_code, c.course_name, c.description, c.credits,
               c.instructor, c.schedule, c.semester
        FROM enrollments e
        JOIN courses c ON e.course_id = c.id
        WHERE e.student_id = ?
        ORDER BY e.enrollment_date DESC
        ''',
        [studentId],
      );

      final enrollments = results.map((row) => Enrollment.fromMap(row.fields).toJson()).toList();

      return ResponseHelper.success(
        message: 'Enrolled courses retrieved successfully',
        data: enrollments,
      );
    } catch (e) {
      print('Error in getStudentCourses: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve enrolled courses',
      );
    }
  }

  /// Get active enrollments only
  Future<Response> getActiveEnrollments(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      final results = await _db.query(
        '''
        SELECT e.*, c.course_code, c.course_name, c.description, c.credits,
               c.instructor, c.schedule, c.semester
        FROM enrollments e
        JOIN courses c ON e.course_id = c.id
        WHERE e.student_id = ? AND e.status = 'active'
        ORDER BY c.course_code
        ''',
        [studentId],
      );

      final enrollments = results.map((row) => Enrollment.fromMap(row.fields).toJson()).toList();

      return ResponseHelper.success(
        message: 'Active enrollments retrieved successfully',
        data: enrollments,
      );
    } catch (e) {
      print('Error in getActiveEnrollments: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve active enrollments',
      );
    }
  }

  /// Get student grades and assignments
  Future<Response> getStudentGrades(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      final results = await _db.query(
        '''
        SELECT e.*, c.course_code, c.course_name, c.credits,
               a.id as assignment_id, a.assignment_name, a.max_marks as assignment_max_marks,
               sa.marks as assignment_marks, sa.submitted_at, sa.feedback
        FROM enrollments e
        JOIN courses c ON e.course_id = c.id
        LEFT JOIN assignments a ON c.id = a.course_id
        LEFT JOIN student_assignments sa ON (e.id = sa.enrollment_id AND a.id = sa.assignment_id)
        WHERE e.student_id = ?
        ORDER BY c.course_code, a.id
        ''',
        [studentId],
      );

      // Group results by course
      final courseMap = <int, Map<String, dynamic>>{};

      for (final row in results) {
        final courseId = row.fields['course_id'] as int;

        if (!courseMap.containsKey(courseId)) {
          courseMap[courseId] = {
            'enrollmentId': row.fields['id'],
            'courseId': courseId,
            'courseCode': row.fields['course_code'],
            'courseName': row.fields['course_name'],
            'credits': row.fields['credits'],
            'grade': row.fields['grade'],
            'finalMarks': row.fields['final_marks'],
            'status': row.fields['status'],
            'assignments': <Map<String, dynamic>>[],
          };
        }

        // Add assignment if exists
        if (row.fields['assignment_id'] != null) {
          courseMap[courseId]!['assignments'].add({
            'assignmentId': row.fields['assignment_id'],
            'assignmentName': row.fields['assignment_name'],
            'maxMarks': row.fields['assignment_max_marks'],
            'marks': row.fields['assignment_marks'],
            'submittedAt': row.fields['submitted_at']?.toString(),
            'feedback': row.fields['feedback'],
          });
        }
      }

      return ResponseHelper.success(
        message: 'Grades retrieved successfully',
        data: courseMap.values.toList(),
      );
    } catch (e) {
      print('Error in getStudentGrades: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve grades',
      );
    }
  }

  /// Drop a course (requires authentication)
  Future<Response> dropCourse(Request request, String courseId) async {
    try {
      final studentId = request.context['studentId'] as int;
      final courseIdInt = int.tryParse(courseId);

      if (courseIdInt == null) {
        return ResponseHelper.validationError(
          message: 'Invalid course ID',
        );
      }

      // Check if enrolled
      final enrollmentRow = await _db.queryOne(
        'SELECT id FROM enrollments WHERE student_id = ? AND course_id = ? AND status = ?',
        [studentId, courseIdInt, 'active'],
      );

      if (enrollmentRow == null) {
        return ResponseHelper.notFound(
          message: 'Enrollment not found or already dropped',
        );
      }

      // Update enrollment status
      await _db.execute(
        'UPDATE enrollments SET status = ? WHERE student_id = ? AND course_id = ?',
        ['dropped', studentId, courseIdInt],
      );

      // Update course student count
      await _db.execute(
        'UPDATE courses SET current_students = current_students - 1 WHERE id = ?',
        [courseIdInt],
      );

      return ResponseHelper.success(
        message: 'Course dropped successfully',
      );
    } catch (e) {
      print('Error in dropCourse: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to drop course',
      );
    }
  }

  /// Re-enroll in a previously dropped course (requires authentication)
  Future<Response> reEnrollCourse(Request request, String enrollmentId) async {
    try {
      final studentId = request.context['studentId'] as int;
      final enrollmentIdInt = int.tryParse(enrollmentId);

      if (enrollmentIdInt == null) {
        return ResponseHelper.validationError(
          message: 'Invalid enrollment ID',
        );
      }

      // Check if enrollment exists and belongs to the student
      final enrollmentRow = await _db.queryOne(
        'SELECT e.*, c.max_students, c.current_students FROM enrollments e JOIN courses c ON e.course_id = c.id WHERE e.id = ? AND e.student_id = ? AND e.status = ?',
        [enrollmentIdInt, studentId, 'dropped'],
      );

      if (enrollmentRow == null) {
        return ResponseHelper.notFound(
          message: 'Dropped enrollment not found',
        );
      }

      // Check if course is full
      final currentStudents = enrollmentRow.fields['current_students'] as int;
      final maxStudents = enrollmentRow.fields['max_students'] as int;

      if (currentStudents >= maxStudents) {
        return ResponseHelper.error(
          message: 'Course is full',
          statusCode: 409,
        );
      }

      // Update enrollment status back to active
      await _db.execute(
        'UPDATE enrollments SET status = ? WHERE id = ?',
        ['active', enrollmentIdInt],
      );

      // Update course student count
      final courseId = enrollmentRow.fields['course_id'] as int;
      await _db.execute(
        'UPDATE courses SET current_students = current_students + 1 WHERE id = ?',
        [courseId],
      );

      return ResponseHelper.success(
        message: 'Successfully re-enrolled in course',
      );
    } catch (e) {
      print('Error in reEnrollCourse: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to re-enroll in course',
      );
    }
  }
}

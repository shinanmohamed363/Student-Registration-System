import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../models/course.dart';
import '../utils/response_helper.dart';

/// Course controller handling course-related operations
class CourseController {
  final _db = Database.instance;

  /// Get all courses with optional filtering
  Future<Response> getAllCourses(Request request) async {
    try {
      // Get query parameters for filtering
      final params = request.url.queryParameters;
      final search = params['search'];
      final semester = params['semester'];
      final instructor = params['instructor'];

      // Build query with filters
      var query = 'SELECT * FROM courses WHERE 1=1';
      final values = <dynamic>[];

      if (search != null && search.isNotEmpty) {
        query += ' AND (course_code LIKE ? OR course_name LIKE ? OR description LIKE ?)';
        values.addAll(['%$search%', '%$search%', '%$search%']);
      }

      if (semester != null && semester.isNotEmpty) {
        query += ' AND semester = ?';
        values.add(semester);
      }

      if (instructor != null && instructor.isNotEmpty) {
        query += ' AND instructor LIKE ?';
        values.add('%$instructor%');
      }

      query += ' ORDER BY course_code';

      final results = await _db.query(query, values.isEmpty ? null : values);
      final courses = results.map((row) => Course.fromMap(row.fields).toJson()).toList();

      return ResponseHelper.success(
        message: 'Courses retrieved successfully',
        data: courses,
      );
    } catch (e) {
      print('Error in getAllCourses: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve courses',
      );
    }
  }

  /// Get course by ID
  Future<Response> getCourseById(Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return ResponseHelper.validationError(
          message: 'Invalid course ID',
        );
      }

      final courseRow = await _db.queryOne(
        'SELECT * FROM courses WHERE id = ?',
        [courseId],
      );

      if (courseRow == null) {
        return ResponseHelper.notFound(message: 'Course not found');
      }

      final course = Course.fromMap(courseRow.fields);

      // Get enrolled students count
      final enrollmentCount = await _db.queryOne(
        'SELECT COUNT(*) as count FROM enrollments WHERE course_id = ? AND status = ?',
        [courseId, 'active'],
      );

      final courseData = course.toJson();
      courseData['enrolledStudents'] = enrollmentCount?.fields['count'] ?? 0;

      return ResponseHelper.success(
        message: 'Course retrieved successfully',
        data: courseData,
      );
    } catch (e) {
      print('Error in getCourseById: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve course',
      );
    }
  }

  /// Get available courses (not full)
  Future<Response> getAvailableCourses(Request request) async {
    try {
      final results = await _db.query(
        'SELECT * FROM courses WHERE current_students < max_students ORDER BY course_code',
      );

      final courses = results.map((row) => Course.fromMap(row.fields).toJson()).toList();

      return ResponseHelper.success(
        message: 'Available courses retrieved successfully',
        data: courses,
      );
    } catch (e) {
      print('Error in getAvailableCourses: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve available courses',
      );
    }
  }

  /// Get course assignments
  Future<Response> getCourseAssignments(Request request, String id) async {
    try {
      final courseId = int.tryParse(id);
      if (courseId == null) {
        return ResponseHelper.validationError(
          message: 'Invalid course ID',
        );
      }

      final results = await _db.query(
        'SELECT * FROM assignments WHERE course_id = ? ORDER BY due_date',
        [courseId],
      );

      final assignments = results.map((row) {
        return {
          'id': row.fields['id'],
          'courseId': row.fields['course_id'],
          'assignmentName': row.fields['assignment_name'],
          'description': row.fields['description'],
          'maxMarks': row.fields['max_marks'],
          'dueDate': row.fields['due_date']?.toString(),
          'createdAt': row.fields['created_at']?.toString(),
        };
      }).toList();

      return ResponseHelper.success(
        message: 'Course assignments retrieved successfully',
        data: assignments,
      );
    } catch (e) {
      print('Error in getCourseAssignments: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve course assignments',
      );
    }
  }

  /// Search courses
  Future<Response> searchCourses(Request request) async {
    try {
      final params = request.url.queryParameters;
      final query = params['q'];

      if (query == null || query.isEmpty) {
        return ResponseHelper.validationError(
          message: 'Search query is required',
        );
      }

      final results = await _db.query(
        '''
        SELECT * FROM courses
        WHERE course_code LIKE ? OR course_name LIKE ? OR description LIKE ? OR instructor LIKE ?
        ORDER BY course_code
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      final courses = results.map((row) => Course.fromMap(row.fields).toJson()).toList();

      return ResponseHelper.success(
        message: 'Search completed successfully',
        data: courses,
      );
    } catch (e) {
      print('Error in searchCourses: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to search courses',
      );
    }
  }
}

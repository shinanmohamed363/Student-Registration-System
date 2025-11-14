import '../datasources/enrollment_datasource.dart';
import '../models/enrollment_model.dart';
import '../models/grade_model.dart';

/// Enrollment repository
/// Provides clean interface for enrollment operations with error handling
class EnrollmentRepository {
  final EnrollmentDataSource _dataSource;

  EnrollmentRepository({EnrollmentDataSource? dataSource})
      : _dataSource = dataSource ?? EnrollmentDataSource();

  /// Get student's enrolled courses
  Future<List<EnrollmentModel>> getMyCourses() async {
    try {
      return await _dataSource.getMyCourses();
    } catch (e) {
      rethrow;
    }
  }

  /// Get active enrollments only
  Future<List<EnrollmentModel>> getActiveEnrollments() async {
    try {
      return await _dataSource.getActiveEnrollments();
    } catch (e) {
      rethrow;
    }
  }

  /// Get student grades and assignments
  Future<List<GradeModel>> getGrades() async {
    try {
      return await _dataSource.getGrades();
    } catch (e) {
      rethrow;
    }
  }

  /// Enroll in a course
  Future<EnrollmentModel> enrollInCourse(int courseId) async {
    try {
      return await _dataSource.enrollInCourse(courseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Drop a course
  Future<void> dropCourse(int courseId) async {
    try {
      await _dataSource.dropCourse(courseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Re-enroll in a previously dropped course
  Future<void> reEnrollCourse(String enrollmentId) async {
    try {
      await _dataSource.reEnrollCourse(enrollmentId);
    } catch (e) {
      rethrow;
    }
  }
}

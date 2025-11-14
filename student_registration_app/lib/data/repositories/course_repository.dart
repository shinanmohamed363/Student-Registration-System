import '../datasources/course_datasource.dart';
import '../models/course_model.dart';

/// Course repository
/// Provides clean interface for course operations with error handling
class CourseRepository {
  final CourseDataSource _dataSource;

  CourseRepository({CourseDataSource? dataSource})
      : _dataSource = dataSource ?? CourseDataSource();

  /// Get all courses with optional filters
  Future<List<CourseModel>> getAllCourses({
    String? search,
    String? semester,
    String? instructor,
  }) async {
    try {
      return await _dataSource.getAllCourses(
        search: search,
        semester: semester,
        instructor: instructor,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get available courses (not full)
  Future<List<CourseModel>> getAvailableCourses() async {
    try {
      return await _dataSource.getAvailableCourses();
    } catch (e) {
      rethrow;
    }
  }

  /// Search courses
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      return await _dataSource.searchCourses(query);
    } catch (e) {
      rethrow;
    }
  }

  /// Get course by ID
  Future<CourseModel> getCourseById(int id) async {
    try {
      return await _dataSource.getCourseById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get course assignments
  Future<List<Map<String, dynamic>>> getCourseAssignments(int courseId) async {
    try {
      return await _dataSource.getCourseAssignments(courseId);
    } catch (e) {
      rethrow;
    }
  }
}

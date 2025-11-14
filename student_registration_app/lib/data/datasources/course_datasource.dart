import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/course_model.dart';

/// Course data source
/// Handles all course-related API calls
class CourseDataSource {
  final ApiClient _apiClient;

  CourseDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all courses with optional filters
  Future<List<CourseModel>> getAllCourses({
    String? search,
    String? semester,
    String? instructor,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (semester != null && semester.isNotEmpty) {
      queryParams['semester'] = semester;
    }
    if (instructor != null && instructor.isNotEmpty) {
      queryParams['instructor'] = instructor;
    }

    final response = await _apiClient.get(
      ApiConstants.courses,
      queryParameters: queryParams,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => CourseModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get available courses (not full)
  Future<List<CourseModel>> getAvailableCourses() async {
    final response = await _apiClient.get(ApiConstants.availableCourses);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => CourseModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Search courses
  Future<List<CourseModel>> searchCourses(String query) async {
    final response = await _apiClient.get(
      ApiConstants.searchCourses,
      queryParameters: {'q': query},
    );

    final data = response['data'] as List<dynamic>;
    return data.map((json) => CourseModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get course by ID
  Future<CourseModel> getCourseById(int id) async {
    final response = await _apiClient.get(ApiConstants.courseById(id));
    final data = response['data'] as Map<String, dynamic>;
    return CourseModel.fromJson(data);
  }

  /// Get course assignments
  Future<List<Map<String, dynamic>>> getCourseAssignments(int courseId) async {
    final response = await _apiClient.get(ApiConstants.courseAssignments(courseId));
    final data = response['data'] as List<dynamic>;
    return data.map((json) => json as Map<String, dynamic>).toList();
  }
}

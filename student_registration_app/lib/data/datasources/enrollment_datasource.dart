import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/enrollment_model.dart';
import '../models/grade_model.dart';

/// Enrollment data source
/// Handles all enrollment-related API calls
class EnrollmentDataSource {
  final ApiClient _apiClient;

  EnrollmentDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get student's enrolled courses
  Future<List<EnrollmentModel>> getMyCourses() async {
    final response = await _apiClient.get(ApiConstants.myCourses);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get active enrollments only
  Future<List<EnrollmentModel>> getActiveEnrollments() async {
    final response = await _apiClient.get(ApiConstants.activeEnrollments);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => EnrollmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get student grades and assignments
  Future<List<GradeModel>> getGrades() async {
    final response = await _apiClient.get(ApiConstants.grades);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => GradeModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Enroll in a course
  Future<EnrollmentModel> enrollInCourse(int courseId) async {
    final response = await _apiClient.post(
      ApiConstants.enrollInCourse(courseId),
      {},
    );

    final data = response['data'] as Map<String, dynamic>;
    return EnrollmentModel.fromJson(data);
  }

  /// Drop a course
  Future<void> dropCourse(int courseId) async {
    await _apiClient.delete(ApiConstants.dropCourse(courseId));
  }

  /// Re-enroll in a previously dropped course
  Future<void> reEnrollCourse(String enrollmentId) async {
    await _apiClient.put(
      ApiConstants.reEnrollCourse(enrollmentId),
      {},
    );
  }
}

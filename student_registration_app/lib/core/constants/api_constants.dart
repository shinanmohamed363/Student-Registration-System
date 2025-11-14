/// API endpoint constants
/// Configuration for backend API endpoints
class ApiConstants {
  // Base URL - Update this to match your backend server
  static const String baseUrl = 'http://localhost:8080/api';

  // For Android emulator, use: http://10.0.2.2:8080/api
  // For physical device, use your computer's IP: http://192.168.x.x:8080/api

  // Authentication endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/auth/profile';
  static const String updateProfile = '$baseUrl/auth/profile';
  static const String changePassword = '$baseUrl/auth/change-password';

  // Course endpoints
  static const String courses = '$baseUrl/courses';
  static const String availableCourses = '$baseUrl/courses/available';
  static const String searchCourses = '$baseUrl/courses/search';

  // Get specific course
  static String courseById(int id) => '$baseUrl/courses/$id';

  // Get course assignments
  static String courseAssignments(int id) => '$baseUrl/courses/$id/assignments';

  // Enrollment endpoints
  static const String myCourses = '$baseUrl/enrollments/my-courses';
  static const String activeEnrollments = '$baseUrl/enrollments/active';
  static const String grades = '$baseUrl/enrollments/grades';

  // Enroll in course
  static String enrollInCourse(int courseId) => '$baseUrl/enrollments/$courseId';

  // Drop course
  static String dropCourse(int courseId) => '$baseUrl/enrollments/$courseId';

  // Re-enroll in course
  static String reEnrollCourse(String enrollmentId) => '$baseUrl/enrollments/$enrollmentId/re-enroll';

  // Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
}

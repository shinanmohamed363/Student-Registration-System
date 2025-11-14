import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/storage_helper.dart';
import '../models/student_model.dart';

/// Authentication data source
/// Handles all authentication-related API calls
class AuthDataSource {
  final ApiClient _apiClient;
  final StorageHelper _storage;

  AuthDataSource({ApiClient? apiClient, StorageHelper? storage})
      : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? StorageHelper();

  /// Register a new student
  Future<Map<String, dynamic>> register({
    required String studentId,
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      {
        'studentId': studentId,
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      },
      requiresAuth: false,
    );

    // Extract data from response
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final studentData = data['student'] as Map<String, dynamic>;

    // Save token and user data
    await _storage.saveToken(token);
    final student = StudentModel.fromJson(studentData);
    await _storage.saveUserData(
      userId: student.id!,
      email: student.email,
      name: student.name,
      studentId: student.studentId,
    );

    return data;
  }

  /// Login student
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    // Extract data from response
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final studentData = data['student'] as Map<String, dynamic>;

    // Save token and user data
    await _storage.saveToken(token);
    await _storage.saveRememberMe(rememberMe);

    final student = StudentModel.fromJson(studentData);
    await _storage.saveUserData(
      userId: student.id!,
      email: student.email,
      name: student.name,
      studentId: student.studentId,
    );

    return data;
  }

  /// Get current user profile
  Future<StudentModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    final data = response['data'] as Map<String, dynamic>;
    return StudentModel.fromJson(data);
  }

  /// Update user profile
  Future<StudentModel> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;

    final response = await _apiClient.put(ApiConstants.updateProfile, body);
    final data = response['data'] as Map<String, dynamic>;

    // Update stored user data
    final student = StudentModel.fromJson(data);
    await _storage.saveUserData(
      userId: student.id!,
      email: student.email,
      name: student.name,
      studentId: student.studentId,
    );

    return student;
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.changePassword,
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    await _storage.clearAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getStoredUserData() async {
    final userId = await _storage.getUserId();
    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();
    final studentId = await _storage.getStudentId();

    if (userId == null || email == null || name == null || studentId == null) {
      return null;
    }

    return {
      'id': userId,
      'email': email,
      'name': name,
      'studentId': studentId,
    };
  }
}

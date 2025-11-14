import '../../core/errors/failures.dart';
import '../datasources/auth_datasource.dart';
import '../models/student_model.dart';

/// Authentication repository
/// Provides clean interface for authentication operations with error handling
class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository({AuthDataSource? dataSource})
      : _dataSource = dataSource ?? AuthDataSource();

  /// Register a new student
  Future<({StudentModel student, String token})?> register({
    required String studentId,
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    try {
      final result = await _dataSource.register(
        studentId: studentId,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
      );

      final student = StudentModel.fromJson(result['student'] as Map<String, dynamic>);
      final token = result['token'] as String;

      return (student: student, token: token);
    } catch (e) {
      rethrow;
    }
  }

  /// Login student
  Future<({StudentModel student, String token})?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final result = await _dataSource.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final student = StudentModel.fromJson(result['student'] as Map<String, dynamic>);
      final token = result['token'] as String;

      return (student: student, token: token);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<StudentModel> getProfile() async {
    try {
      return await _dataSource.getProfile();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<StudentModel> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    try {
      return await _dataSource.updateProfile(
        name: name,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _dataSource.isLoggedIn();
  }

  /// Get stored user data
  Future<StudentModel?> getStoredUser() async {
    try {
      final userData = await _dataSource.getStoredUserData();
      if (userData == null) return null;
      return StudentModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
}

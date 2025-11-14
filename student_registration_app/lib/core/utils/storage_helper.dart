import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Helper class for local storage operations
/// Uses SharedPreferences to store user data and authentication tokens
class StorageHelper {
  /// Save authentication token
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(AppConstants.keyToken, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  /// Remove authentication token
  Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(AppConstants.keyToken);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user data
  Future<bool> saveUserData({
    required int userId,
    required String email,
    required String name,
    required String studentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setString(AppConstants.keyUserName, name);
    await prefs.setString(AppConstants.keyStudentId, studentId);
    return true;
  }

  /// Get user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.keyUserId);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserEmail);
  }

  /// Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserName);
  }

  /// Get student ID
  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyStudentId);
  }

  /// Save remember me preference
  Future<bool> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(AppConstants.keyRememberMe, value);
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyRememberMe) ?? false;
  }

  /// Clear all user data (logout)
  Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}

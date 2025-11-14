import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Authentication provider for state management
/// Manages user authentication state and operations
class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // State variables
  StudentModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  StudentModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  /// Initialize authentication state
  Future<void> initialize() async {
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _repository.getStoredUser();
        _isAuthenticated = _currentUser != null;
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Register a new student
  Future<bool> register({
    required String studentId,
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        studentId: studentId,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
      );

      if (result != null) {
        _currentUser = result.student;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on ValidationFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login student
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (result != null) {
        _currentUser = result.student;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      _currentUser = await _repository.getProfile();
      notifyListeners();
    } catch (e) {
      // Silently fail, keep existing user data
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.updateProfile(
        name: name,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to change password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _repository.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Silently fail, clear state anyway
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

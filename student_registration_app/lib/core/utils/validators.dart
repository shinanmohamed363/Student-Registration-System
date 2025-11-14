import 'package:email_validator/email_validator.dart';
import '../constants/app_constants.dart';

/// Input validation utility class
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    // Check for uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < AppConstants.minNameLength) {
      return '$fieldName must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.trim().length > AppConstants.maxNameLength) {
      return '$fieldName must not exceed ${AppConstants.maxNameLength} characters';
    }

    return null;
  }

  /// Validate student ID
  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }

    // Alphanumeric, 3-20 characters
    if (!RegExp(r'^[A-Z0-9]{3,20}$').hasMatch(value.trim())) {
      return 'Student ID must be 3-20 alphanumeric characters';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    if (!RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}

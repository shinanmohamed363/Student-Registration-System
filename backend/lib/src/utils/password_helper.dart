import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper class for password hashing and verification
/// Uses SHA-256 for hashing (in production, use bcrypt for better security)
class PasswordHelper {
  /// Hash a password using SHA-256
  /// Note: In production, consider using bcrypt or argon2 for better security
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verify a password against a hash
  static bool verifyPassword(String password, String hash) {
    final hashedPassword = hashPassword(password);
    return hashedPassword == hash;
  }

  /// Validate password strength
  /// Returns true if password meets minimum requirements
  static bool isValidPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // Contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

  /// Get password validation error message
  static String getPasswordValidationError(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    return '';
  }
}

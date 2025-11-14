import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../config/database.dart';
import '../models/student.dart';
import '../utils/password_helper.dart';
import '../utils/jwt_helper.dart';
import '../utils/response_helper.dart';
import '../middleware/validation_middleware.dart';

/// Authentication controller handling student registration and login
class AuthController {
  final _db = Database.instance;

  /// Register a new student
  Future<Response> register(Request request) async {
    try {
      // Parse request body
      final bodyString = request.context['body'] as String? ?? await request.readAsString();
      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Validate required fields
      final requiredFields = ['studentId', 'name', 'email', 'password'];
      if (!ValidationMiddleware.validateRequiredFields(body, requiredFields)) {
        final missing = ValidationMiddleware.getMissingFields(body, requiredFields);
        return ResponseHelper.validationError(
          message: 'Missing required fields: ${missing.join(', ')}',
        );
      }

      final studentId = body['studentId'] as String;
      final name = body['name'] as String;
      final email = body['email'] as String;
      final password = body['password'] as String;
      final phone = body['phone'] as String?;
      final address = body['address'] as String?;
      final dateOfBirth = body['dateOfBirth'] as String?;

      // Validate email format
      if (!ValidationMiddleware.isValidEmail(email)) {
        return ResponseHelper.validationError(
          message: 'Invalid email format',
        );
      }

      // Validate student ID format
      if (!ValidationMiddleware.isValidStudentId(studentId)) {
        return ResponseHelper.validationError(
          message: 'Student ID must be alphanumeric and 3-20 characters long',
        );
      }

      // Validate password strength
      if (!PasswordHelper.isValidPassword(password)) {
        return ResponseHelper.validationError(
          message: PasswordHelper.getPasswordValidationError(password),
        );
      }

      // Check if student ID or email already exists
      final existingStudent = await _db.query(
        'SELECT id FROM students WHERE student_id = ? OR email = ?',
        [studentId, email],
      );

      if (existingStudent.isNotEmpty) {
        return ResponseHelper.error(
          message: 'Student ID or email already exists',
          statusCode: 409,
        );
      }

      // Hash password
      final passwordHash = PasswordHelper.hashPassword(password);

      // Insert student
      final insertId = await _db.insert(
        '''
        INSERT INTO students (student_id, name, email, password_hash, phone, address, date_of_birth)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [studentId, name, email, passwordHash, phone, address, dateOfBirth],
      );

      // Generate JWT token
      final token = JwtHelper.generateToken(insertId, email);

      // Fetch created student
      final studentRow = await _db.queryOne(
        'SELECT * FROM students WHERE id = ?',
        [insertId],
      );

      final student = Student.fromMap(studentRow!.fields);

      return ResponseHelper.success(
        message: 'Student registered successfully',
        data: {
          'token': token,
          'student': student.toJson(),
        },
        statusCode: 201,
      );
    } catch (e) {
      print('Error in register: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to register student',
      );
    }
  }

  /// Login student
  Future<Response> login(Request request) async {
    try {
      // Parse request body
      final bodyString = request.context['body'] as String? ?? await request.readAsString();
      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Validate required fields
      final requiredFields = ['email', 'password'];
      if (!ValidationMiddleware.validateRequiredFields(body, requiredFields)) {
        return ResponseHelper.validationError(
          message: 'Email and password are required',
        );
      }

      final email = body['email'] as String;
      final password = body['password'] as String;

      // Find student by email
      final studentRow = await _db.queryOne(
        'SELECT * FROM students WHERE email = ?',
        [email],
      );

      if (studentRow == null) {
        return ResponseHelper.unauthorized(
          message: 'Invalid email or password',
        );
      }

      final student = Student.fromMap(studentRow.fields);

      // Verify password
      if (!PasswordHelper.verifyPassword(password, student.passwordHash!)) {
        return ResponseHelper.unauthorized(
          message: 'Invalid email or password',
        );
      }

      // Generate JWT token
      final token = JwtHelper.generateToken(student.id!, email);

      return ResponseHelper.success(
        message: 'Login successful',
        data: {
          'token': token,
          'student': student.toJson(),
        },
      );
    } catch (e) {
      print('Error in login: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to login',
      );
    }
  }

  /// Get current student profile (requires authentication)
  Future<Response> getProfile(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      final studentRow = await _db.queryOne(
        'SELECT * FROM students WHERE id = ?',
        [studentId],
      );

      if (studentRow == null) {
        return ResponseHelper.notFound(message: 'Student not found');
      }

      final student = Student.fromMap(studentRow.fields);

      return ResponseHelper.success(
        message: 'Profile retrieved successfully',
        data: student.toJson(),
      );
    } catch (e) {
      print('Error in getProfile: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to retrieve profile',
      );
    }
  }

  /// Update student profile (requires authentication)
  Future<Response> updateProfile(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      // Parse request body
      final bodyString = request.context['body'] as String? ?? await request.readAsString();
      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Build update query dynamically based on provided fields
      final updates = <String>[];
      final values = <dynamic>[];

      if (body.containsKey('name') && body['name'] != null) {
        updates.add('name = ?');
        values.add(body['name']);
      }
      if (body.containsKey('phone') && body['phone'] != null) {
        updates.add('phone = ?');
        values.add(body['phone']);
      }
      if (body.containsKey('address') && body['address'] != null) {
        updates.add('address = ?');
        values.add(body['address']);
      }
      if (body.containsKey('dateOfBirth') && body['dateOfBirth'] != null) {
        updates.add('date_of_birth = ?');
        values.add(body['dateOfBirth']);
      }

      if (updates.isEmpty) {
        return ResponseHelper.validationError(
          message: 'No fields to update',
        );
      }

      // Add student ID to values
      values.add(studentId);

      // Update student
      await _db.execute(
        'UPDATE students SET ${updates.join(', ')} WHERE id = ?',
        values,
      );

      // Fetch updated student
      final studentRow = await _db.queryOne(
        'SELECT * FROM students WHERE id = ?',
        [studentId],
      );

      final student = Student.fromMap(studentRow!.fields);

      return ResponseHelper.success(
        message: 'Profile updated successfully',
        data: student.toJson(),
      );
    } catch (e) {
      print('Error in updateProfile: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to update profile',
      );
    }
  }

  /// Change password (requires authentication)
  Future<Response> changePassword(Request request) async {
    try {
      final studentId = request.context['studentId'] as int;

      // Parse request body
      final bodyString = request.context['body'] as String? ?? await request.readAsString();
      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      // Validate required fields
      final requiredFields = ['currentPassword', 'newPassword'];
      if (!ValidationMiddleware.validateRequiredFields(body, requiredFields)) {
        return ResponseHelper.validationError(
          message: 'Current password and new password are required',
        );
      }

      final currentPassword = body['currentPassword'] as String;
      final newPassword = body['newPassword'] as String;

      // Validate new password strength
      if (!PasswordHelper.isValidPassword(newPassword)) {
        return ResponseHelper.validationError(
          message: PasswordHelper.getPasswordValidationError(newPassword),
        );
      }

      // Get current student
      final studentRow = await _db.queryOne(
        'SELECT * FROM students WHERE id = ?',
        [studentId],
      );

      if (studentRow == null) {
        return ResponseHelper.notFound(message: 'Student not found');
      }

      final student = Student.fromMap(studentRow.fields);

      // Verify current password
      if (!PasswordHelper.verifyPassword(currentPassword, student.passwordHash!)) {
        return ResponseHelper.unauthorized(
          message: 'Current password is incorrect',
        );
      }

      // Hash new password
      final newPasswordHash = PasswordHelper.hashPassword(newPassword);

      // Update password
      await _db.execute(
        'UPDATE students SET password_hash = ? WHERE id = ?',
        [newPasswordHash, studentId],
      );

      return ResponseHelper.success(
        message: 'Password changed successfully',
      );
    } catch (e) {
      print('Error in changePassword: $e');
      return ResponseHelper.internalServerError(
        message: 'Failed to change password',
      );
    }
  }
}

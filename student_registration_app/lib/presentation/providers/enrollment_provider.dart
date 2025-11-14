import 'package:flutter/foundation.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/enrollment_repository.dart';

/// Enrollment provider for state management
/// Manages student enrollments and grades
class EnrollmentProvider with ChangeNotifier {
  final EnrollmentRepository _repository;

  EnrollmentProvider({EnrollmentRepository? repository})
      : _repository = repository ?? EnrollmentRepository();

  // State variables
  List<EnrollmentModel> _enrollments = [];
  List<GradeModel> _grades = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<EnrollmentModel> get enrollments => _enrollments;
  List<EnrollmentModel> get activeEnrollments =>
      _enrollments.where((e) => e.isActive).toList();
  List<GradeModel> get grades => _grades;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Load student's enrolled courses
  Future<void> loadMyCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _enrollments = await _repository.getMyCourses();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load enrolled courses';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load student grades
  Future<void> loadGrades() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grades = await _repository.getGrades();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load grades';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enroll in a course
  Future<bool> enrollInCourse(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final enrollment = await _repository.enrollInCourse(courseId);
      _enrollments.add(enrollment);
      _successMessage = 'Successfully enrolled in course';

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('full')
          ? 'Course is full'
          : e.toString().contains('Already enrolled')
              ? 'Already enrolled in this course'
              : 'Failed to enroll in course';

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Drop a course
  Future<bool> dropCourse(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.dropCourse(courseId);
      _enrollments.removeWhere((e) => e.courseId == courseId);
      _successMessage = 'Successfully dropped course';

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to drop course';

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Re-enroll in a previously dropped course
  Future<bool> reEnrollCourse(String enrollmentId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.reEnrollCourse(enrollmentId);
      _successMessage = 'Successfully re-enrolled in course';

      // Reload data to refresh the status
      await loadGrades();
      await loadMyCourses();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to re-enroll in course';

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if enrolled in a course
  bool isEnrolledIn(int courseId) {
    return _enrollments.any((e) => e.courseId == courseId && e.isActive);
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Refresh enrollments
  Future<void> refresh() async {
    await loadMyCourses();
  }
}

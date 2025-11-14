import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

/// Course provider for state management
/// Manages courses list and operations
class CourseProvider with ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  // State variables
  List<CourseModel> _courses = [];
  List<CourseModel> _availableCourses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CourseModel> get courses => _courses;
  List<CourseModel> get availableCourses => _availableCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all courses
  Future<void> loadCourses({
    String? search,
    String? semester,
    String? instructor,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _repository.getAllCourses(
        search: search,
        semester: semester,
        instructor: instructor,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load courses';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load available courses
  Future<void> loadAvailableCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableCourses = await _repository.getAvailableCourses();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load available courses';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search courses
  Future<void> searchCourses(String query) async {
    if (query.trim().isEmpty) {
      await loadCourses();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _repository.searchCourses(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search courses';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load course details
  Future<void> loadCourseDetails(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCourse = await _repository.getCourseById(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load course details';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh courses
  Future<void> refresh() async {
    await loadCourses();
  }
}

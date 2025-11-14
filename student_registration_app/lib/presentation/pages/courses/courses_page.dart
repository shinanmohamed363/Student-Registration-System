import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/course_card.dart';
import 'course_details_page.dart';

/// Courses page for browsing and searching courses
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _searchController = TextEditingController();
  bool _showAvailableOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final courseProvider = context.read<CourseProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();

    // Load courses and enrollment data
    if (_showAvailableOnly) {
      await courseProvider.loadAvailableCourses();
    } else {
      await courseProvider.loadCourses();
    }

    // Load enrollment and grades data to check for dropped courses
    await enrollmentProvider.loadMyCourses();
    await enrollmentProvider.loadGrades();
  }

  Future<void> _searchCourses(String query) async {
    final courseProvider = context.read<CourseProvider>();
    if (query.trim().isEmpty) {
      await _loadCourses();
    } else {
      await courseProvider.searchCourses(query);
    }
  }

  Future<void> _showReEnrollDialog(BuildContext context, CourseModel course, int enrollmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-enroll in Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to re-enroll in this course?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              course.courseName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              course.courseCode,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Re-enroll'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      final success = await enrollmentProvider.reEnrollCourse(enrollmentId.toString());

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully re-enrolled in ${course.courseCode}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          _loadCourses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to re-enroll in ${course.courseCode}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final enrollmentProvider = context.watch<EnrollmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchCourses('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _searchCourses(value);
                  },
                ),
                const SizedBox(height: 12),
                // Filter chip
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Available only'),
                      selected: _showAvailableOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showAvailableOnly = selected;
                        });
                        _loadCourses();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Courses list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCourses,
              child: courseProvider.isLoading
                  ? const LoadingWidget(message: 'Loading courses...')
                  : courseProvider.courses.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'No Courses Found',
                          message: _searchController.text.isNotEmpty
                              ? 'No courses match your search'
                              : 'No courses available at the moment',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courseProvider.courses.length,
                          itemBuilder: (context, index) {
                            final course = courseProvider.courses[index];
                            final isEnrolled = enrollmentProvider.isEnrolledIn(course.id);

                            // Check if course is dropped
                            final droppedGrade = enrollmentProvider.grades.where(
                              (grade) => grade.courseId == course.id && grade.status == 'dropped'
                            ).firstOrNull;
                            final isDropped = droppedGrade != null;

                            return CourseCard(
                              course: course,
                              onTap: () {
                                if (isDropped) {
                                  // Show re-enroll dialog for dropped courses
                                  _showReEnrollDialog(context, course, droppedGrade.enrollmentId);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailsPage(courseId: course.id),
                                    ),
                                  );
                                }
                              },
                              trailing: isEnrolled
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'ENROLLED',
                                        style: TextStyle(
                                          color: AppTheme.successColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : isDropped
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.errorColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'DROPPED',
                                            style: TextStyle(
                                              color: AppTheme.errorColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

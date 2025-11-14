import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

/// Dropped Courses page showing previously dropped courses
class DroppedCoursesPage extends StatefulWidget {
  const DroppedCoursesPage({super.key});

  @override
  State<DroppedCoursesPage> createState() => _DroppedCoursesPageState();
}

class _DroppedCoursesPageState extends State<DroppedCoursesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDroppedCourses();
    });
  }

  Future<void> _loadDroppedCourses() async {
    final enrollmentProvider = context.read<EnrollmentProvider>();
    await enrollmentProvider.loadGrades();
  }

  Future<void> _reEnrollCourse(int enrollmentId, String courseCode, String courseName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-enroll in Course'),
        content: Text('Do you want to re-enroll in $courseCode - $courseName?'),
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
              content: Text('Successfully re-enrolled in $courseCode'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          _loadDroppedCourses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to re-enroll in $courseCode'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = context.watch<EnrollmentProvider>();

    // Filter dropped courses
    final droppedCourses = enrollmentProvider.grades
        .where((grade) => grade.status == 'dropped')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropped Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDroppedCourses,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDroppedCourses,
        child: enrollmentProvider.isLoading
            ? const LoadingWidget(message: 'Loading dropped courses...')
            : droppedCourses.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.school_outlined,
                    title: 'No Dropped Courses',
                    message: 'You haven\'t dropped any courses yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: droppedCourses.length,
                    itemBuilder: (context, index) {
                      final course = droppedCourses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                                    child: Text(
                                      course.courseCode.substring(0, 2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.courseName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.courseCode,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'DROPPED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Course info
                              if (course.credits > 0)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      size: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${course.credits} Credits',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),

                              if (course.assignments.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${course.assignments.length} Assignment${course.assignments.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Re-enroll button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _reEnrollCourse(
                                    course.enrollmentId,
                                    course.courseCode,
                                    course.courseName,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Re-enroll in Course'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    side: const BorderSide(color: AppTheme.primaryColor),
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

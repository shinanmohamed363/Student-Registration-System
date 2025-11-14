import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/grade_model.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

/// Course details page with enrollment functionality
class CourseDetailsPage extends StatefulWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourseDetails();
    });
  }

  Future<void> _loadCourseDetails() async {
    final courseProvider = context.read<CourseProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();

    // Load course details
    await courseProvider.loadCourseDetails(widget.courseId);

    // Load grades/assignments if enrolled
    await enrollmentProvider.loadGrades();
  }

  Future<void> _handleEnroll() async {
    final enrollmentProvider = context.read<EnrollmentProvider>();

    final success = await enrollmentProvider.enrollInCourse(widget.courseId);

    if (!mounted) return;

    if (success) {
      // Reload grades to get fresh assignment data
      await enrollmentProvider.loadGrades();

      Fluttertoast.showToast(
        msg: enrollmentProvider.successMessage ?? 'Enrolled successfully!',
        backgroundColor: AppTheme.successColor,
      );
      setState(() {}); // Refresh UI
    } else {
      Fluttertoast.showToast(
        msg: enrollmentProvider.errorMessage ?? 'Failed to enroll',
        backgroundColor: AppTheme.errorColor,
      );
    }
  }

  Future<void> _handleDrop() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drop Course'),
        content: const Text('Are you sure you want to drop this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Drop'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final enrollmentProvider = context.read<EnrollmentProvider>();
    final success = await enrollmentProvider.dropCourse(widget.courseId);

    if (!mounted) return;

    if (success) {
      // Reload grades to update assignment data
      await enrollmentProvider.loadGrades();

      Fluttertoast.showToast(
        msg: 'Course dropped successfully',
        backgroundColor: AppTheme.successColor,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: enrollmentProvider.errorMessage ?? 'Failed to drop course',
        backgroundColor: AppTheme.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final enrollmentProvider = context.watch<EnrollmentProvider>();
    final course = courseProvider.selectedCourse;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: courseProvider.isLoading || course == null
          ? const LoadingWidget(message: 'Loading course details...')
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Course header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDark,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.courseCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course.courseName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Course info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info cards
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.school,
                                label: 'Credits',
                                value: '${course.credits}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.people,
                                label: 'Available',
                                value: '${course.computedAvailableSeats}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Instructor
                        if (course.instructor != null) ...[
                          _DetailRow(
                            icon: Icons.person,
                            label: 'Instructor',
                            value: course.instructor!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Schedule
                        if (course.schedule != null) ...[
                          _DetailRow(
                            icon: Icons.schedule,
                            label: 'Schedule',
                            value: course.schedule!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Semester
                        if (course.semester != null) ...[
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Semester',
                            value: course.semester!,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Description
                        if (course.description != null) ...[
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Prerequisites
                        if (course.prerequisites != null && course.prerequisites!.isNotEmpty) ...[
                          const Text(
                            'Prerequisites',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.prerequisites!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Assignment Marks Section (only if enrolled)
                        Consumer<EnrollmentProvider>(
                          builder: (context, provider, _) {
                            final isEnrolled = provider.isEnrolledIn(widget.courseId);
                            if (!isEnrolled) return const SizedBox.shrink();

                            // Find the grade info for this course
                            final gradeInfo = provider.grades.firstWhere(
                              (grade) => grade.courseId == widget.courseId,
                              orElse: () => GradeModel(
                                enrollmentId: 0,
                                courseId: widget.courseId,
                                courseCode: course.courseCode,
                                courseName: course.courseName,
                                credits: course.credits,
                                status: 'active',
                                assignments: [],
                              ),
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 32),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Assignment Marks',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (gradeInfo.assignments.isEmpty)
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'No assignments available yet',
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ...gradeInfo.assignments.map(
                                    (assignment) => _AssignmentCard(
                                      assignment: assignment,
                                    ),
                                  ),

                                // Overall grade if available
                                if (gradeInfo.grade != null || gradeInfo.finalMarks != null) ...[
                                  const SizedBox(height: 16),
                                  Card(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Final Grade',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (gradeInfo.finalMarks != null)
                                                Text(
                                                  '${gradeInfo.finalMarks!.toStringAsFixed(1)}%',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                              if (gradeInfo.grade != null) ...[
                                                if (gradeInfo.finalMarks != null)
                                                  const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    gradeInfo.grade!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),

                        // Enrollment button
                        Consumer<EnrollmentProvider>(
                          builder: (context, provider, _) {
                            final isEnrolled = provider.isEnrolledIn(widget.courseId);

                            if (isEnrolled) {
                              return CustomButton(
                                text: 'Drop Course',
                                onPressed: _handleDrop,
                                isLoading: provider.isLoading,
                                backgroundColor: AppTheme.errorColor,
                                icon: Icons.remove_circle_outline,
                              );
                            }

                            return CustomButton(
                              text: course.computedIsFull ? 'Course Full' : 'Enroll Now',
                              onPressed: course.computedIsFull ? null : _handleEnroll,
                              isLoading: provider.isLoading,
                              backgroundColor: AppTheme.successColor,
                              icon: Icons.add_circle_outline,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Info card widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Assignment card widget
class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;

  const _AssignmentCard({required this.assignment});

  Color _getGradeColor(double? percentage) {
    if (percentage == null) return AppTheme.textSecondary;
    if (percentage >= 90) return AppTheme.successColor;
    if (percentage >= 75) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = assignment.percentage;
    final isGraded = assignment.marks != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.assignmentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Max Marks: ${assignment.maxMarks.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Grade display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isGraded) ...[
                      Text(
                        '${assignment.marks!.toStringAsFixed(1)} / ${assignment.maxMarks.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getGradeColor(percentage),
                        ),
                      ),
                      if (percentage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(percentage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(percentage),
                            ),
                          ),
                        ),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Not Graded',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Submission status
            if (assignment.isSubmitted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Submitted',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.pending,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Not Submitted',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // Feedback
            if (assignment.feedback != null && assignment.feedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.feedback,
                          size: 14,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assignment.feedback!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

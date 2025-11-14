import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

/// Grades page showing academic records
class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrades();
    });
  }

  Future<void> _loadGrades() async {
    final enrollmentProvider = context.read<EnrollmentProvider>();
    await enrollmentProvider.loadGrades();
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentProvider = context.watch<EnrollmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGrades,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGrades,
        child: enrollmentProvider.isLoading
            ? const LoadingWidget(message: 'Loading grades...')
            : Builder(
                builder: (context) {
                  // Filter out dropped courses
                  final activeGrades = enrollmentProvider.grades
                      .where((grade) => grade.status != 'dropped')
                      .toList();

                  if (activeGrades.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.assignment_outlined,
                      title: 'No Grades Yet',
                      message: 'Your grades and assignments will appear here once available.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeGrades.length,
                    itemBuilder: (context, index) {
                      final grade = activeGrades[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                            child: Text(
                              grade.courseCode.substring(0, 2),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                          title: Text(
                            grade.courseName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(grade.courseCode),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (grade.grade != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getGradeColor(grade.grade!).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Grade: ${grade.grade}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _getGradeColor(grade.grade!),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (grade.finalMarks != null)
                                    Text(
                                      '${grade.finalMarks}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            if (grade.assignments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No assignments yet'),
                              )
                            else
                              ...grade.assignments.map((assignment) {
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    assignment.isSubmitted ? Icons.check_circle : Icons.assignment,
                                    color: assignment.isSubmitted ? AppTheme.successColor : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  title: Text(
                                    assignment.assignmentName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: assignment.marks != null
                                      ? Text(
                                          '${assignment.marks}/${assignment.maxMarks} (${assignment.percentage?.toStringAsFixed(1)}%)',
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      : Text(
                                          'Max: ${assignment.maxMarks}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                  trailing: assignment.marks != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPercentageColor(assignment.percentage ?? 0).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getGradeFromPercentage(assignment.percentage ?? 0),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _getPercentageColor(assignment.percentage ?? 0),
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              }),
                            if (grade.averageAssignmentMarks != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                color: AppTheme.backgroundColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Average:',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${grade.averageAssignmentMarks!.toStringAsFixed(1)}%',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
        return AppTheme.successColor;
      case 'B':
      case 'B+':
        return AppTheme.infoColor;
      case 'C':
      case 'C+':
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 70) return AppTheme.infoColor;
    if (percentage >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getGradeFromPercentage(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}

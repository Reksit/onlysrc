import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';

class MyAssessmentsWidget extends StatefulWidget {
  const MyAssessmentsWidget({super.key});

  @override
  State<MyAssessmentsWidget> createState() => _MyAssessmentsWidgetState();
}

class _MyAssessmentsWidgetState extends State<MyAssessmentsWidget> {
  List<Assessment> _assessments = [];
  bool _loading = true;
  Assessment? _editingAssessment;

  @override
  void initState() {
    super.initState();
    _fetchAssessments();
  }

  Future<void> _fetchAssessments() async {
    try {
      final assessments = await ApiService.getProfessorAssessments();
      setState(() {
        _assessments = assessments;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to fetch assessments');
    }
  }

  String _getAssessmentStatus(Assessment assessment) {
    final now = DateTime.now();
    if (now.isBefore(assessment.startTime)) return 'upcoming';
    if (now.isAfter(assessment.endTime)) return 'completed';
    return 'active';
  }

  bool _canEdit(Assessment assessment) {
    return DateTime.now().isBefore(assessment.startTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading assessments...');
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen.withOpacity(0.1), Colors.green.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Assessments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'Manage and track your assessments',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_assessments.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Assessments List
        Expanded(
          child: _assessments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text(
                        'No Assessments Created',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Start creating assessments to evaluate your students\' progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = _assessments[index];
                    return _buildAssessmentCard(assessment);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Assessment assessment) {
    final status = _getAssessmentStatus(assessment);
    final canEdit = _canEdit(assessment);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assessment Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assessment.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Assessment Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.schedule,
                        'Start Time',
                        _formatDateTime(assessment.startTime),
                        AppTheme.primaryGreen,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.schedule,
                        'End Time',
                        _formatDateTime(assessment.endTime),
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.timer,
                        'Duration',
                        '${assessment.duration} min',
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.people,
                        'Students',
                        '${assessment.assignedTo.length} assigned',
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons and Info
          Row(
            children: [
              if (canEdit)
                IconButton(
                  onPressed: () => _editAssessment(assessment),
                  icon: const Icon(Icons.edit, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              if (status == 'completed')
                IconButton(
                  onPressed: () => _viewResults(assessment),
                  icon: const Icon(Icons.visibility, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                ),
              if (canEdit)
                IconButton(
                  onPressed: () => _deleteAssessment(assessment),
                  icon: const Icon(Icons.delete, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              const Spacer(),
              
              // Status indicators
              Row(
                children: [
                  _buildStatusIndicator('${assessment.questions.length} questions', AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  _buildStatusIndicator('${assessment.totalMarks} marks', AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  _buildStatusIndicator('Created ${_formatDate(assessment.createdAt)}', AppTheme.primaryPurple),
                ],
              ),
            ],
          ),

          if (!canEdit && status != 'completed')
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    'Assessment is live',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return AppTheme.primaryBlue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _editAssessment(Assessment assessment) {
    if (!_canEdit(assessment)) {
      context.read<ToastProvider>().showWarning('Cannot edit assessment after it has started');
      return;
    }
    // Implement edit functionality
    context.read<ToastProvider>().showInfo('Edit functionality coming soon');
  }

  void _viewResults(Assessment assessment) {
    // Implement view results functionality
    context.read<ToastProvider>().showInfo('View results functionality coming soon');
  }

  void _deleteAssessment(Assessment assessment) {
    // Implement delete functionality
    context.read<ToastProvider>().showInfo('Delete functionality coming soon');
  }
}
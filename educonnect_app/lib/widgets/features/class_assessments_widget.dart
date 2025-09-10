import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';

class ClassAssessmentsWidget extends StatefulWidget {
  const ClassAssessmentsWidget({super.key});

  @override
  State<ClassAssessmentsWidget> createState() => _ClassAssessmentsWidgetState();
}

class _ClassAssessmentsWidgetState extends State<ClassAssessmentsWidget> {
  List<Assessment> _assessments = [];
  Assessment? _activeAssessment;
  bool _loading = true;
  bool _isActive = false;
  int _currentQuestion = 0;
  List<int> _answers = [];
  int _timeLeft = 0;
  bool _showResults = false;
  Map<String, dynamic>? _results;
  bool _isSubmitting = false;
  Set<String> _submittedAssessments = {};

  @override
  void initState() {
    super.initState();
    _fetchAssessments();
    _loadSubmissionStatus();
  }

  Future<void> _fetchAssessments() async {
    try {
      final assessments = await ApiService.getStudentAssessments();
      setState(() {
        _assessments = assessments;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (!error.toString().contains('404')) {
        context.read<ToastProvider>().showError(error.toString());
      }
    }
  }

  void _loadSubmissionStatus() {
    // In a real app, this would be stored in SharedPreferences
    // For now, we'll use a simple Set
  }

  void _saveSubmissionStatus(String assessmentId) {
    setState(() {
      _submittedAssessments.add(assessmentId);
    });
  }

  String _getAssessmentStatus(Assessment assessment) {
    if (_submittedAssessments.contains(assessment.id)) {
      return 'completed';
    }

    final now = DateTime.now();
    if (now.isBefore(assessment.startTime)) return 'upcoming';
    if (now.isAfter(assessment.endTime)) return 'missed';
    return 'active';
  }

  bool _isAssessmentActive(Assessment assessment) {
    final now = DateTime.now();
    return now.isAfter(assessment.startTime) && now.isBefore(assessment.endTime);
  }

  void _startAssessment(Assessment assessment) {
    final now = DateTime.now();
    
    if (now.isBefore(assessment.startTime)) {
      context.read<ToastProvider>().showWarning('Assessment has not started yet');
      return;
    }

    if (now.isAfter(assessment.endTime)) {
      context.read<ToastProvider>().showError('Assessment has ended');
      return;
    }

    if (_submittedAssessments.contains(assessment.id)) {
      context.read<ToastProvider>().showWarning('You have already submitted this assessment');
      return;
    }

    setState(() {
      _activeAssessment = assessment;
      _answers = List.filled(assessment.questions.length, -1);
      _currentQuestion = 0;
      _timeLeft = (assessment.duration * 60).clamp(
        0,
        assessment.endTime.difference(now).inSeconds,
      );
      _isActive = true;
      _showResults = false;
      _results = null;
    });

    context.read<ToastProvider>().showInfo('Assessment started! Good luck!');
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isActive) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _submitAssessment();
          }
        });
        return _timeLeft > 0 && _isActive;
      }
      return false;
    });
  }

  Future<void> _submitAssessment() async {
    if (_activeAssessment == null || _isSubmitting) return;

    setState(() {
      _isActive = false;
      _isSubmitting = true;
    });

    try {
      final submission = {
        'answers': _answers.asMap().entries.map((entry) => {
          'questionIndex': entry.key,
          'selectedAnswer': entry.value,
        }).toList(),
        'startedAt': DateTime.now().toIso8601String(),
      };

      final result = await ApiService.submitAssessment(_activeAssessment!.id, submission);
      
      if (result != null) {
        setState(() {
          _results = result;
          _showResults = true;
        });
        
        _saveSubmissionStatus(_activeAssessment!.id);
        
        // Log activity
        await ApiService.logActivity('ASSESSMENT_COMPLETED', 'Completed assessment: ${_activeAssessment!.title}');
        
        if (!mounted) return;
        context.read<ToastProvider>().showSuccess('Assessment submitted successfully!');
        
        setState(() {
          _activeAssessment = null;
          _isActive = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
      setState(() => _isActive = true); // Re-enable if submission fails
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading assessments...');
    }

    if (_showResults && _results != null) {
      return _buildResultsView();
    }

    if (_activeAssessment != null && _isActive) {
      return _buildAssessmentView();
    }

    return _buildAssessmentsList();
  }

  Widget _buildAssessmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.assignment, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Class Assessments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Assessments List
        Expanded(
          child: _assessments.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.assignment,
                  title: 'No Assessments Available',
                  subtitle: 'No assessments found for your courses.',
                )
              : ListView.builder(
                  itemCount: _assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = _assessments[index];
                    final status = _getAssessmentStatus(assessment);
                    final isActiveNow = _isAssessmentActive(assessment);
                    final isSubmitted = _submittedAssessments.contains(assessment.id);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      assessment.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      assessment.description,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  _buildStatusChip(_getStatusDisplay(status)),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(_getTimeStatus(assessment)),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Assessment Details
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  Icons.schedule,
                                  'Start',
                                  _formatDateTime(assessment.startTime),
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  Icons.schedule,
                                  'End',
                                  _formatDateTime(assessment.endTime),
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  Icons.timer,
                                  'Duration',
                                  '${assessment.duration} min',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  Icons.quiz,
                                  'Questions',
                                  '${assessment.questions.length}',
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: _buildActionButton(assessment, status, isActiveNow, isSubmitted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAssessmentView() {
    final currentQ = _activeAssessment!.questions[_currentQuestion];
    
    return Column(
      children: [
        // Timer and Progress
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Time Left: ${_formatTime(_timeLeft)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Question ${_currentQuestion + 1} of ${_activeAssessment!.questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _activeAssessment!.questions.length,
                backgroundColor: AppTheme.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Question
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQ.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQ.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = _answers.length > _currentQuestion && 
                                        _answers[_currentQuestion] == index;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQ.options[index],
                                      style: TextStyle(
                                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      text: 'Previous',
                      onPressed: _currentQuestion > 0 ? _previousQuestion : null,
                      variant: ButtonVariant.outline,
                    ),
                    CustomButton(
                      text: _currentQuestion == _activeAssessment!.questions.length - 1 
                          ? 'Submit Assessment' 
                          : 'Next',
                      onPressed: _isSubmitting ? null : (_currentQuestion == _activeAssessment!.questions.length - 1 
                          ? _submitAssessment 
                          : _nextQuestion),
                      variant: ButtonVariant.primary,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Assessment Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Here's your performance summary",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  '${_results!['score']}',
                  'Correct',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  '${_results!['totalMarks'] - _results!['score']}',
                  'Wrong',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  '${_results!['totalMarks']}',
                  'Total',
                  AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  '${_results!['percentage'].toStringAsFixed(1)}%',
                  'Percentage',
                  AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Return Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Return to Dashboard',
              onPressed: () {
                setState(() {
                  _showResults = false;
                  _results = null;
                  _activeAssessment = null;
                });
                _fetchAssessments();
              },
              variant: ButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(Map<String, dynamic> status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status['bgColor'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status['text'],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status['color'],
        ),
      ),
    );
  }

  Widget _buildActionButton(Assessment assessment, String status, bool isActiveNow, bool isSubmitted) {
    if (isActiveNow && !isSubmitted && status != 'completed') {
      return CustomButton(
        text: 'Start Assessment',
        onPressed: () => _startAssessment(assessment),
        variant: ButtonVariant.primary,
        icon: Icons.play_arrow,
      );
    }

    if (status == 'completed' || isSubmitted) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              'Assessment Submitted Successfully',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'upcoming') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Text(
          'Assessment will be available at the scheduled time',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Text(
        'Assessment Deadline Passed',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusDisplay(String status) {
    switch (status) {
      case 'completed':
        return {
          'text': 'Assessment Submitted',
          'color': Colors.green.shade800,
          'bgColor': Colors.green.shade50,
        };
      case 'missed':
        return {
          'text': 'Assessment Missed',
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade50,
        };
      case 'upcoming':
        return {
          'text': 'Upcoming',
          'color': Colors.orange.shade800,
          'bgColor': Colors.orange.shade50,
        };
      case 'active':
        return {
          'text': 'Active Now',
          'color': Colors.green.shade800,
          'bgColor': Colors.green.shade50,
        };
      default:
        return {
          'text': status,
          'color': AppTheme.textSecondary,
          'bgColor': AppTheme.backgroundLight,
        };
    }
  }

  Map<String, dynamic> _getTimeStatus(Assessment assessment) {
    final now = DateTime.now();
    if (now.isBefore(assessment.startTime)) {
      return {
        'text': 'Upcoming',
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50,
      };
    } else if (now.isAfter(assessment.endTime)) {
      return {
        'text': 'Ended',
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50,
      };
    } else {
      return {
        'text': 'Active',
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50,
      };
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      if (_answers.length <= _currentQuestion) {
        _answers = List.filled(_activeAssessment!.questions.length, -1);
      }
      _answers[_currentQuestion] = answerIndex;
    });
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  void _nextQuestion() {
    if (_currentQuestion < _activeAssessment!.questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }
}
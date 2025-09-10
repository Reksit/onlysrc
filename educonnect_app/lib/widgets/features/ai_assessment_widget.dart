import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';

class AIAssessmentWidget extends StatefulWidget {
  const AIAssessmentWidget({super.key});

  @override
  State<AIAssessmentWidget> createState() => _AIAssessmentWidgetState();
}

class _AIAssessmentWidgetState extends State<AIAssessmentWidget> {
  Assessment? _assessment;
  bool _loading = false;
  int _currentQuestion = 0;
  List<int> _answers = [];
  bool _isActive = false;
  int _timeLeft = 0;
  bool _showResults = false;
  Map<String, dynamic>? _results;

  String _selectedDomain = '';
  String _selectedDifficulty = '';
  int _numberOfQuestions = 5;

  final List<String> _domains = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography'
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  Widget build(BuildContext context) {
    if (_showResults && _results != null) {
      return _buildResultsView();
    }

    if (_assessment != null && _isActive) {
      return _buildAssessmentView();
    }

    return _buildConfigurationView();
  }

  Widget _buildConfigurationView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.blueGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Assessment Generator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Create personalized assessments to test your knowledge',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Configuration Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Configuration Options
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Domain',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedDomain.isEmpty ? null : _selectedDomain,
                            items: [
                              const DropdownMenuItem(value: '', child: Text('Select Domain')),
                              ..._domains.map((domain) => DropdownMenuItem(
                                value: domain,
                                child: Text(domain),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedDomain = value ?? '');
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Difficulty',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
                            items: [
                              const DropdownMenuItem(value: '', child: Text('Select Difficulty')),
                              ..._difficulties.map((difficulty) => DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedDifficulty = value ?? '');
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Number of Questions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _numberOfQuestions,
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5 Questions')),
                              DropdownMenuItem(value: 10, child: Text('10 Questions')),
                              DropdownMenuItem(value: 15, child: Text('15 Questions')),
                              DropdownMenuItem(value: 20, child: Text('20 Questions')),
                            ],
                            onChanged: (value) {
                              setState(() => _numberOfQuestions = value ?? 5);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _loading ? 'Generating Assessment...' : 'Generate Assessment',
                    onPressed: _loading ? null : _generateAssessment,
                    variant: ButtonVariant.primary,
                    isLoading: _loading,
                    icon: Icons.psychology,
                  ),
                ),
              ],
            ),
          ),
          
          // Generated Assessment Preview
          if (_assessment != null && !_isActive) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _assessment!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedDifficulty,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('${_assessment!.questions.length}', 'Questions'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('${_assessment!.duration} min', 'Duration'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('${_assessment!.totalMarks}', 'Total Marks'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Start Assessment',
                      onPressed: _startAssessment,
                      variant: ButtonVariant.primary,
                      icon: Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessmentView() {
    final currentQ = _assessment!.questions[_currentQuestion];
    
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
                    'Question ${_currentQuestion + 1} of ${_assessment!.questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _assessment!.questions.length,
                backgroundColor: AppTheme.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
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
                                  color: isSelected ? AppTheme.primaryPurple : AppTheme.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected ? AppTheme.primaryPurple.withOpacity(0.05) : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primaryPurple : AppTheme.borderMedium,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQ.options[index],
                                      style: TextStyle(
                                        color: isSelected ? AppTheme.primaryPurple : AppTheme.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                      text: _currentQuestion == _assessment!.questions.length - 1 
                          ? 'Submit Assessment' 
                          : 'Next',
                      onPressed: _currentQuestion == _assessment!.questions.length - 1 
                          ? _submitAssessment 
                          : _nextQuestion,
                      variant: _currentQuestion == _assessment!.questions.length - 1 
                          ? ButtonVariant.primary 
                          : ButtonVariant.primary,
                      icon: _currentQuestion == _assessment!.questions.length - 1 
                          ? Icons.check 
                          : Icons.arrow_forward,
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
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Your performance summary and detailed feedback',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  '${_results!['score']}',
                  'Correct Answers',
                  AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  '${_results!['totalMarks']}',
                  'Total Questions',
                  AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  '${_results!['percentage'].toStringAsFixed(1)}%',
                  'Success Rate',
                  AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Detailed Feedback
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detailed Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Feedback List
                ...(_results!['feedback'] as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final feedback = entry.value;
                  final isCorrect = feedback['isCorrect'] as bool;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feedback['question'],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Answer:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    feedback['selectedOption'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Correct Answer:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    feedback['correctOption'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Explanation:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feedback['explanation'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 24),
                
                // Take Another Assessment Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Take Another Assessment',
                    onPressed: () {
                      setState(() {
                        _assessment = null;
                        _showResults = false;
                        _results = null;
                        _currentQuestion = 0;
                        _answers = [];
                        _isActive = false;
                      });
                    },
                    variant: ButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateAssessment() async {
    if (_selectedDomain.isEmpty || _selectedDifficulty.isEmpty) {
      context.read<ToastProvider>().showError('Please select domain and difficulty');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await ApiService.generateAIAssessment({
        'domain': _selectedDomain,
        'difficulty': _selectedDifficulty,
        'numberOfQuestions': _numberOfQuestions,
      });

      setState(() {
        _assessment = Assessment.fromJson(response);
        _answers = List.filled(_assessment!.questions.length, -1);
        _currentQuestion = 0;
        _showResults = false;
        _results = null;
      });

      // Log activity
      await ApiService.logActivity('AI_ASSESSMENT', 'Generated AI assessment');
      
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Assessment generated successfully!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _startAssessment() {
    if (_assessment == null) return;
    
    setState(() {
      _isActive = true;
      _timeLeft = _assessment!.duration * 60; // Convert minutes to seconds
    });
    
    // Start timer
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

  void _selectAnswer(int answerIndex) {
    setState(() {
      if (_answers.length <= _currentQuestion) {
        _answers = List.filled(_assessment!.questions.length, -1);
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
    if (_currentQuestion < _assessment!.questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  Future<void> _submitAssessment() async {
    if (_assessment == null) return;

    setState(() => _isActive = false);
    
    // Calculate results
    int score = 0;
    final feedback = <Map<String, dynamic>>[];

    for (int i = 0; i < _answers.length; i++) {
      final question = _assessment!.questions[i];
      final answer = _answers[i];
      final isCorrect = answer == question.correctAnswer;
      if (isCorrect) score++;

      feedback.add({
        'questionIndex': i,
        'question': question.question,
        'selectedOption': answer >= 0 ? question.options[answer] : 'Not answered',
        'correctOption': question.options[question.correctAnswer],
        'explanation': question.explanation,
        'isCorrect': isCorrect,
      });
    }

    final percentage = (score / _assessment!.questions.length) * 100;

    setState(() {
      _results = {
        'score': score,
        'totalMarks': _assessment!.questions.length,
        'percentage': percentage,
        'feedback': feedback,
      };
      _showResults = true;
    });

    // Log activity
    await ApiService.logActivity('AI_ASSESSMENT', 'Completed AI assessment - Score: $score/${_assessment!.questions.length}');
    
    if (!mounted) return;
    context.read<ToastProvider>().showSuccess('Assessment completed! Score: $score/${_assessment!.questions.length}');
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
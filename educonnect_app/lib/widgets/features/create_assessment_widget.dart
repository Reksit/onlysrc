import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class CreateAssessmentWidget extends StatefulWidget {
  const CreateAssessmentWidget({super.key});

  @override
  State<CreateAssessmentWidget> createState() => _CreateAssessmentWidgetState();
}

class _CreateAssessmentWidgetState extends State<CreateAssessmentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _durationController = TextEditingController();

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _selectedStudents = [];
  String _studentSearch = '';
  List<Map<String, dynamic>> _studentSuggestions = [];
  bool _loading = false;
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _durationController.text = '60';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _searchStudents(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _studentSuggestions = [];
      });
      return;
    }

    setState(() => _searchLoading = true);

    try {
      final students = await ApiService.searchStudents(query);
      setState(() {
        _studentSuggestions = students;
      });
    } catch (error) {
      setState(() => _studentSuggestions = []);
    } finally {
      setState(() => _searchLoading = false);
    }
  }

  void _addStudent(Map<String, dynamic> student) {
    if (!_selectedStudents.any((s) => s['id'] == student['id'])) {
      setState(() {
        _selectedStudents.add(student);
      });
    }
    setState(() {
      _studentSearch = '';
      _studentSuggestions = [];
    });
  }

  void _removeStudent(String studentId) {
    setState(() {
      _selectedStudents.removeWhere((s) => s['id'] == studentId);
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': 0,
        'explanation': '',
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _createAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      context.read<ToastProvider>().showError('Please add at least one question');
      return;
    }

    if (_selectedStudents.isEmpty) {
      context.read<ToastProvider>().showError('Please assign at least one student');
      return;
    }

    // Validate questions
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q['question'].toString().trim().isEmpty) {
        context.read<ToastProvider>().showError('Question ${i + 1} is empty');
        return;
      }
      if ((q['options'] as List).any((opt) => opt.toString().trim().isEmpty)) {
        context.read<ToastProvider>().showError('Question ${i + 1} has empty options');
        return;
      }
      if (q['explanation'].toString().trim().isEmpty) {
        context.read<ToastProvider>().showError('Question ${i + 1} needs an explanation');
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final assessmentData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'duration': int.parse(_durationController.text),
        'assignedTo': _selectedStudents.map((s) => s['id']).toList(),
        'questions': _questions,
        'totalMarks': _questions.length,
      };

      await ApiService.createAssessment(assessmentData);

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Assessment created and scheduled successfully!');

      // Reset form
      _resetForm();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to create assessment');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _durationController.text = '60';
    setState(() {
      _questions = [];
      _selectedStudents = [];
      _studentSearch = '';
      _studentSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                    Icons.add,
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
                        'Create Assessment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Design and schedule new assessments',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_questions.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Assessment Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assessment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title and Description
                  CustomTextField(
                    controller: _titleController,
                    label: 'Assessment Title',
                    hintText: 'Enter assessment title...',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Assessment title is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Describe the assessment purpose and instructions...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _startTimeController,
                          label: 'Start Date & Time',
                          hintText: 'Select start date and time',
                          prefixIcon: const Icon(Icons.calendar_today),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Start time is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _endTimeController,
                          label: 'End Date & Time',
                          hintText: 'Select end date and time',
                          prefixIcon: const Icon(Icons.schedule),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'End time is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration
                  CustomTextField(
                    controller: _durationController,
                    label: 'Duration (minutes)',
                    hintText: 'Enter duration in minutes',
                    prefixIcon: const Icon(Icons.timer),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Duration is required';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid duration';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Student Assignment
                  const Text(
                    'Assign Students',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Selected Students
                  if (_selectedStudents.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedStudents.map((student) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              student['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeStudent(student['id']),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Student Search
                  TextField(
                    onChanged: _searchStudents,
                    decoration: InputDecoration(
                      hintText: 'Search students by name, email, or ID (e.g., 23cs1554)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                  // Student Suggestions
                  if (_studentSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _studentSuggestions.length,
                        itemBuilder: (context, index) {
                          final student = _studentSuggestions[index];
                          final isSelected = _selectedStudents.any((s) => s['id'] == student['id']);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                                student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              student['name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${student['email']} • ${student['className']} • ${student['department']}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: isSelected ? null : () => _addStudent(student),
                            enabled: !isSelected,
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Questions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assessment Questions (${_questions.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Question', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Questions List
                  if (_questions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.quiz, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No Questions Added Yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create engaging questions to assess your students\' understanding',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addQuestion,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Question'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return _buildQuestionCard(index, question);
                    }).toList(),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _loading ? 'Creating Assessment...' : 'Create Assessment',
                      onPressed: _loading || _questions.isEmpty ? null : _createAssessment,
                      variant: ButtonVariant.primary,
                      isLoading: _loading,
                      icon: Icons.save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppGradients.blueGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _removeQuestion(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Question Text
          TextField(
            onChanged: (value) => question['question'] = value,
            decoration: InputDecoration(
              labelText: 'Question Text',
              hintText: 'Enter your question here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Options
          const Text(
            'Answer Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          ...List.generate(4, (optionIndex) {
            final isCorrect = question['correctAnswer'] == optionIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green.shade300 : AppTheme.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: question['correctAnswer'],
                    onChanged: (value) {
                      setState(() {
                        question['correctAnswer'] = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  Text(
                    String.fromCharCode(65 + optionIndex),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => question['options'][optionIndex] = value,
                      decoration: InputDecoration(
                        hintText: 'Option ${String.fromCharCode(65 + optionIndex)} - Enter answer choice',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 6),
              Text(
                'Select the radio button next to the correct answer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Explanation
          TextField(
            onChanged: (value) => question['explanation'] = value,
            decoration: InputDecoration(
              labelText: 'Explanation',
              hintText: 'Explain why this is the correct answer and provide additional context...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
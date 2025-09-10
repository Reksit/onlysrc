import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class TaskManagementWidget extends StatefulWidget {
  const TaskManagementWidget({super.key});

  @override
  State<TaskManagementWidget> createState() => _TaskManagementWidgetState();
}

class _TaskManagementWidgetState extends State<TaskManagementWidget> {
  List<Task> _tasks = [];
  bool _loading = true;
  bool _showCreateForm = false;
  Set<String> _expandedTasks = {};
  String? _generatingRoadmap;

  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await ApiService.getUserTasks();
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      if (!error.toString().contains('404')) {
        context.read<ToastProvider>().showError('Failed to fetch tasks');
      }
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final taskData = {
        'taskName': _taskNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate': _dueDateController.text,
      };

      final newTask = await ApiService.createTask(taskData);
      setState(() {
        _tasks.insert(0, newTask);
        _showCreateForm = false;
      });

      _resetForm();
      
      // Log activity
      await ApiService.logActivity('TASK_MANAGEMENT', 'Created task: ${taskData['taskName']}');
      
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Task created successfully!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to create task');
    }
  }

  Future<void> _generateRoadmap(String taskId) async {
    try {
      setState(() => _generatingRoadmap = taskId);
      
      context.read<ToastProvider>().showInfo('Generating roadmap...');
      
      final updatedTask = await ApiService.generateRoadmap(taskId);
      setState(() {
        _tasks = _tasks.map((task) => task.id == taskId ? updatedTask : task).toList();
        _expandedTasks.add(taskId);
      });

      // Log activity
      await ApiService.logActivity('TASK_MANAGEMENT', 'Generated AI roadmap for task');
      
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Roadmap generated successfully!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to generate roadmap');
    } finally {
      setState(() => _generatingRoadmap = null);
    }
  }

  Future<void> _updateTaskStatus(String taskId, String status) async {
    try {
      final updatedTask = await ApiService.updateTaskStatus(taskId, status);
      setState(() {
        _tasks = _tasks.map((task) => task.id == taskId ? updatedTask : task).toList();
      });
      
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Task status updated!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to update task status');
    }
  }

  void _resetForm() {
    _taskNameController.clear();
    _descriptionController.clear();
    _dueDateController.clear();
  }

  void _toggleTaskExpansion(String taskId) {
    setState(() {
      if (_expandedTasks.contains(taskId)) {
        _expandedTasks.remove(taskId);
      } else {
        _expandedTasks.add(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading tasks...');
    }

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.task_alt, color: AppTheme.primaryBlue, size: 24),
                SizedBox(width: 12),
                Text(
                  'Task Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => setState(() => _showCreateForm = true),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Create Task Form
        if (_showCreateForm) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _taskNameController,
                    label: 'Task Name',
                    hintText: 'Enter task name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Task name is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Describe your task in detail',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _dueDateController,
                    label: 'Due Date',
                    hintText: 'Select due date',
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Due date is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Create Task',
                          onPressed: _createTask,
                          variant: ButtonVariant.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: () => setState(() => _showCreateForm = false),
                          variant: ButtonVariant.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Tasks List
        Expanded(
          child: _tasks.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.task_alt,
                  title: 'No Tasks Yet',
                  subtitle: 'Create your first task to get started with AI-powered roadmaps.',
                )
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return _buildTaskCard(task);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final isExpanded = _expandedTasks.contains(task.id);
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && task.status != 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Header
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
                                  task.taskName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.status.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isOverdue) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description,
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

                // Task Details
                Row(
                  children: [
                    _buildTaskDetail(Icons.calendar_today, 'Due: ${_formatDate(task.dueDate)}'),
                    const SizedBox(width: 16),
                    _buildTaskDetail(Icons.schedule, 'Created: ${_formatDate(task.createdAt)}'),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    if (!task.roadmapGenerated)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatingRoadmap == task.id ? null : () => _generateRoadmap(task.id),
                          icon: _generatingRoadmap == task.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.map, size: 16),
                          label: Text(
                            _generatingRoadmap == task.id ? 'Generating...' : 'Generate Roadmap',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    
                    if (task.roadmapGenerated) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleTaskExpansion(task.id),
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text('View Roadmap', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: task.status,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'PENDING', child: Text('Pending', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'COMPLETED', child: Text('Completed', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _updateTaskStatus(task.id, value);
                          }
                        },
                      ),
                    ),
                    
                    if (task.roadmapGenerated)
                      IconButton(
                        onPressed: () => _toggleTaskExpansion(task.id),
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Roadmap
          if (task.roadmapGenerated && isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderLight)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Generated Roadmap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...task.roadmap.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Create Task Form Dialog would be implemented here
  // Similar to the web version but adapted for mobile
}
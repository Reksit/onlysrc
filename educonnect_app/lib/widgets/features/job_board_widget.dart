import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class JobBoardWidget extends StatefulWidget {
  const JobBoardWidget({super.key});

  @override
  State<JobBoardWidget> createState() => _JobBoardWidgetState();
}

class _JobBoardWidgetState extends State<JobBoardWidget> {
  List<Job> _jobs = [];
  bool _loading = true;
  bool _showCreateForm = false;
  Job? _editingJob;
  String _searchTerm = '';
  String _selectedType = '';
  String _selectedLocation = '';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _applicationUrlController = TextEditingController();
  final _contactEmailController = TextEditingController();

  String _selectedJobType = 'FULL_TIME';
  List<String> _requirements = [''];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _applicationUrlController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await ApiService.getJobs();
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      if (!error.toString().contains('404')) {
        context.read<ToastProvider>().showError('Failed to load jobs');
      }
    }
  }

  List<Job> get _filteredJobs {
    return _jobs.where((job) {
      final matchesSearch = _searchTerm.isEmpty ||
          job.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          job.location.toLowerCase().contains(_searchTerm.toLowerCase());

      final matchesType = _selectedType.isEmpty ||
          job.type.toLowerCase().contains(_selectedType.toLowerCase());

      final matchesLocation = _selectedLocation.isEmpty ||
          job.location.toLowerCase().contains(_selectedLocation.toLowerCase());

      return matchesSearch && matchesType && matchesLocation;
    }).toList();
  }

  bool _canEditJob(Job job) {
    final user = context.read<AuthProvider>().user;
    return user?.role == 'ALUMNI' && user?.email == job.postedByEmail;
  }

  Future<void> _createOrUpdateJob() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final jobData = {
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _selectedJobType,
        'salary': _salaryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirements.where((req) => req.trim().isNotEmpty).toList(),
        'applicationUrl': _applicationUrlController.text.trim(),
        'contactEmail': _contactEmailController.text.trim(),
      };

      if (_editingJob != null) {
        await ApiService.updateJob(_editingJob!.id, jobData);
        context.read<ToastProvider>().showSuccess('Job updated successfully!');
      } else {
        await ApiService.createJob(jobData);
        context.read<ToastProvider>().showSuccess('Job posted successfully!');
      }

      _resetForm();
      _loadJobs();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    }
  }

  void _resetForm() {
    setState(() {
      _showCreateForm = false;
      _editingJob = null;
      _titleController.clear();
      _companyController.clear();
      _locationController.clear();
      _salaryController.clear();
      _descriptionController.clear();
      _applicationUrlController.clear();
      _contactEmailController.clear();
      _selectedJobType = 'FULL_TIME';
      _requirements = [''];
    });
  }

  void _editJob(Job job) {
    setState(() {
      _editingJob = job;
      _showCreateForm = true;
      _titleController.text = job.title;
      _companyController.text = job.company;
      _locationController.text = job.location;
      _selectedJobType = job.type;
      _salaryController.text = job.salary ?? '';
      _descriptionController.text = job.description;
      _applicationUrlController.text = job.applicationUrl ?? '';
      _contactEmailController.text = job.contactEmail ?? '';
      _requirements = job.requirements.isNotEmpty ? job.requirements : [''];
    });
  }

  Future<void> _deleteJob(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job posting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteJob(job.id);
        context.read<ToastProvider>().showSuccess('Job deleted successfully');
        _loadJobs();
      } catch (error) {
        if (!mounted) return;
        context.read<ToastProvider>().showError('Failed to delete job');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (_loading) {
      return const LoadingWidget(message: 'Loading job opportunities...');
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.orangeGradient,
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
                  Icons.work,
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
                      'Job Board',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Discover career opportunities and internships',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (user?.role == 'ALUMNI')
                IconButton(
                  onPressed: () => setState(() => _showCreateForm = true),
                  icon: const Icon(Icons.add, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search and Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) => setState(() => _searchTerm = value),
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 12),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType.isEmpty ? null : _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Job Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Types')),
                        DropdownMenuItem(value: 'full-time', child: Text('Full-time')),
                        DropdownMenuItem(value: 'part-time', child: Text('Part-time')),
                        DropdownMenuItem(value: 'contract', child: Text('Contract')),
                        DropdownMenuItem(value: 'internship', child: Text('Internship')),
                      ],
                      onChanged: (value) => setState(() => _selectedType = value ?? ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLocation.isEmpty ? null : _selectedLocation,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Locations')),
                        DropdownMenuItem(value: 'remote', child: Text('Remote')),
                        DropdownMenuItem(value: 'on-site', child: Text('On-site')),
                        DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                      ],
                      onChanged: (value) => setState(() => _selectedLocation = value ?? ''),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchTerm = '';
                        _selectedType = '';
                        _selectedLocation = '';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Jobs List
        Expanded(
          child: _filteredJobs.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.work,
                  title: 'No Jobs Found',
                  subtitle: _jobs.isEmpty 
                      ? 'Be the first to share an exciting career opportunity!'
                      : 'Try adjusting your search criteria',
                  action: user?.role == 'ALUMNI'
                      ? CustomButton(
                          text: 'Post Job',
                          onPressed: () => setState(() => _showCreateForm = true),
                          variant: ButtonVariant.primary,
                          icon: Icons.add,
                        )
                      : null,
                )
              : ListView.builder(
                  itemCount: _filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = _filteredJobs[index];
                    return _buildJobCard(job);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJobCard(Job job) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = _canEditJob(job);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getJobTypeColor(job.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatJobType(job.type),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editJob(job),
                      icon: const Icon(Icons.edit, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteJob(job),
                      icon: const Icon(Icons.delete, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Job Details
          Row(
            children: [
              _buildJobDetail(Icons.location_on, job.location),
              const SizedBox(width: 16),
              _buildJobDetail(Icons.schedule, _formatDate(job.postedAt)),
              if (job.salary != null) ...[
                const SizedBox(width: 16),
                _buildJobDetail(Icons.attach_money, job.salary!),
              ],
            ],
          ),

          const SizedBox(height: 8),

          _buildJobDetail(Icons.person, 'Posted by ${job.postedByName}'),

          const SizedBox(height: 12),

          // Description
          Text(
            job.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (job.requirements.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.requirements.take(3).map((req) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )).toList(),
            ),
            if (job.requirements.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${job.requirements.length - 3} more requirements',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (job.applicationUrl != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openUrl(job.applicationUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply', style: TextStyle(fontSize: 12)),
                  ),
                ),
              if (job.applicationUrl != null && job.contactEmail != null)
                const SizedBox(width: 8),
              if (job.contactEmail != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sendEmail(job.contactEmail!, job.title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.backgroundLight,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: const Text('Contact', style: TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String text) {
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

  Color _getJobTypeColor(String type) {
    switch (type) {
      case 'FULL_TIME':
        return Colors.green;
      case 'INTERNSHIP':
        return Colors.blue;
      case 'PART_TIME':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _formatJobType(String type) {
    return type.replaceAll('_', '-').toLowerCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openUrl(String url) {
    // In a real app, you would use url_launcher package
    context.read<ToastProvider>().showInfo('Opening $url');
  }

  void _sendEmail(String email, String jobTitle) {
    // In a real app, you would use url_launcher to open email client
    context.read<ToastProvider>().showInfo('Opening email to $email');
  }

  // Create Job Form would be implemented as a separate dialog/bottom sheet
  // Similar to the web version but adapted for mobile UI
}
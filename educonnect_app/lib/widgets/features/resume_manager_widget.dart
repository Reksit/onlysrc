import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';

class ResumeManagerWidget extends StatefulWidget {
  const ResumeManagerWidget({super.key});

  @override
  State<ResumeManagerWidget> createState() => _ResumeManagerWidgetState();
}

class _ResumeManagerWidgetState extends State<ResumeManagerWidget> {
  List<Map<String, dynamic>> _resumes = [];
  Map<String, dynamic>? _currentResume;
  bool _loading = true;
  bool _uploading = false;
  String _activeTab = 'manage';
  Map<String, dynamic>? _selectedResumeForATS;
  bool _atsAnalyzing = false;
  bool _showATSResults = false;

  @override
  void initState() {
    super.initState();
    _loadResumes();
    _loadCurrentResume();
  }

  Future<void> _loadResumes() async {
    try {
      final resumes = await ApiService.getMyResumes();
      setState(() {
        _resumes = resumes;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load resumes');
    }
  }

  Future<void> _loadCurrentResume() async {
    try {
      final currentResume = await ApiService.getCurrentResume();
      setState(() => _currentResume = currentResume);
    } catch (error) {
      // No current resume is fine
    }
  }

  Future<void> _uploadResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Validate file size (10MB limit)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (!mounted) return;
          context.read<ToastProvider>().showError('File size must be less than 10MB');
          return;
        }

        setState(() => _uploading = true);

        await ApiService.uploadResume(file);
        
        if (!mounted) return;
        context.read<ToastProvider>().showSuccess('Resume uploaded successfully!');
        
        _loadResumes();
        _loadCurrentResume();
      }
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to upload resume');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _activateResume(String resumeId) async {
    try {
      await ApiService.activateResume(resumeId);
      context.read<ToastProvider>().showSuccess('Resume activated successfully!');
      _loadResumes();
      _loadCurrentResume();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to activate resume');
    }
  }

  Future<void> _deleteResume(String resumeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text('Are you sure you want to delete this resume?'),
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
        await ApiService.deleteResume(resumeId);
        context.read<ToastProvider>().showSuccess('Resume deleted successfully!');
        _loadResumes();
        _loadCurrentResume();
      } catch (error) {
        if (!mounted) return;
        context.read<ToastProvider>().showError('Failed to delete resume');
      }
    }
  }

  Future<void> _analyzeResumeWithATS(Map<String, dynamic> resume) async {
    setState(() {
      _selectedResumeForATS = resume;
      _atsAnalyzing = true;
    });

    try {
      final updatedResume = await ApiService.analyzeResumeATS(resume['id']);
      setState(() {
        _selectedResumeForATS = updatedResume;
        _showATSResults = true;
      });
      
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('ATS analysis completed!');
      _loadResumes();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to analyze resume');
    } finally {
      setState(() => _atsAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading resumes...');
    }

    return Column(
      children: [
        // Header with Tabs
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
                children: [
                  const Icon(Icons.description, color: AppTheme.primaryOrange, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Resume Manager',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_activeTab == 'manage')
                    IconButton(
                      onPressed: _uploading ? null : _uploadResume,
                      icon: _uploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Tab Navigation
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'manage'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 'manage' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Manage Resumes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _activeTab == 'manage' ? AppTheme.primaryOrange : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'ats'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 'ats' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.psychology, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'ATS Score Checker',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _activeTab == 'ats' ? AppTheme.primaryOrange : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: _activeTab == 'manage' ? _buildManageTab() : _buildATSTab(),
        ),
      ],
    );
  }

  Widget _buildManageTab() {
    return Column(
      children: [
        // Current Resume
        if (_currentResume != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_currentResume!['atsScore'] != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getATSScoreBg(_currentResume!['atsScore']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ATS: ${_currentResume!['atsScore']}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getATSScoreColor(_currentResume!['atsScore']),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.description, color: AppTheme.primaryOrange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentResume!['fileName'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Uploaded ${_formatDate(_currentResume!['uploadedAt'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_currentResume!['fileSize'] != null)
                            Text(
                              _formatFileSize(_currentResume!['fileSize']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _downloadResume(_currentResume!['id'], _currentResume!['fileName']),
                      icon: const Icon(Icons.download),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        foregroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // All Resumes
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Resumes (${_resumes.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _resumes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 64, color: AppTheme.textMuted),
                              SizedBox(height: 16),
                              Text(
                                'No Resumes Uploaded',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Upload your first resume to get started!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _resumes.length,
                          itemBuilder: (context, index) {
                            final resume = _resumes[index];
                            return _buildResumeCard(resume);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildATSTab() {
    return Column(
      children: [
        // ATS Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.indigo.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.blue, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-Powered ATS Score Checker',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Get detailed feedback on your resume\'s ATS compatibility',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildATSFeature(Icons.check_circle, 'Comprehensive Analysis'),
                  _buildATSFeature(Icons.psychology, 'AI-Powered Recommendations'),
                  _buildATSFeature(Icons.send, 'Send to Management'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Resume Selection for ATS
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Resume for ATS Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _resumes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 64, color: AppTheme.textMuted),
                              SizedBox(height: 16),
                              Text(
                                'No Resumes Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Upload a resume first to analyze its ATS score.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _resumes.length,
                          itemBuilder: (context, index) {
                            final resume = _resumes[index];
                            final isSelected = _selectedResumeForATS?['id'] == resume['id'];
                            
                            return GestureDetector(
                              onTap: () => setState(() => _selectedResumeForATS = resume),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : AppTheme.borderLight,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.description, color: AppTheme.primaryOrange, size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      resume['fileName'],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppTheme.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (resume['isActive'] == true)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text(
                                                        'Active',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    _formatDate(resume['uploadedAt']),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                  if (resume['atsScore'] != null) ...[
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'ATS: ${resume['atsScore']}%',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: _getATSScoreColor(resume['atsScore']),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (resume['atsAnalysis'] != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Last analyzed: ${_formatDate(resume['atsAnalysis']['analyzedAt'])}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            if (resume['atsAnalysis']['sentToManagement'] == true)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Sent to Management',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.green,
                                                  ),
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
                          },
                        ),
                ),

                if (_selectedResumeForATS != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: _atsAnalyzing ? 'Analyzing...' : 'Analyze with AI',
                          onPressed: _atsAnalyzing ? null : () => _analyzeResumeWithATS(_selectedResumeForATS!),
                          variant: ButtonVariant.primary,
                          isLoading: _atsAnalyzing,
                          icon: Icons.psychology,
                        ),
                      ),
                      if (_selectedResumeForATS!['atsAnalysis'] != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'View Results',
                            onPressed: () => setState(() => _showATSResults = true),
                            variant: ButtonVariant.outline,
                            icon: Icons.visibility,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(Map<String, dynamic> resume) {
    final isActive = resume['isActive'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.green.shade200 : AppTheme.borderLight,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isActive ? Colors.green.shade50 : Colors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: AppTheme.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resume['fileName'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Uploaded ${_formatDate(resume['uploadedAt'])}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (resume['fileSize'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatFileSize(resume['fileSize']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.green),
                      SizedBox(width: 2),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (resume['atsScore'] != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getATSScoreBg(resume['atsScore']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ATS: ${resume['atsScore']}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getATSScoreColor(resume['atsScore']),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              if (!isActive)
                IconButton(
                  onPressed: () => _activateResume(resume['id']),
                  icon: const Icon(Icons.star_border, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                ),
              IconButton(
                onPressed: () => _deleteResume(resume['id']),
                icon: const Icon(Icons.delete, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildATSFeature(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Color _getATSScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getATSScoreBg(int score) {
    if (score >= 80) return Colors.green.shade100;
    if (score >= 60) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _downloadResume(String resumeId, String fileName) {
    // In a real app, you would implement file download
    context.read<ToastProvider>().showInfo('Downloading $fileName');
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class AlumniProfileWidget extends StatefulWidget {
  const AlumniProfileWidget({super.key});

  @override
  State<AlumniProfileWidget> createState() => _AlumniProfileWidgetState();
}

class _AlumniProfileWidgetState extends State<AlumniProfileWidget> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;

  final _currentJobController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  List<String> _skills = [];
  List<String> _achievements = [];
  final _skillController = TextEditingController();
  final _achievementController = TextEditingController();
  bool _isAvailableForMentorship = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _currentJobController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _skillController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getAlumniProfile();
      setState(() {
        _profile = profile;
        _currentJobController.text = profile['currentJob'] ?? '';
        _companyController.text = profile['company'] ?? '';
        _locationController.text = profile['location'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _experienceController.text = profile['experience'] ?? '';
        _linkedinController.text = profile['linkedinUrl'] ?? '';
        _githubController.text = profile['githubUrl'] ?? '';
        _portfolioController.text = profile['portfolioUrl'] ?? '';
        _skills = List<String>.from(profile['skills'] ?? []);
        _achievements = List<String>.from(profile['achievements'] ?? []);
        _isAvailableForMentorship = profile['isAvailableForMentorship'] ?? false;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load profile');
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    try {
      final profileData = {
        'currentJob': _currentJobController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'skills': _skills,
        'linkedinUrl': _linkedinController.text.trim(),
        'githubUrl': _githubController.text.trim(),
        'portfolioUrl': _portfolioController.text.trim(),
        'experience': _experienceController.text.trim(),
        'achievements': _achievements,
        'isAvailableForMentorship': _isAvailableForMentorship,
      };

      await ApiService.updateAlumniProfile(profileData);
      await _loadProfile();

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Profile updated successfully!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to update profile');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _addAchievement() {
    final achievement = _achievementController.text.trim();
    if (achievement.isNotEmpty && !_achievements.contains(achievement)) {
      setState(() {
        _achievements.add(achievement);
        _achievementController.clear();
      });
    }
  }

  void _removeAchievement(String achievement) {
    setState(() => _achievements.remove(achievement));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading profile...');
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primaryOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'My Alumni Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: _saving ? 'Saving...' : 'Save Profile',
                onPressed: _saving ? null : _saveProfile,
                variant: ButtonVariant.primary,
                isLoading: _saving,
                icon: Icons.save,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Basic Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Read-only fields
                _buildReadOnlyField('Name', _profile?['name'] ?? ''),
                const SizedBox(height: 12),
                _buildReadOnlyField('Email', _profile?['email'] ?? ''),
                const SizedBox(height: 12),
                _buildReadOnlyField('Department', _profile?['department'] ?? ''),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Professional Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Professional Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _currentJobController,
                  label: 'Current Job Title',
                  hintText: 'e.g., Software Engineer',
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _companyController,
                  label: 'Company',
                  hintText: 'e.g., Google, Microsoft',
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'e.g., Chennai, India',
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _experienceController,
                  label: 'Experience',
                  hintText: 'e.g., 3 years',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bio
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Me',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _bioController,
                  label: '',
                  hintText: 'Tell us about yourself, your interests, and what you\'re passionate about...',
                  maxLines: 4,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Skills
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillController,
                        decoration: InputDecoration(
                          hintText: 'Add a skill',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                
                  children: _skills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeSkill(skill),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Social Links
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Social Links',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn URL',
                  hintText: 'https://linkedin.com/in/yourprofile',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.link, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _githubController,
                  label: 'GitHub URL',
                  hintText: 'https://github.com/yourusername',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.code, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _portfolioController,
                  label: 'Portfolio URL',
                  hintText: 'https://yourportfolio.com',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.web, color: AppTheme.primaryPurple),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Achievements
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _achievementController,
                        decoration: InputDecoration(
                          hintText: 'Add an achievement',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => _addAchievement(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addAchievement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                ..._achievements.map((achievement) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeAchievement(achievement),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mentorship
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mentorship',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Checkbox(
                      value: _isAvailableForMentorship,
                      onChanged: (value) => setState(() => _isAvailableForMentorship = value ?? false),
                      activeColor: AppTheme.primaryOrange,
                    ),
                    const Expanded(
                      child: Text(
                        'I\'m available to mentor students and junior alumni',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
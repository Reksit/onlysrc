import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import 'activity_heatmap_widget.dart';

class StudentProfileWidget extends StatefulWidget {
  const StudentProfileWidget({super.key});

  @override
  State<StudentProfileWidget> createState() => _StudentProfileWidgetState();
}

class _StudentProfileWidgetState extends State<StudentProfileWidget> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _isEditing = false;
  bool _saving = false;

  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _locationController = TextEditingController();

  List<String> _skills = [];
  final _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _locationController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getMyProfile();
      setState(() {
        _profile = profile;
        _bioController.text = profile['bio'] ?? '';
        _phoneController.text = profile['phone'] ?? profile['phoneNumber'] ?? '';
        _linkedinController.text = profile['linkedinUrl'] ?? '';
        _githubController.text = profile['githubUrl'] ?? '';
        _portfolioController.text = profile['portfolioUrl'] ?? '';
        _locationController.text = profile['location'] ?? '';
        _skills = List<String>.from(profile['skills'] ?? []);
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      
      // Set basic profile with user data if API fails
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        setState(() {
          _profile = {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'department': user.department ?? '',
            'className': user.className ?? '',
            'bio': '',
            'skills': <String>[],
            'location': '',
            'phone': user.phoneNumber ?? '',
            'linkedinUrl': '',
            'githubUrl': '',
            'portfolioUrl': '',
          };
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    setState(() => _saving = true);

    try {
      final updateData = {
        'bio': _bioController.text.trim(),
        'skills': _skills,
        'location': _locationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'linkedinUrl': _linkedinController.text.trim(),
        'githubUrl': _githubController.text.trim(),
        'portfolioUrl': _portfolioController.text.trim(),
      };

      await ApiService.updateMyProfile(updateData);
      await _loadProfile();

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Profile updated successfully!');
      setState(() => _isEditing = false);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading profile...');
    }

    if (_profile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text(
              'Profile Not Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Unable to load your profile information.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              CustomButton(
                text: _isEditing ? (_saving ? 'Saving...' : 'Save') : 'Edit Profile',
                onPressed: _saving ? null : (_isEditing ? _saveProfile : () => setState(() => _isEditing = true)),
                variant: ButtonVariant.primary,
                isLoading: _saving,
                icon: _isEditing ? Icons.save : Icons.edit,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        _profile!['name']?.substring(0, 1).toUpperCase() ?? 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile!['name'] ?? 'Student',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Text(
                            'Student',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Class ${_profile!['className'] ?? 'N/A'}',
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

                const SizedBox(height: 20),

                // Basic Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.business, 'Department', _profile!['department'] ?? ''),
                      _buildInfoRow(Icons.email, 'Email', _profile!['email'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bio Section
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
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isEditing)
                  CustomTextField(
                    controller: _bioController,
                    label: '',
                    hintText: 'Tell us about yourself...',
                    maxLines: 4,
                  )
                else
                  Text(
                    _profile!['bio']?.isNotEmpty == true ? _profile!['bio'] : 'No bio added yet.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Information
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
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isEditing) ...[
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hintText: 'Phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    hintText: 'Your location',
                  ),
                ] else ...[
                  _buildContactRow(Icons.phone, 'Phone', _profile!['phone'] ?? _profile!['phoneNumber'] ?? 'Not provided'),
                  _buildContactRow(Icons.location_on, 'Location', _profile!['location'] ?? 'Not provided'),
                ],
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
                const SizedBox(height: 12),
                if (_isEditing) ...[
                  CustomTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn URL',
                    hintText: 'https://linkedin.com/in/username',
                    keyboardType: TextInputType.url,
                    prefixIcon: const Icon(Icons.link, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _githubController,
                    label: 'GitHub URL',
                    hintText: 'https://github.com/username',
                    keyboardType: TextInputType.url,
                    prefixIcon: const Icon(Icons.code, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _portfolioController,
                    label: 'Portfolio URL',
                    hintText: 'https://yourportfolio.com',
                    keyboardType: TextInputType.url,
                    prefixIcon: const Icon(Icons.web, color: AppTheme.primaryPurple),
                  ),
                ] else ...[
                  _buildSocialLinkRow(Icons.link, 'LinkedIn', _profile!['linkedinUrl']),
                  _buildSocialLinkRow(Icons.code, 'GitHub', _profile!['githubUrl']),
                  _buildSocialLinkRow(Icons.web, 'Portfolio', _profile!['portfolioUrl']),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Skills Section
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
                const SizedBox(height: 12),
                
                if (_isEditing) ...[
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
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeSkill(skill),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Activity Heatmap Section
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
                  'My Activity Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: ActivityHeatmapWidget(
                    userId: _profile!['id'],
                    userName: _profile!['name'],
                    showTitle: false,
                  ),
                ),
              ],
            ),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _loadProfile(); // Reset changes
                    },
                    variant: ButtonVariant.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _saving ? 'Saving...' : 'Save Changes',
                    onPressed: _saving ? null : _saveProfile,
                    variant: ButtonVariant.primary,
                    isLoading: _saving,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkRow(IconData icon, String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: url?.isNotEmpty == true
                ? GestureDetector(
                    onTap: () => _openUrl(url!),
                    child: Text(
                      url!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : const Text(
                    'Not provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) {
    // In a real app, you would use url_launcher package
    context.read<ToastProvider>().showInfo('Opening $url');
  }
}
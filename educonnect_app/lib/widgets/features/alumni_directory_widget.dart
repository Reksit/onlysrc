import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';

class AlumniDirectoryWidget extends StatefulWidget {
  const AlumniDirectoryWidget({super.key});

  @override
  State<AlumniDirectoryWidget> createState() => _AlumniDirectoryWidgetState();
}

class _AlumniDirectoryWidgetState extends State<AlumniDirectoryWidget> {
  List<AlumniProfile> _alumni = [];
  List<AlumniProfile> _filteredAlumni = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedDepartment = '';
  String _selectedYear = '';
  AlumniProfile? _selectedAlumni;

  @override
  void initState() {
    super.initState();
    _loadAlumniDirectory();
  }

  Future<void> _loadAlumniDirectory() async {
    try {
      final alumni = await ApiService.getAllVerifiedAlumni();
      setState(() {
        _alumni = alumni;
        _filteredAlumni = alumni;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load alumni directory');
    }
  }

  void _filterAlumni() {
    setState(() {
      _filteredAlumni = _alumni.where((alumni) {
        bool matchesSearch = _searchQuery.isEmpty ||
            alumni.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            alumni.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (alumni.currentCompany?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        bool matchesDepartment = _selectedDepartment.isEmpty ||
            alumni.department == _selectedDepartment;

        bool matchesYear = _selectedYear.isEmpty ||
            alumni.graduationYear == _selectedYear;

        return matchesSearch && matchesDepartment && matchesYear;
      }).toList();
    });
  }

  List<String> get _departments {
    return _alumni.map((a) => a.department).toSet().toList()..sort();
  }

  List<String> get _graduationYears {
    return _alumni
        .map((a) => a.graduationYear)
        .where((year) => year != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading Alumni Network...');
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.purpleGradient,
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
                  Icons.school,
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
                      'Alumni Network',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Connect with alumni and expand your professional network',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_alumni.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                onChanged: (value) {
                  _searchQuery = value;
                  _filterAlumni();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, company, position...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.borderLight),
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
                      value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All Departments')),
                        ..._departments.map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept, style: const TextStyle(fontSize: 12)),
                        )),
                      ],
                      onChanged: (value) {
                        _selectedDepartment = value ?? '';
                        _filterAlumni();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear.isEmpty ? null : _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Graduation Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All Years')),
                        ..._graduationYears.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        )),
                      ],
                      onChanged: (value) {
                        _selectedYear = value ?? '';
                        _filterAlumni();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Results count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_filteredAlumni.length} of ${_alumni.length} alumni',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty || _selectedDepartment.isNotEmpty || _selectedYear.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedDepartment = '';
                          _selectedYear = '';
                        });
                        _filterAlumni();
                      },
                      child: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Alumni Grid
        Expanded(
          child: _filteredAlumni.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.people,
                  title: 'No alumni found',
                  subtitle: 'Try adjusting your search criteria or filters.',
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _filteredAlumni.length,
                  itemBuilder: (context, index) {
                    final alumni = _filteredAlumni[index];
                    return _buildAlumniCard(alumni);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlumniCard(AlumniProfile alumni) {
    return GestureDetector(
      onTap: () => _showAlumniProfile(alumni),
      child: Container(
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
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryPurple,
                  child: Text(
                    alumni.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumni.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        alumni.currentPosition ?? 'Alumni',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (alumni.isAvailableForMentorship == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mentor',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Column(
              children: [
                _buildDetailRow(Icons.business, alumni.currentCompany ?? 'Not specified'),
                const SizedBox(height: 4),
                _buildDetailRow(Icons.location_on, alumni.location ?? 'Not specified'),
                const SizedBox(height: 4),
                _buildDetailRow(Icons.calendar_today, '${alumni.department} • Class of ${alumni.graduationYear}'),
              ],
            ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAlumniProfile(alumni),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Profile', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _connectWithAlumni(alumni),
                  icon: const Icon(Icons.connect_without_contact, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAlumniProfile(AlumniProfile alumni) {
    showDialog(
      context: context,
      builder: (context) => _buildAlumniProfileDialog(alumni),
    );
  }

  Widget _buildAlumniProfileDialog(AlumniProfile alumni) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.purpleGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      alumni.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alumni.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          alumni.currentPosition ?? 'Alumni',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          alumni.currentCompany ?? 'Company not specified',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Information
                      _buildProfileSection(
                        'Contact Information',
                        [
                          _buildProfileDetailRow(Icons.email, 'Email', alumni.email),
                          if (alumni.phoneNumber != null)
                            _buildProfileDetailRow(Icons.phone, 'Phone', alumni.phoneNumber!),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Education
                      _buildProfileSection(
                        'Education',
                        [
                          _buildProfileDetailRow(Icons.school, 'Department', alumni.department),
                          _buildProfileDetailRow(Icons.calendar_today, 'Graduation Year', alumni.graduationYear ?? 'N/A'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Professional
                      _buildProfileSection(
                        'Professional',
                        [
                          _buildProfileDetailRow(Icons.work, 'Position', alumni.currentPosition ?? 'Not specified'),
                          _buildProfileDetailRow(Icons.business, 'Company', alumni.currentCompany ?? 'Not specified'),
                          _buildProfileDetailRow(Icons.location_on, 'Location', alumni.location ?? 'Not specified'),
                        ],
                      ),

                      if (alumni.skills != null && alumni.skills!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSkillsSection(alumni.skills!),
                      ],

                      if (alumni.bio != null && alumni.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildProfileSection(
                          'About',
                          [
                            Text(
                              alumni.bio!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderLight)),
              ),
              child: Row(
                children: [
                  if (alumni.linkedinUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(alumni.linkedinUrl!),
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('LinkedIn', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (alumni.linkedinUrl != null && alumni.githubUrl != null)
                    const SizedBox(width: 12),
                  if (alumni.githubUrl != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(alumni.githubUrl!),
                        icon: const Icon(Icons.code, size: 16),
                        label: const Text('GitHub', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _connectWithAlumni(alumni),
                      icon: const Icon(Icons.connect_without_contact, size: 16),
                      label: const Text('Connect', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildSkillsSection(List<String> skills) {
    return Column(
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills.take(6).map((skill) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              skill,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        ),
        if (skills.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${skills.length - 6} more skills',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  void _connectWithAlumni(AlumniProfile alumni) async {
    try {
      await ApiService.sendConnectionRequest(
        alumni.id,
        'Hi ${alumni.name}, I would like to connect with you for mentoring and career guidance. Thank you!',
      );
      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Connection request sent to ${alumni.name}!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to send connection request');
    }
  }

  void _openUrl(String url) {
    // In a real app, you would use url_launcher package
    context.read<ToastProvider>().showInfo('Opening $url');
  }
}
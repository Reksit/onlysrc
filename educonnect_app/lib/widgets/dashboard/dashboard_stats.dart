import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';

class DashboardStats extends StatefulWidget {
  const DashboardStats({super.key});

  @override
  State<DashboardStats> createState() => _DashboardStatsState();
}

class _DashboardStatsState extends State<DashboardStats> {
  Map<String, int> _stats = {
    'aiAssessments': 0,
    'classTests': 0,
    'activeTasks': 0,
    'alumniConnections': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Load various stats from different APIs
      final futures = await Future.wait([
        ApiService.getUserTasks().catchError((_) => []),
        ApiService.getStudentAssessments().catchError((_) => []),
        ApiService.getMyProfile().catchError((_) => {}),
      ]);

      final tasks = futures[0] as List;
      final assessments = futures[1] as List;
      final profile = futures[2] as Map<String, dynamic>;

      setState(() {
        _stats = {
          'aiAssessments': profile['aiAssessmentCount'] ?? 0,
          'classTests': assessments.where((a) => a['type'] == 'CLASS_ASSESSMENT' || a['type'] == 'CLASS_TEST').length,
          'activeTasks': tasks.where((t) => t['status'] == 'IN_PROGRESS' || t['status'] == 'PENDING').length,
          'alumniConnections': profile['connectionCount'] ?? 0,
        };
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load dashboard stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (_loading) {
      return const LoadingWidget(message: 'Loading dashboard...');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.purpleGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user?.name ?? "Student"}! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to continue your learning journey? Check out your progress and upcoming tasks below.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'AI Assessments Taken',
                '${_stats['aiAssessments']}',
                Icons.psychology,
                AppTheme.primaryPurple,
              ),
              _buildStatCard(
                'Class Tests',
                '${_stats['classTests']}',
                Icons.assignment,
                AppTheme.primaryBlue,
              ),
              _buildStatCard(
                'Pending Tasks',
                '${_stats['activeTasks']}',
                Icons.task_alt,
                AppTheme.primaryOrange,
              ),
              _buildStatCard(
                'Alumni Connections',
                '${_stats['alumniConnections']}',
                Icons.school,
                AppTheme.primaryGreen,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
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
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildQuickActionCard(
                      'Take AI Assessment',
                      Icons.psychology,
                      AppTheme.primaryPurple,
                      () => _navigateToTab('ai-assessment'),
                    ),
                    _buildQuickActionCard(
                      'View Tasks',
                      Icons.task_alt,
                      AppTheme.primaryOrange,
                      () => _navigateToTab('task-management'),
                    ),
                    _buildQuickActionCard(
                      'Update Resume',
                      Icons.description,
                      AppTheme.primaryBlue,
                      () => _navigateToTab('resume'),
                    ),
                    _buildQuickActionCard(
                      'View Events',
                      Icons.event,
                      AppTheme.primaryGreen,
                      () => _navigateToTab('events'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Career Hub Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.purpleGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Career Hub',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Advance your career with our professional tools',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCareerHubCard(
                        'Job Board',
                        'Find opportunities',
                        'Discover internships, full-time positions, and freelance opportunities tailored to your skills and interests.',
                        Icons.work,
                        AppGradients.orangeGradient,
                        () => _navigateToTab('job-board'),
                      ),
                      const SizedBox(height: 16),
                      _buildCareerHubCard(
                        'Alumni Network',
                        'Connect & grow',
                        'Network with successful alumni, get mentorship, and gain valuable industry insights for your career growth.',
                        Icons.school,
                        AppGradients.purpleGradient,
                        () => _navigateToTab('alumni-directory'),
                      ),
                      const SizedBox(height: 16),
                      _buildCareerHubCard(
                        'Resume Manager',
                        'Build your profile',
                        'Create and maintain a professional resume with AI-powered suggestions and industry-standard templates.',
                        Icons.description,
                        AppGradients.orangeGradient,
                        () => _navigateToTab('resume'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerHubCard(
    String title,
    String subtitle,
    String description,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient.colors.first.withOpacity(0.1) != null
              ? LinearGradient(
                  colors: [
                    gradient.colors.first.withOpacity(0.1),
                    gradient.colors.last.withOpacity(0.05),
                  ],
                )
              : gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gradient.colors.first.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: gradient.colors.first,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: gradient.colors.first,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(String tabId) {
    // This would be handled by the parent dashboard to switch tabs
    context.read<ToastProvider>().showInfo('Navigating to $tabId');
  }
}
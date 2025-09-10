import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/features/my_assessments_widget.dart';
import '../../widgets/features/create_assessment_widget.dart';
import '../../widgets/features/attendance_management_widget.dart';
import '../../widgets/features/assessment_insights_widget.dart';
import '../../widgets/features/student_heatmap_widget.dart';
import '../../widgets/features/events_widget.dart';
import '../../widgets/features/chat_widget.dart';
import '../../widgets/features/issue_circular_widget.dart';
import '../../widgets/features/circulars_widget.dart';
import '../../widgets/features/sent_circulars_widget.dart';
import '../../widgets/features/password_change_widget.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  int _selectedIndex = 0;

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      id: 'home',
      title: 'Home',
      icon: Icons.home,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'assessments',
      title: 'My Assessments',
      icon: Icons.assignment,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'create-assessment',
      title: 'Create Assessment',
      icon: Icons.add_circle,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'attendance',
      title: 'Attendance',
      icon: Icons.people,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'insights',
      title: 'Insights',
      icon: Icons.analytics,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'student-activity',
      title: 'Student Activity',
      icon: Icons.trending_up,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'events',
      title: 'Events',
      icon: Icons.event,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'chat',
      title: 'Chat',
      icon: Icons.chat,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'issue-circular',
      title: 'Issue Circular',
      icon: Icons.send,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'view-circulars',
      title: 'View Circulars',
      icon: Icons.mail,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'sent-circulars',
      title: 'Sent Circulars',
      icon: Icons.send,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'settings',
      title: 'Settings',
      icon: Icons.settings,
      color: AppTheme.primaryOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.8),
                  AppTheme.primaryGreen,
                ],
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'EduBoard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = _dashboardItems[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selectedIndex = index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const Spacer(),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'P',
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
                              user?.name ?? 'Professor',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
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
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name?.split(' ').first ?? 'Professor'}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            DateTime.now().toString().split(' ')[0],
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Notification Bell
                      IconButton(
                        onPressed: () {
                          context.read<ToastProvider>().showInfo('No new notifications');
                        },
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      const SizedBox(width: 8),
                      // Profile Avatar
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen,
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundLight,
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final selectedItem = _dashboardItems[_selectedIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _getContentWidget(selectedItem.id),
    );
  }

  Widget _getContentWidget(String id) {
    switch (id) {
      case 'home':
        return _buildHomeContent();
      case 'assessments':
        return const MyAssessmentsWidget();
      case 'create-assessment':
        return const CreateAssessmentWidget();
      case 'attendance':
        return const AttendanceManagementWidget();
      case 'insights':
        return const AssessmentInsightsWidget();
      case 'student-activity':
        return const StudentHeatmapWidget();
      case 'events':
        return const EventsWidget();
      case 'chat':
        return const ChatWidget();
      case 'issue-circular':
        return const IssueCircularWidget();
      case 'view-circulars':
        return const CircularsWidget();
      case 'sent-circulars':
        return const SentCircularsWidget();
      case 'settings':
        return const PasswordChangeWidget();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final user = context.watch<AuthProvider>().user;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name?.split(' ').first ?? 'Professor'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ready to manage your classes today?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _selectedIndex = 2), // Create Assessment
                        icon: const Icon(Icons.add),
                        label: const Text('Quick Create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Current status at a glance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Upcoming',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'My Assessments',
                  'View and manage assessments',
                  Icons.assignment,
                  AppTheme.primaryBlue,
                  () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Attendance',
                  'Track student attendance',
                  Icons.people,
                  AppTheme.primaryOrange,
                  () => setState(() => _selectedIndex = 3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Create Assessment',
                  'Build new tests & quizzes',
                  Icons.add_circle,
                  AppTheme.primaryGreen,
                  () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
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
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContentWidget(String id) {
    switch (id) {
      case 'home':
        return _buildHomeContent();
      case 'assessments':
        return const MyAssessmentsWidget();
      case 'create-assessment':
        return const CreateAssessmentWidget();
      case 'attendance':
        return const AttendanceManagementWidget();
      case 'insights':
        return const AssessmentInsightsWidget();
      case 'student-activity':
        return const StudentHeatmapWidget();
      case 'events':
        return const EventsWidget();
      case 'chat':
        return const ChatWidget();
      case 'issue-circular':
        return const IssueCircularWidget();
      case 'view-circulars':
        return const CircularsWidget();
      case 'sent-circulars':
        return const SentCircularsWidget();
      case 'settings':
        return const PasswordChangeWidget();
      default:
        return _buildHomeContent();
    }
  }
}

class DashboardItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  DashboardItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}
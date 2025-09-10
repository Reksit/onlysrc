import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/dashboard/dashboard_stats.dart';
import '../../widgets/features/ai_assessment_widget.dart';
import '../../widgets/features/class_assessments_widget.dart';
import '../../widgets/features/task_management_widget.dart';
import '../../widgets/features/alumni_directory_widget.dart';
import '../../widgets/features/job_board_widget.dart';
import '../../widgets/features/events_widget.dart';
import '../../widgets/features/chat_widget.dart';
import '../../widgets/features/resume_manager_widget.dart';
import '../../widgets/features/attendance_widget.dart';
import '../../widgets/features/activity_heatmap_widget.dart';
import '../../widgets/features/circulars_widget.dart';
import '../../widgets/features/student_profile_widget.dart';
import '../../widgets/features/password_change_widget.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  bool _showAIChat = false;

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.home,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'ai-assessment',
      title: 'AI Assessment',
      icon: Icons.psychology,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'class-assessments',
      title: 'Class Tests',
      icon: Icons.assignment,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'task-management',
      title: 'Tasks',
      icon: Icons.task_alt,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'activity',
      title: 'Performance',
      icon: Icons.bar_chart,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'attendance',
      title: 'Attendance',
      icon: Icons.calendar_today,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'resume',
      title: 'Resume Manager',
      icon: Icons.description,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'job-board',
      title: 'Job Board',
      icon: Icons.work,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'alumni-directory',
      title: 'Alumni Network',
      icon: Icons.school,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'events',
      title: 'Events',
      icon: Icons.event,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'chat',
      title: 'Messages',
      icon: Icons.chat,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'circulars',
      title: 'Circulars',
      icon: Icons.mail,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'profile',
      title: 'Profile',
      icon: Icons.person,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'settings',
      title: 'Settings',
      icon: Icons.settings,
      color: AppTheme.primaryBlue,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Career Coaches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
                                color: isSelected ? const Color(0xFFF3F4F6) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? const Border(right: BorderSide(color: AppTheme.primaryPurple, width: 4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected ? item.color : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 14,
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
                
                // Logout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.read<AuthProvider>().logout(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            'Hello, ${user?.name?.split(' ').first ?? 'Student'}!',
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
                        backgroundColor: AppTheme.primaryPurple,
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'S',
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
      
      // Floating AI Chat Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAIChat = !_showAIChat),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      
      // AI Chat Modal
      body: _showAIChat
          ? Stack(
              children: [
                // Main content
                Row(
                  children: [
                    Container(width: 280), // Sidebar space
                    Expanded(child: _buildContent()),
                  ],
                ),
                // AI Chat Overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat, color: AppTheme.primaryPurple),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'AI Assistant',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => setState(() => _showAIChat = false),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: ChatWidget(isAIChat: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
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
      case 'dashboard':
        return const DashboardStats();
      case 'ai-assessment':
        return const AIAssessmentWidget();
      case 'class-assessments':
        return const ClassAssessmentsWidget();
      case 'task-management':
        return const TaskManagementWidget();
      case 'activity':
        return const ActivityHeatmapWidget();
      case 'attendance':
        return const AttendanceWidget();
      case 'resume':
        return const ResumeManagerWidget();
      case 'job-board':
        return const JobBoardWidget();
      case 'alumni-directory':
        return const AlumniDirectoryWidget();
      case 'events':
        return const EventsWidget();
      case 'chat':
        return const ChatWidget();
      case 'circulars':
        return const CircularsWidget();
      case 'profile':
        return const StudentProfileWidget();
      case 'settings':
        return const PasswordChangeWidget();
      default:
        return const DashboardStats();
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
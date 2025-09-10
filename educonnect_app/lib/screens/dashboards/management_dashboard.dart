import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/features/dashboard_stats_widget.dart';
import '../../widgets/features/alumni_verification_widget.dart';
import '../../widgets/features/event_management_widget.dart';
import '../../widgets/features/student_heatmap_widget.dart';
import '../../widgets/features/alumni_event_invitation_widget.dart';
import '../../widgets/features/management_event_request_tracker_widget.dart';
import '../../widgets/features/ai_student_analysis_widget.dart';
import '../../widgets/features/password_change_widget.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _selectedIndex = 0;

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'alumni-verification',
      title: 'Alumni Verification',
      icon: Icons.verified_user,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'event-management',
      title: 'Event Management',
      icon: Icons.event_note,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'student-analysis',
      title: 'Student Analysis',
      icon: Icons.analytics,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'invite-alumni',
      title: 'Invite Alumni',
      icon: Icons.send,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'event-requests',
      title: 'Event Requests',
      icon: Icons.request_page,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'ai-analysis',
      title: 'AI Student Analysis',
      icon: Icons.psychology,
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
                  AppTheme.primaryPurple.withOpacity(0.9),
                  AppTheme.primaryPurple,
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
                          Icons.admin_panel_settings,
                          color: AppTheme.primaryPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Management',
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
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected ? AppTheme.primaryPurple : Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: isSelected ? AppTheme.primaryPurple : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryPurple,
                                        shape: BoxShape.circle,
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
                
                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'M',
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
                              user?.name ?? 'Management',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Management',
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
                            'Management Portal',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'System Overview & Administration',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // System Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'System Online',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
      case 'dashboard':
        return const DashboardStatsWidget();
      case 'alumni-verification':
        return const AlumniVerificationWidget();
      case 'event-management':
        return const EventManagementWidget();
      case 'student-analysis':
        return const StudentHeatmapWidget();
      case 'invite-alumni':
        return const AlumniEventInvitationWidget();
      case 'event-requests':
        return const ManagementEventRequestTrackerWidget();
      case 'ai-analysis':
        return const AIStudentAnalysisWidget();
      case 'settings':
        return const PasswordChangeWidget();
      default:
        return const DashboardStatsWidget();
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
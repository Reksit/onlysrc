import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/features/alumni_profile_widget.dart';
import '../../widgets/features/alumni_directory_widget.dart';
import '../../widgets/features/connection_requests_widget.dart';
import '../../widgets/features/job_board_widget.dart';
import '../../widgets/features/events_widget.dart';
import '../../widgets/features/alumni_event_request_widget.dart';
import '../../widgets/features/alumni_management_requests_widget.dart';
import '../../widgets/features/chat_widget.dart';
import '../../widgets/features/password_change_widget.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  int _selectedIndex = 0;
  String _activeProfileTab = 'profile';

  final List<DashboardItem> _mainTabs = [
    DashboardItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: AppTheme.primaryPurple,
    ),
    DashboardItem(
      id: 'profile',
      title: 'Profile',
      icon: Icons.person,
      color: AppTheme.primaryBlue,
    ),
    DashboardItem(
      id: 'directory',
      title: 'Alumni Directory',
      icon: Icons.people,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'connections',
      title: 'Connections',
      icon: Icons.connect_without_contact,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'chat',
      title: 'Messages',
      icon: Icons.chat,
      color: AppTheme.primaryBlue,
    ),
  ];

  final List<DashboardItem> _professionalTabs = [
    DashboardItem(
      id: 'jobs',
      title: 'Job Board',
      icon: Icons.work,
      color: AppTheme.primaryOrange,
    ),
    DashboardItem(
      id: 'events',
      title: 'Events',
      icon: Icons.event,
      color: AppTheme.primaryGreen,
    ),
    DashboardItem(
      id: 'request-event',
      title: 'Request Event',
      icon: Icons.add_circle,
      color: AppTheme.primaryPurple,
    ),
  ];

  final List<DashboardItem> _managementTabs = [
    DashboardItem(
      id: 'alumni-management-requests',
      title: 'Alumni Requests',
      icon: Icons.school,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.8),
                  AppTheme.primaryPurple,
                ],
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
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
                          Icons.favorite,
                          color: AppTheme.primaryPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Alumni Network',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Section
                        _buildSectionHeader('Main'),
                        ..._mainTabs.map((item) => _buildNavItem(item)),
                        
                        const SizedBox(height: 24),
                        
                        // Professional Section
                        _buildSectionHeader('Professional'),
                        ..._professionalTabs.map((item) => _buildNavItem(item)),
                        
                        const SizedBox(height: 24),
                        
                        // Management Section
                        _buildSectionHeader('Management'),
                        ..._managementTabs.map((item) => _buildNavItem(item)),
                      ],
                    ),
                  ),
                ),
                
                // User Profile
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'A',
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
                              user?.name ?? 'Alumni',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Alumni',
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
                      const Spacer(),
                      Row(
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
                            'Active Status',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(DashboardItem item) {
    final isSelected = _getSelectedId() == item.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectItem(item.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppTheme.primaryPurple : Colors.white70,
                  size: 16,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSelectedId() {
    final allItems = [..._mainTabs, ..._professionalTabs, ..._managementTabs];
    return allItems[_selectedIndex].id;
  }

  void _selectItem(String id) {
    final allItems = [..._mainTabs, ..._professionalTabs, ..._managementTabs];
    final index = allItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildContent() {
    final selectedId = _getSelectedId();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _getContentWidget(selectedId),
    );
  }

  Widget _getContentWidget(String id) {
    switch (id) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'profile':
        return _buildProfileContent();
      case 'directory':
        return const AlumniDirectoryWidget();
      case 'connections':
        return const ConnectionRequestsWidget();
      case 'jobs':
        return const JobBoardWidget();
      case 'events':
        return const EventsWidget();
      case 'request-event':
        return const AlumniEventRequestWidget();
      case 'alumni-management-requests':
        return const AlumniManagementRequestsWidget();
      case 'chat':
        return const ChatWidget();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    final user = context.watch<AuthProvider>().user;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // University Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppTheme.primaryPurple.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppGradients.purpleGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.name ?? "Alumni"} Dashboard',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Computer Science Alumni • Class of 2020 • Professional Network',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard('0', 'Network Connections', AppTheme.primaryPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('0', 'Events Attended', AppTheme.primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('0', 'Opportunities Shared', AppTheme.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        // Profile Navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple.withOpacity(0.1), AppTheme.primaryPurple.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildProfileTabButton('profile', 'My Profile'),
              const SizedBox(width: 16),
              _buildProfileTabButton('security', 'Security Settings'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Profile Content
        Expanded(
          child: _activeProfileTab == 'profile'
              ? const AlumniProfileWidget()
              : const PasswordChangeWidget(),
        ),
      ],
    );
  }

  Widget _buildProfileTabButton(String tabId, String title) {
    final isActive = _activeProfileTab == tabId;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeProfileTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? AppTheme.primaryPurple : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
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
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
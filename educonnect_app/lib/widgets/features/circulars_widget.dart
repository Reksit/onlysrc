import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';

class CircularsWidget extends StatefulWidget {
  const CircularsWidget({super.key});

  @override
  State<CircularsWidget> createState() => _CircularsWidgetState();
}

class _CircularsWidgetState extends State<CircularsWidget> {
  List<Circular> _circulars = [];
  bool _loading = true;
  Circular? _selectedCircular;
  String _filter = 'all';
  String _searchTerm = '';
  String _senderFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCirculars();
  }

  Future<void> _loadCirculars() async {
    try {
      final circulars = await ApiService.getMyReceivedCirculars();
      setState(() {
        _circulars = circulars;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load circulars');
    }
  }

  Future<void> _markAsRead(Circular circular) async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null || circular.readBy.contains(userId)) return;

    try {
      await ApiService.markCircularAsRead(circular.id);
      setState(() {
        final index = _circulars.indexWhere((c) => c.id == circular.id);
        if (index != -1) {
          _circulars[index] = Circular(
            id: circular.id,
            title: circular.title,
            body: circular.body,
            senderId: circular.senderId,
            senderName: circular.senderName,
            senderRole: circular.senderRole,
            recipientTypes: circular.recipientTypes,
            createdAt: circular.createdAt,
            status: circular.status,
            readBy: [...circular.readBy, userId],
          );
        }
      });
    } catch (error) {
      // Silently fail for read status
    }
  }

  List<Circular> get _filteredCirculars {
    final userId = context.read<AuthProvider>().user?.id ?? '';
    
    return _circulars.where((circular) {
      // Filter by read status
      final isRead = circular.readBy.contains(userId);
      if (_filter == 'read' && !isRead) return false;
      if (_filter == 'unread' && isRead) return false;

      // Filter by sender role
      if (_senderFilter != 'all' && circular.senderRole != _senderFilter.toUpperCase()) return false;

      // Filter by search term
      if (_searchTerm.isNotEmpty) {
        final searchLower = _searchTerm.toLowerCase();
        return circular.title.toLowerCase().contains(searchLower) ||
               circular.body.toLowerCase().contains(searchLower) ||
               circular.senderName.toLowerCase().contains(searchLower);
      }

      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get _unreadCount {
    final userId = context.read<AuthProvider>().user?.id ?? '';
    return _circulars.where((c) => !c.readBy.contains(userId)).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading circulars...');
    }

    if (_selectedCircular != null) {
      return _buildCircularDetailView();
    }

    return Column(
      children: [
        // Header
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mail,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Circulars',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _unreadCount > 0
                              ? '$_unreadCount unread circular${_unreadCount > 1 ? 's' : ''}'
                              : 'All circulars read',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_unreadCount New',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Search and Filters
              TextField(
                onChanged: (value) => setState(() => _searchTerm = value),
                decoration: InputDecoration(
                  hintText: 'Search circulars...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _filter = _filter == 'unread' ? 'all' : 'unread'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filter == 'unread' ? AppTheme.primaryPurple : AppTheme.backgroundLight,
                        foregroundColor: _filter == 'unread' ? Colors.white : AppTheme.textSecondary,
                      ),
                      child: Text('Unread ($_unreadCount)', style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _senderFilter,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Senders', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'management', child: Text('Management', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'professor', child: Text('Professor', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (value) => setState(() => _senderFilter = value ?? 'all'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Circulars List
        Expanded(
          child: _filteredCirculars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mail, size: 64, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        _searchTerm.isNotEmpty || _filter != 'all' || _senderFilter != 'all'
                            ? 'No circulars match your filters'
                            : 'No circulars received yet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (_searchTerm.isNotEmpty || _filter != 'all' || _senderFilter != 'all')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchTerm = '';
                              _filter = 'all';
                              _senderFilter = 'all';
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCirculars.length,
                  itemBuilder: (context, index) {
                    final circular = _filteredCirculars[index];
                    return _buildCircularCard(circular);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCircularCard(Circular circular) {
    final userId = context.read<AuthProvider>().user?.id ?? '';
    final isUnread = !circular.readBy.contains(userId);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCircular = circular);
        _markAsRead(circular);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppTheme.primaryPurple.withOpacity(0.3) : AppTheme.borderLight,
          ),
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
            // Circular Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getSenderRoleColor(circular.senderRole),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getSenderRoleIcon(circular.senderRole),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circular.senderName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        circular.senderRole.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(circular.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              circular.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            // Preview
            Text(
              circular.body.length > 150 
                  ? '${circular.body.substring(0, 150)}...'
                  : circular.body,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Status
            Row(
              children: [
                Icon(
                  isUnread ? Icons.mail : Icons.mark_email_read,
                  size: 14,
                  color: isUnread ? AppTheme.primaryPurple : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isUnread ? 'Unread' : 'Read',
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnread ? AppTheme.primaryPurple : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.visibility, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularDetailView() {
    final circular = _selectedCircular!;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Circular Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'From ${circular.senderName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedCircular = null),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getSenderRoleColor(circular.senderRole),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _getSenderRoleIcon(circular.senderRole),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    circular.senderName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    circular.senderRole.toLowerCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDate(circular.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          circular.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Circular Body
                  Text(
                    circular.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _selectedCircular = null),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Circulars'),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Icon(Icons.mark_email_read, size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Marked as read',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
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
        ),
      ],
    );
  }

  Color _getSenderRoleColor(String role) {
    switch (role) {
      case 'MANAGEMENT':
        return AppTheme.primaryPurple.withOpacity(0.1);
      case 'PROFESSOR':
        return AppTheme.primaryGreen.withOpacity(0.1);
      case 'STUDENT':
        return AppTheme.primaryBlue.withOpacity(0.1);
      default:
        return AppTheme.backgroundLight;
    }
  }

  String _getSenderRoleIcon(String role) {
    switch (role) {
      case 'MANAGEMENT':
        return '👔';
      case 'PROFESSOR':
        return '👨‍🏫';
      case 'STUDENT':
        return '👨‍🎓';
      default:
        return '👤';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
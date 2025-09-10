import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';

class ChatWidget extends StatefulWidget {
  final bool isAIChat;
  
  const ChatWidget({super.key, this.isAIChat = false});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _allUsers = [];
  Map<String, dynamic>? _selectedUser;
  final _messageController = TextEditingController();
  bool _loading = false;
  bool _showUserList = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAIChat) {
      _initializeAIChat();
    } else {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _initializeAIChat() {
    setState(() {
      _messages = [
        ChatMessage(
          id: '1',
          senderId: 'ai',
          senderName: 'AI Assistant',
          receiverId: _getCurrentUserId(),
          receiverName: 'You',
          message: "Hello! I'm your AI assistant. I'm here to help you with your studies, answer questions, and provide guidance. How can I assist you today?",
          timestamp: DateTime.now(),
          read: true,
        ),
      ];
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final futures = await Future.wait([
        ApiService.getConversations(),
        ApiService.getAllUsers(),
      ]);

      setState(() {
        _conversations = futures[0] as List<Map<String, dynamic>>;
        _allUsers = futures[1] as List<Map<String, dynamic>>;
      });
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load chat data');
    }
  }

  Future<void> _selectUser(Map<String, dynamic> user) async {
    setState(() {
      _selectedUser = user;
      _showUserList = false;
    });

    if (widget.isAIChat) return;

    try {
      final chatHistory = await ApiService.getChatHistory(user['id']);
      setState(() => _messages = chatHistory);

      await ApiService.markMessagesAsRead(user['id']);
      _loadInitialData(); // Refresh conversations
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load chat history');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _loading) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() => _loading = true);

    try {
      if (widget.isAIChat) {
        // Add user message immediately
        final userMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: _getCurrentUserId(),
          senderName: 'You',
          receiverId: 'ai',
          receiverName: 'AI Assistant',
          message: messageText,
          timestamp: DateTime.now(),
          read: true,
        );

        setState(() => _messages.add(userMessage));

        // Send to AI
        final response = await ApiService.sendAIMessage(messageText);
        
        final aiMessage = ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          senderId: 'ai',
          senderName: 'AI Assistant',
          receiverId: _getCurrentUserId(),
          receiverName: 'You',
          message: response['response'],
          timestamp: DateTime.now(),
          read: true,
        );

        setState(() => _messages.add(aiMessage));

        // Log activity
        await ApiService.logActivity('AI_CHAT', 'Chatted with AI assistant');
      } else {
        if (_selectedUser == null) return;

        final response = await ApiService.sendMessage({
          'receiverId': _selectedUser!['id'],
          'message': messageText,
        });

        setState(() => _messages.add(response));
        _loadInitialData(); // Refresh conversations

        // Log activity
        final activityType = _selectedUser!['role'] == 'ALUMNI' ? 'ALUMNI_CHAT' : 'PROFESSOR_CHAT';
        await ApiService.logActivity(activityType, 'Sent message to ${_selectedUser!['name']}');
      }

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Message sent successfully!');
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to send message');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _getCurrentUserId() {
    return context.read<AuthProvider>().user?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAIChat) {
      return _buildAIChatInterface();
    }

    return _buildUserChatInterface();
  }

  Widget _buildAIChatInterface() {
    return Column(
      children: [
        // AI Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.blueGradient,
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
                  Icons.psychology,
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
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Always here to help you learn and grow',
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

        // Messages
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.senderId == _getCurrentUserId();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isCurrentUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryBlue,
                          child: const Icon(Icons.psychology, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? AppTheme.primaryGreen : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCurrentUser ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isCurrentUser ? Colors.white70 : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryGreen,
                          child: const Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loading ? null : _sendMessage,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserChatInterface() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showUserList = !_showUserList),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Row(
            children: [
              // Conversations List
              Container(
                width: 200,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundLight,
                  border: Border(right: BorderSide(color: AppTheme.borderLight)),
                ),
                child: Column(
                  children: [
                    if (_showUserList) ...[
                      // User List
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          'Start New Chat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _allUsers.length,
                          itemBuilder: (context, index) {
                            final user = _allUsers[index];
                            if (user['id'] == _getCurrentUserId()) return const SizedBox.shrink();
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue,
                                child: Text(
                                  user['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              title: Text(
                                user['name'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${user['role']} • ${user['department']}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              onTap: () => _selectUser(user),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      // Conversations List
                      if (_conversations.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat, size: 48, color: AppTheme.textMuted),
                                SizedBox(height: 12),
                                Text(
                                  'No conversations yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Start a new chat to begin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = _conversations[index];
                              final user = conversation['user'];
                              final isSelected = _selectedUser?['id'] == user['id'];
                              
                              return Container(
                                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryBlue,
                                    child: Text(
                                      user['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  title: Text(
                                    user['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    conversation['lastMessage']?['message'] ?? 'No messages',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: conversation['unreadCount'] > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${conversation['unreadCount']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () => _selectUser(user),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Chat Area
              Expanded(
                child: _selectedUser == null && !widget.isAIChat
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 64, color: AppTheme.textMuted),
                            SizedBox(height: 16),
                            Text(
                              'Select a Conversation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              'Choose a conversation from the sidebar or start a new chat.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Chat Header
                          if (_selectedUser != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryGradient,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text(
                                      _selectedUser!['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedUser!['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${_selectedUser!['role']} • ${_selectedUser!['department']}',
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

                          // Messages
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: _messages.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No messages yet. Start the conversation!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _messages[index];
                                        final isCurrentUser = message.senderId == _getCurrentUserId();
                                        
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            mainAxisAlignment: isCurrentUser 
                                                ? MainAxisAlignment.end 
                                                : MainAxisAlignment.start,
                                            children: [
                                              if (!isCurrentUser) ...[
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: widget.isAIChat ? AppTheme.primaryBlue : AppTheme.primaryGreen,
                                                  child: Icon(
                                                    widget.isAIChat ? Icons.psychology : Icons.person,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: isCurrentUser 
                                                        ? AppTheme.primaryGreen 
                                                        : AppTheme.backgroundLight,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        message.message,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: isCurrentUser ? Colors.white : AppTheme.textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _formatTime(message.timestamp),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isCurrentUser ? Colors.white70 : AppTheme.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isCurrentUser) ...[
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: AppTheme.primaryGreen,
                                                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // Message Input
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: AppTheme.borderLight)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Type your message...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _loading ? null : _sendMessage,
                                  icon: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
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
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
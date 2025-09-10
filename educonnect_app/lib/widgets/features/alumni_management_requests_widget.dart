import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';

class AlumniManagementRequestsWidget extends StatefulWidget {
  const AlumniManagementRequestsWidget({super.key});

  @override
  State<AlumniManagementRequestsWidget> createState() => _AlumniManagementRequestsWidgetState();
}

class _AlumniManagementRequestsWidgetState extends State<AlumniManagementRequestsWidget> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _selectedRequest;
  String _responseMessage = '';
  String _rejectReason = '';
  bool _showResponseModal = false;
  String _actionType = 'accept';

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      // This would be implemented in the API service
      // final requests = await ApiService.getPendingManagementRequests();
      setState(() {
        _requests = []; // Placeholder
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load management requests');
    }
  }

  Future<void> _handleAction(String requestId, String action) async {
    setState(() {
      _selectedRequest = requestId;
      _actionType = action;
      _showResponseModal = true;
      _responseMessage = '';
      _rejectReason = '';
    });
  }

  Future<void> _submitResponse() async {
    if (_selectedRequest == null) return;

    try {
      if (_actionType == 'accept') {
        if (_responseMessage.trim().isEmpty) {
          context.read<ToastProvider>().showError('Please provide a response message');
          return;
        }
        // await ApiService.acceptManagementEventRequest(_selectedRequest!, _responseMessage);
        context.read<ToastProvider>().showSuccess('Event request accepted successfully!');
      } else {
        if (_rejectReason.trim().isEmpty) {
          context.read<ToastProvider>().showError('Please provide a reason for rejection');
          return;
        }
        // await ApiService.rejectManagementEventRequest(_selectedRequest!, _rejectReason);
        context.read<ToastProvider>().showSuccess('Event request rejected successfully!');
      }

      _loadPendingRequests();
      setState(() {
        _showResponseModal = false;
        _selectedRequest = null;
      });
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to respond to request');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading management requests...');
    }

    return Stack(
      children: [
        Column(
          children: [
            // Header
            const Row(
              children: [
                Icon(Icons.message, color: AppTheme.primaryOrange, size: 24),
                SizedBox(width: 12),
                Text(
                  'Management Event Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Requests List
            Expanded(
              child: _requests.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: AppTheme.textMuted),
                          SizedBox(height: 16),
                          Text(
                            'No Pending Requests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'No alumni event requests are currently pending approval.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return _buildRequestCard(request);
                      },
                    ),
            ),
          ],
        ),

        // Response Modal
        if (_showResponseModal)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _actionType == 'accept' ? 'Accept Event Request' : 'Reject Event Request',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      onChanged: (value) {
                        if (_actionType == 'accept') {
                          _responseMessage = value;
                        } else {
                          _rejectReason = value;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: _actionType == 'accept' ? 'Response Message' : 'Reason for Rejection',
                        hintText: _actionType == 'accept' 
                            ? 'Enter your response message...'
                            : 'Enter rejection reason...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _showResponseModal = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitResponse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _actionType == 'accept' ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_actionType == 'accept' ? 'Accept Request' : 'Reject Request'),
                          ),
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Request Header
          Text(
            request['title'] ?? 'Event Request',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Request Details
          Text(
            request['description'] ?? 'No description available',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAction(request['id'], 'accept'),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Accept', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAction(request['id'], 'reject'),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
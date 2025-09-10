import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';
import '../common/loading_widget.dart';

class EventsWidget extends StatefulWidget {
  const EventsWidget({super.key});

  @override
  State<EventsWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  List<Event> _events = [];
  bool _loading = true;
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await ApiService.getApprovedEvents();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      if (!error.toString().contains('404')) {
        context.read<ToastProvider>().showError('Failed to load events');
      }
    }
  }

  Future<void> _updateAttendance(Event event) async {
    try {
      final isAttending = event.attendees.contains(_getCurrentUserId());
      await ApiService.updateAttendance(event.id, !isAttending);
      
      context.read<ToastProvider>().showSuccess(
        isAttending ? 'Attendance cancelled successfully!' : 'Attendance confirmed successfully!',
      );
      
      _loadEvents();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to update attendance');
    }
  }

  String _getCurrentUserId() {
    // Get current user ID from storage or auth provider
    return context.read<AuthProvider>().user?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading events...');
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
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
                  Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Discover and join upcoming events',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_events.length}',
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

        // Events List
        Expanded(
          child: _events.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.event,
                  title: 'No Events Available',
                  subtitle: 'No events are currently scheduled. Check back later for updates!',
                )
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _buildEventCard(event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    final isAttending = event.attendees.contains(_getCurrentUserId());
    final isUpcoming = event.startDateTime.isAfter(DateTime.now());
    final isInProgress = DateTime.now().isAfter(event.startDateTime) &&
        (event.endDateTime == null || DateTime.now().isBefore(event.endDateTime!));

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
          // Event Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(event.type),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.type,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getEventStatusColor(isUpcoming, isInProgress),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getEventStatusText(isUpcoming, isInProgress),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organized by ${event.organizerName}',
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

          const SizedBox(height: 12),

          // Event Details
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Event Info
          Column(
            children: [
              _buildEventDetailRow(Icons.calendar_today, _formatDateTime(event.startDateTime)),
              const SizedBox(height: 4),
              _buildEventDetailRow(Icons.location_on, event.location),
              const SizedBox(height: 4),
              _buildEventDetailRow(Icons.people, '${event.attendees.length} attending${event.maxAttendees != null ? ' / ${event.maxAttendees} max' : ''}'),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showEventDetails(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backgroundLight,
                    foregroundColor: AppTheme.textPrimary,
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              if (isUpcoming)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateAttendance(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending ? Colors.green : AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      isAttending ? 'Attending' : 'Join Event',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
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
          ),
        ),
      ],
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'workshop':
        return Colors.blue;
      case 'seminar':
        return Colors.green;
      case 'networking':
        return Colors.purple;
      case 'career':
        return Colors.orange;
      case 'social':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getEventStatusColor(bool isUpcoming, bool isInProgress) {
    if (isInProgress) return Colors.green;
    if (isUpcoming) return Colors.blue;
    return Colors.grey;
  }

  String _getEventStatusText(bool isUpcoming, bool isInProgress) {
    if (isInProgress) return 'In Progress';
    if (isUpcoming) return 'Upcoming';
    return 'Completed';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => _buildEventDetailsDialog(event),
    );
  }

  Widget _buildEventDetailsDialog(Event event) {
    final isAttending = event.attendees.contains(_getCurrentUserId());
    final isUpcoming = event.startDateTime.isAfter(DateTime.now());

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Organized by ${event.organizerName}',
                          style: const TextStyle(
                            color: Colors.white70,
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
                      // Event Details
                      _buildDetailSection('Event Details', [
                        _buildDetailItem(Icons.calendar_today, 'Date', _formatDateTime(event.startDateTime)),
                        _buildDetailItem(Icons.location_on, 'Location', event.location),
                        _buildDetailItem(Icons.people, 'Attendees', '${event.attendees.length}${event.maxAttendees != null ? ' / ${event.maxAttendees}' : ''}'),
                        if (event.isVirtual && event.meetingLink != null)
                          _buildDetailItem(Icons.video_call, 'Meeting Link', 'Available for attendees'),
                      ]),

                      const SizedBox(height: 16),

                      // Description
                      _buildDetailSection('About This Event', [
                        Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            if (isUpcoming)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.borderLight)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _updateAttendance(event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending ? Colors.green : AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAttending ? Icons.check : Icons.people,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAttending ? 'You\'re Attending - Click to Cancel' : 'Join This Event',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class AlumniEventRequestWidget extends StatefulWidget {
  const AlumniEventRequestWidget({super.key});

  @override
  State<AlumniEventRequestWidget> createState() => _AlumniEventRequestWidgetState();
}

class _AlumniEventRequestWidgetState extends State<AlumniEventRequestWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startDateTimeController = TextEditingController();
  final _endDateTimeController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _specialRequirementsController = TextEditingController();

  String _selectedEventType = '';
  String _selectedTargetAudience = '';
  bool _loading = false;

  final List<String> _eventTypes = [
    'Workshop',
    'Seminar',
    'Networking',
    'Reunion',
    'Career Fair',
    'Industry Talk',
    'Panel Discussion',
    'Alumni Meet',
    'Other'
  ];

  final List<String> _targetAudiences = [
    'All Students',
    'Final Year Students',
    'Alumni Only',
    'Faculty & Students',
    'Department Specific'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    _maxAttendeesController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEventType.isEmpty) {
      context.read<ToastProvider>().showError('Please select an event type');
      return;
    }

    setState(() => _loading = true);

    try {
      final requestData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'startDateTime': _startDateTimeController.text,
        'endDateTime': _endDateTimeController.text,
        'maxAttendees': int.tryParse(_maxAttendeesController.text) ?? 0,
        'specialRequirements': _specialRequirementsController.text.trim(),
        'targetAudience': _selectedTargetAudience.isNotEmpty ? _selectedTargetAudience : 'All Students',
        'eventType': _selectedEventType,
        'contactEmail': '',
        'contactPhone': '',
      };

      await ApiService.submitAlumniEventRequest(requestData);

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Event request submitted successfully! Management will review your request.');

      // Reset form
      _resetForm();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to submit event request');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _startDateTimeController.clear();
    _endDateTimeController.clear();
    _maxAttendeesController.clear();
    _specialRequirementsController.clear();
    setState(() {
      _selectedEventType = '';
      _selectedTargetAudience = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.blueGradient,
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Event from Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Submit a request to organize an event that will benefit students and the academic community',
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

          const SizedBox(height: 20),

          // Request Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Event Title',
                    hintText: 'Enter a descriptive title for your event',
                    prefixIcon: const Icon(Icons.title),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Event title is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Event Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedEventType.isEmpty ? null : _selectedEventType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Select event type')),
                          ..._eventTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedEventType = value ?? ''),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Event Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Event Description',
                    hintText: 'Describe the event, its objectives, and how it will benefit the community',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Event description is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _startDateTimeController,
                          label: 'Start Date & Time',
                          hintText: 'Select start date and time',
                          prefixIcon: const Icon(Icons.calendar_today),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Start date & time is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _endDateTimeController,
                          label: 'End Date & Time',
                          hintText: 'Select end date and time',
                          prefixIcon: const Icon(Icons.schedule),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'End date & time is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Venue and Attendees
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _locationController,
                          label: 'Venue',
                          hintText: 'e.g., Main Auditorium, Conference Hall',
                          prefixIcon: const Icon(Icons.location_on),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Venue is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _maxAttendeesController,
                          label: 'Expected Attendees',
                          hintText: 'e.g., 50',
                          prefixIcon: const Icon(Icons.people),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Expected attendees is required';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Target Audience
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Audience',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTargetAudience.isEmpty ? null : _selectedTargetAudience,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Select audience')),
                          ..._targetAudiences.map((audience) => DropdownMenuItem(
                            value: audience,
                            child: Text(audience),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedTargetAudience = value ?? ''),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Special Requirements
                  CustomTextField(
                    controller: _specialRequirementsController,
                    label: 'Special Requirements (Optional)',
                    hintText: 'Any special equipment, catering, or other requirements',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _loading ? 'Submitting...' : 'Submit Request',
                      onPressed: _loading ? null : _submitRequest,
                      variant: ButtonVariant.primary,
                      isLoading: _loading,
                      icon: Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Info Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What happens after you submit?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoItem('Management will review your event request within 2-3 business days'),
                _buildInfoItem('You\'ll receive a notification once your request is approved or requires modifications'),
                _buildInfoItem('Approved events will be visible to students and professors in their portals'),
                _buildInfoItem('You\'ll be contacted for any additional coordination required'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';
import '../common/custom_button.dart';

class AttendanceManagementWidget extends StatefulWidget {
  const AttendanceManagementWidget({super.key});

  @override
  State<AttendanceManagementWidget> createState() => _AttendanceManagementWidgetState();
}

class _AttendanceManagementWidgetState extends State<AttendanceManagementWidget> {
  String _activeTab = 'take-attendance';
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  String _selectedClass = '';
  bool _loading = false;
  bool _submitting = false;

  final List<String> _classes = ['I', 'II', 'III', 'IV'];

  Map<String, dynamic> _attendanceData = {
    'date': DateTime.now().toIso8601String().split('T')[0],
    'period': '',
    'notes': '',
    'studentAttendances': <Map<String, dynamic>>[],
  };

  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  Future<void> _loadStudents() async {
    if (_selectedClass.isEmpty) return;

    final user = context.read<AuthProvider>().user;
    final professorDepartment = user?.department;

    if (professorDepartment == null) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Professor department not found. Please contact administration.');
      return;
    }

    setState(() => _loading = true);

    try {
      final students = await ApiService.getStudentsForAttendance(professorDepartment, _selectedClass);
      setState(() {
        _students = students;
        _attendanceData['studentAttendances'] = students.map((student) => {
          'studentId': student['id'],
          'status': 'PRESENT',
          'remarks': '',
        }).toList();
      });

      if (students.isEmpty) {
        if (!mounted) return;
        context.read<ToastProvider>().showWarning('No students found for $professorDepartment department, Class $_selectedClass');
      }
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load students');
      setState(() => _students = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadAttendanceRecords() async {
    try {
      final records = await ApiService.getAttendanceRecords(_selectedClass.isEmpty ? null : _selectedClass);
      setState(() => _attendanceRecords = records);
    } catch (error) {
      setState(() => _attendanceRecords = []);
    }
  }

  Future<void> _submitAttendance() async {
    if (_attendanceData['period'].toString().trim().isEmpty) {
      context.read<ToastProvider>().showError('Please enter the period/subject name');
      return;
    }

    if (_selectedClass.isEmpty) {
      context.read<ToastProvider>().showError('Please select a class');
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = context.read<AuthProvider>().user;
      final submissionData = {
        'department': user?.department,
        'className': _selectedClass,
        'date': _attendanceData['date'],
        'period': _attendanceData['period'],
        'notes': _attendanceData['notes'],
        'studentAttendances': _attendanceData['studentAttendances'],
      };

      await ApiService.submitAttendance(submissionData);

      if (!mounted) return;
      context.read<ToastProvider>().showSuccess('Attendance submitted successfully!');

      // Reset form
      setState(() {
        _attendanceData = {
          'date': DateTime.now().toIso8601String().split('T')[0],
          'period': '',
          'notes': '',
          'studentAttendances': _students.map((student) => {
            'studentId': student['id'],
            'status': 'PRESENT',
            'remarks': '',
          }).toList(),
        };
      });

      _loadAttendanceRecords();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to submit attendance');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _updateStudentAttendance(String studentId, String field, String value) {
    setState(() {
      final attendances = _attendanceData['studentAttendances'] as List<Map<String, dynamic>>;
      final index = attendances.indexWhere((sa) => sa['studentId'] == studentId);
      if (index != -1) {
        attendances[index][field] = value;
      }
    });
  }

  void _markAllStudents(String status) {
    setState(() {
      final attendances = _attendanceData['studentAttendances'] as List<Map<String, dynamic>>;
      for (var attendance in attendances) {
        attendance['status'] = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyan.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade400, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
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
                      'Attendance Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'Track and manage student attendance',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_attendanceRecords.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Navigation
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 'take-attendance'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _activeTab == 'take-attendance' 
                          ? Colors.cyan.shade500 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Take Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _activeTab == 'take-attendance' ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 'view-records'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _activeTab == 'view-records' 
                          ? Colors.cyan.shade500 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View Records',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _activeTab == 'view-records' ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: _activeTab == 'take-attendance' 
              ? _buildTakeAttendanceTab() 
              : _buildViewRecordsTab(),
        ),
      ],
    );
  }

  Widget _buildTakeAttendanceTab() {
    return Column(
      children: [
        // Class Selection
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
                'Select Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: _classes.map((className) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedClass = className);
                    _loadStudents();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedClass == className 
                          ? Colors.cyan.shade50 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedClass == className 
                            ? Colors.cyan.shade500 
                            : AppTheme.borderLight,
                        width: _selectedClass == className ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Class $className',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedClass == className 
                                ? Colors.cyan.shade700 
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          context.read<AuthProvider>().user?.department ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Attendance Form
        if (_selectedClass.isNotEmpty)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle,
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
                              'Take Attendance - Class $_selectedClass',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_students.length} students enrolled',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Date, Period, Notes
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: TextEditingController(text: _attendanceData['date']),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Period/Subject *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              onChanged: (value) => _attendanceData['period'] = value,
                              decoration: InputDecoration(
                                hintText: 'e.g., Mathematics, Period 1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) => _attendanceData['notes'] = value,
                        decoration: InputDecoration(
                          hintText: 'Class notes or remarks',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Students List
                  if (_loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_students.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: AppTheme.textMuted),
                            SizedBox(height: 16),
                            Text(
                              'No Students Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          // Bulk Actions
                          Row(
                            children: [
                              const Text(
                                'Student Attendance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _markAllStudents('PRESENT'),
                                icon: const Icon(Icons.check_circle, size: 16),
                                label: const Text('All Present', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _markAllStudents('ABSENT'),
                                icon: const Icon(Icons.cancel, size: 16),
                                label: const Text('All Absent', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Students List
                          Expanded(
                            child: ListView.builder(
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                final attendances = _attendanceData['studentAttendances'] as List<Map<String, dynamic>>;
                                final studentAttendance = attendances.firstWhere(
                                  (sa) => sa['studentId'] == student['id'],
                                  orElse: () => {'status': 'PRESENT', 'remarks': ''},
                                );

                                return _buildStudentAttendanceCard(student, studentAttendance);
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: _submitting ? 'Submitting Attendance...' : 'Submit Attendance',
                              onPressed: _submitting || _attendanceData['period'].toString().trim().isEmpty 
                                  ? null 
                                  : _submitAttendance,
                              variant: ButtonVariant.primary,
                              isLoading: _submitting,
                              icon: Icons.save,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewRecordsTab() {
    return Column(
      children: [
        // Filter Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              const Text(
                'Attendance Records',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedClass.isEmpty ? null : _selectedClass,
                hint: const Text('All Classes'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Classes')),
                  ..._classes.map((className) => DropdownMenuItem(
                    value: className,
                    child: Text('Class $className'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedClass = value ?? '');
                  _loadAttendanceRecords();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Records List
        Expanded(
          child: _attendanceRecords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text(
                        'No Attendance Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Start taking attendance to see records here.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceRecords[index];
                    return _buildAttendanceRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceCard(Map<String, dynamic> student, Map<String, dynamic> attendance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  student['name']?.substring(0, 1).toUpperCase() ?? 'S',
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
                      student['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      student['studentId'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      student['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Buttons
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: [
                    _buildStatusButton('PRESENT', attendance['status'], Icons.check_circle, Colors.green, student['id']),
                    _buildStatusButton('ABSENT', attendance['status'], Icons.cancel, Colors.red, student['id']),
                    _buildStatusButton('LATE', attendance['status'], Icons.schedule, Colors.orange, student['id']),
                    _buildStatusButton('EXCUSED', attendance['status'], Icons.info, AppTheme.primaryBlue, student['id']),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Remarks
          TextField(
            onChanged: (value) => _updateStudentAttendance(student['id'], 'remarks', value),
            decoration: InputDecoration(
              hintText: 'Add remarks...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, String currentStatus, IconData icon, Color color, String studentId) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () => _updateStudentAttendance(studentId, 'status', status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecordCard(Map<String, dynamic> record) {
    final studentAttendances = record['studentAttendances'] as List? ?? [];
    final stats = _calculateAttendanceStats(studentAttendances);

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
          // Record Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.blueGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
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
                      '${record['period']} - Class ${record['className']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${_formatDate(record['date'])} by ${record['professorName']}',
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

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              Expanded(child: _buildStatItem('Total', '${stats['total']}', Colors.grey)),
              Expanded(child: _buildStatItem('Present', '${stats['present']}', Colors.green)),
              Expanded(child: _buildStatItem('Absent', '${stats['absent']}', Colors.red)),
              Expanded(child: _buildStatItem('Late', '${stats['late']}', Colors.orange)),
              Expanded(child: _buildStatItem('${stats['percentage'].toStringAsFixed(1)}%', 'Attendance', AppTheme.primaryBlue)),
            ],
          ),

          if (record['notes'] != null && record['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'Notes: ${record['notes']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateAttendanceStats(List studentAttendances) {
    final total = studentAttendances.length;
    final present = studentAttendances.where((sa) => sa['status'] == 'PRESENT').length;
    final absent = studentAttendances.where((sa) => sa['status'] == 'ABSENT').length;
    final late = studentAttendances.where((sa) => sa['status'] == 'LATE').length;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;

    return {
      'total': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': percentage,
    };
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
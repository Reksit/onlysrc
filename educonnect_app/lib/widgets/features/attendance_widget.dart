import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  Map<String, dynamic>? _attendanceSummary;
  bool _loading = true;
  int _selectedMonth = DateTime.now().month - 1;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadAttendanceSummary();
  }

  Future<void> _loadAttendanceSummary() async {
    try {
      final summary = await ApiService.getStudentAttendanceSummary();
      setState(() {
        _attendanceSummary = summary;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      if (!error.toString().contains('404')) {
        context.read<ToastProvider>().showError('Failed to load attendance data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading attendance data...');
    }

    if (_attendanceSummary == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text(
              'No Attendance Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'No attendance records found.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final attendancePercentage = _attendanceSummary!['attendancePercentage']?.toDouble() ?? 0.0;
    final attendanceGrade = _getAttendanceGrade(attendancePercentage);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 24),
              SizedBox(width: 12),
              Text(
                'My Attendance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Attendance Overview Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildAttendanceCard(
                'Total Days',
                '${_attendanceSummary!['totalDays'] ?? 0}',
                Icons.calendar_today,
                AppTheme.primaryBlue,
              ),
              _buildAttendanceCard(
                'Present',
                '${_attendanceSummary!['presentDays'] ?? 0}',
                Icons.check_circle,
                AppTheme.primaryGreen,
              ),
              _buildAttendanceCard(
                'Absent',
                '${_attendanceSummary!['absentDays'] ?? 0}',
                Icons.cancel,
                Colors.red,
              ),
              _buildAttendanceCard(
                'Attendance',
                '${attendancePercentage.toStringAsFixed(1)}%',
                Icons.person,
                attendanceGrade['color'],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Attendance Performance Card
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
                  'Attendance Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Text(
                      '${attendancePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: attendanceGrade['color'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attendanceGrade['grade'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: attendanceGrade['color'],
                            ),
                          ),
                          Text(
                            '${_attendanceSummary!['presentDays']} out of ${_attendanceSummary!['totalDays']} days',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildSmallStat('Late', '${_attendanceSummary!['lateDays'] ?? 0}', Colors.orange),
                        const SizedBox(height: 8),
                        _buildSmallStat('Excused', '${_attendanceSummary!['excusedDays'] ?? 0}', AppTheme.primaryBlue),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: attendancePercentage / 100,
                      backgroundColor: AppTheme.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        attendancePercentage >= 85 ? Colors.green :
                        attendancePercentage >= 75 ? Colors.orange : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        Text('Required: 75%', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        Text('100%', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Month Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: _selectedMonth,
                          items: List.generate(12, (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              _getMonthName(index),
                              style: const TextStyle(fontSize: 12),
                            ),
                          )),
                          onChanged: (value) => setState(() => _selectedMonth = value!),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - 2 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString(), style: const TextStyle(fontSize: 12)),
                            );
                          }),
                          onChanged: (value) => setState(() => _selectedYear = value!),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Attendance Records Table
                _buildAttendanceTable(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Attendance Guidelines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Guidelines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuidelineItem('Minimum 75% attendance required', Colors.green),
                _buildGuidelineItem('85%+ attendance for excellent grade', AppTheme.primaryBlue),
                _buildGuidelineItem('Contact professor for excused absences', Colors.orange),
                _buildGuidelineItem('Below 75% may affect academic standing', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
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
        ),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    final attendanceDetails = _attendanceSummary!['attendanceDetails'] as List? ?? [];
    final filteredDetails = attendanceDetails.where((detail) {
      final date = DateTime.parse(detail['date']);
      return date.month == _selectedMonth + 1 && date.year == _selectedYear;
    }).toList();

    if (filteredDetails.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: AppTheme.textMuted),
              SizedBox(height: 12),
              Text(
                'No attendance records for the selected month',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Period', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Professor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        // Table Rows
        ...filteredDetails.take(10).map((detail) => Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(detail['date']),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  detail['period'] ?? '',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(detail['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusIcon(detail['status']),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  detail['professorName'] ?? '',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        )).toList(),

        if (filteredDetails.length > 10)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Showing 10 most recent records out of ${filteredDetails.length} total',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuidelineItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAttendanceGrade(double percentage) {
    if (percentage >= 95) return {'grade': 'Excellent', 'color': Colors.green};
    if (percentage >= 85) return {'grade': 'Very Good', 'color': AppTheme.primaryBlue};
    if (percentage >= 75) return {'grade': 'Good', 'color': Colors.orange};
    if (percentage >= 65) return {'grade': 'Average', 'color': Colors.orange};
    return {'grade': 'Poor', 'color': Colors.red};
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'EXCUSED':
        return AppTheme.primaryBlue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'PRESENT':
        return '✓';
      case 'ABSENT':
        return '✗';
      case 'LATE':
        return '⏰';
      case 'EXCUSED':
        return '📝';
      default:
        return '?';
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../common/loading_widget.dart';

class ActivityHeatmapWidget extends StatefulWidget {
  final String? userId;
  final String? userName;
  final bool showTitle;

  const ActivityHeatmapWidget({
    super.key,
    this.userId,
    this.userName,
    this.showTitle = true,
  });

  @override
  State<ActivityHeatmapWidget> createState() => _ActivityHeatmapWidgetState();
}

class _ActivityHeatmapWidgetState extends State<ActivityHeatmapWidget> {
  Map<String, dynamic>? _heatmapData;
  bool _loading = true;
  String? _hoveredDate;

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  Future<void> _loadHeatmapData() async {
    try {
      final userId = widget.userId ?? context.read<AuthProvider>().user?.id;
      if (userId == null) return;

      final data = await ApiService.getHeatmapData(userId);
      setState(() {
        _heatmapData = data;
        _loading = false;
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      context.read<ToastProvider>().showError('Failed to load activity data');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading activity data...');
    }

    if (_heatmapData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text(
              'No Activity Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Start using the platform to see your activity heatmap',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final dailyTotals = _heatmapData!['dailyTotals'] as Map<String, dynamic>? ?? {};
    final totalActivities = dailyTotals.values.fold<int>(0, (sum, value) => sum + (value as int));
    final activeDays = dailyTotals.keys.where((date) => dailyTotals[date] > 0).length;
    final maxDaily = dailyTotals.values.fold<int>(0, (max, value) => value > max ? value : max);
    final avgDaily = totalActivities / 365;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (widget.showTitle) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Heatmap',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (widget.userName != null)
                        Text(
                          '• ${widget.userName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      const Text(
                        'Your contribution activity over the past year',
                        style: TextStyle(
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
          ],

          // Statistics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard('Total Activities', totalActivities.toString(), AppTheme.primaryBlue),
              _buildStatCard('Active Days', activeDays.toString(), Colors.green),
              _buildStatCard('Max Daily', maxDaily.toString(), AppTheme.primaryPurple),
              _buildStatCard('Daily Average', avgDaily.toStringAsFixed(1), AppTheme.primaryOrange),
            ],
          ),

          const SizedBox(height: 20),

          // Heatmap
          const Text(
            'Activity Heatmap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Simplified heatmap representation for mobile
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Activity Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActivityBar('Mon', _getWeekdayActivity(1)),
                      _buildActivityBar('Tue', _getWeekdayActivity(2)),
                      _buildActivityBar('Wed', _getWeekdayActivity(3)),
                      _buildActivityBar('Thu', _getWeekdayActivity(4)),
                      _buildActivityBar('Fri', _getWeekdayActivity(5)),
                      _buildActivityBar('Sat', _getWeekdayActivity(6)),
                      _buildActivityBar('Sun', _getWeekdayActivity(7)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Less', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    Row(
                      children: [
                        _buildLegendSquare(AppTheme.backgroundLight),
                        const SizedBox(width: 2),
                        _buildLegendSquare(Colors.green.shade100),
                        const SizedBox(width: 2),
                        _buildLegendSquare(Colors.green.shade300),
                        const SizedBox(width: 2),
                        _buildLegendSquare(Colors.green.shade500),
                        const SizedBox(width: 2),
                        _buildLegendSquare(Colors.green.shade700),
                      ],
                    ),
                    const Text('More', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(String day, int activity) {
    final maxActivity = 10; // Assume max 10 activities per day
    final height = (activity / maxActivity * 100).clamp(10.0, 100.0);

    return Column(
      children: [
        Expanded(
          child: Container(
            width: 20,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 16,
              height: height,
              decoration: BoxDecoration(
                color: _getActivityColor(activity),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendSquare(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppTheme.borderLight),
      ),
    );
  }

  Color _getActivityColor(int count) {
    if (count == 0) return AppTheme.backgroundLight;
    if (count <= 2) return Colors.green.shade100;
    if (count <= 4) return Colors.green.shade300;
    if (count <= 6) return Colors.green.shade500;
    return Colors.green.shade700;
  }

  int _getWeekdayActivity(int weekday) {
    // Calculate average activity for this weekday
    final dailyTotals = _heatmapData!['dailyTotals'] as Map<String, dynamic>? ?? {};
    int total = 0;
    int count = 0;

    dailyTotals.forEach((dateString, activity) {
      final date = DateTime.parse(dateString);
      if (date.weekday == weekday) {
        total += activity as int;
        count++;
      }
    });

    return count > 0 ? (total / count).round() : 0;
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
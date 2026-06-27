import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_models.dart';
import '../../core/services/screen_time_service.dart';

class ChildDashboard extends StatefulWidget {
  final AppUser user;
  final int goalMinutes;

  const ChildDashboard({
    super.key,
    required this.user,
    this.goalMinutes = 120,
  });

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _loading = true;
  int _screenTimeToday = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadScreenTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check permission when user returns from Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadScreenTime();
    }
  }

  Future<void> _loadScreenTime() async {
    setState(() => _loading = true);
    final hasPermission = await ScreenTimeService.hasPermission();
    if (hasPermission) {
      final minutes = await ScreenTimeService.getScreenTimeToday();
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _screenTimeToday = minutes;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text('Hi, ${widget.user.name}!'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 20),
                SizedBox(width: 4),
                Text('\$3.00',
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildPermissionGate()
              : _buildDashboard(),
    );
  }

  Widget _buildPermissionGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android,
                  size: 64, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 24),
            const Text(
              'Usage Access Needed',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),
            const Text(
              'To track your screen time and reward you for meeting your goals, we need permission to read your device usage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await ScreenTimeService.requestPermission();
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Grant Access in Settings'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final goal = widget.goalMinutes;
    final used = _screenTimeToday;
    final remaining = (goal - used).clamp(0, goal);
    final progress = goal > 0 ? (used / goal).clamp(0.0, 1.0) : 0.0;
    final onTrack = used <= goal;

    return RefreshIndicator(
      onRefresh: _loadScreenTime,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Daily progress card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: onTrack
                      ? [AppTheme.primaryPurple, const Color(0xFF7C4DFF)]
                      : [AppTheme.errorRed, const Color(0xFFFF5252)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (onTrack ? AppTheme.primaryPurple : AppTheme.errorRed)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Screen Time Today',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ScreenTimeService.formatMinutes(used),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of ${ScreenTimeService.formatMinutes(goal)} goal',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color: onTrack ? Colors.white : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    onTrack
                        ? '${ScreenTimeService.formatMinutes(remaining)} remaining — keep it up!'
                        : 'Goal exceeded by ${ScreenTimeService.formatMinutes(used - goal)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Missions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildGoalCard(
                    title: 'Under ${ScreenTimeService.formatMinutes(goal)} Total',
                    current: used,
                    max: goal,
                    reward: 1.00,
                    isCompleted: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required int current,
    required int max,
    required double reward,
    required bool isCompleted,
    String? description,
  }) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Text(
                  '+\$${reward.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(description,
                style:
                    const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: isCompleted ? AppTheme.successGreen : AppTheme.accentBlue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompleted
                    ? 'Completed!'
                    : '${ScreenTimeService.formatMinutes(current)} / ${ScreenTimeService.formatMinutes(max)}',
                style: TextStyle(
                  color:
                      isCompleted ? AppTheme.successGreen : AppTheme.textGrey,
                  fontWeight:
                      isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isCompleted)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Claim'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

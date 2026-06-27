import 'package:flutter/services.dart';

class ScreenTimeService {
  static const _channel = MethodChannel('com.base44.screentime_rewards/usage_stats');

  static Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
  }

  /// Returns total screen time for today in minutes.
  static Future<int> getScreenTimeToday() async {
    try {
      return await _channel.invokeMethod<int>('getScreenTimeToday') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Returns total screen time between [start] and [end] in minutes.
  static Future<int> getScreenTimeForRange(DateTime start, DateTime end) async {
    try {
      return await _channel.invokeMethod<int>('getScreenTimeForRange', {
            'startTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
          }) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  static String formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

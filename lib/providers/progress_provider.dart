import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_service.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class ProgressProvider extends ChangeNotifier {
  final BuildContext context;
  List<HealthGoalProgress> _progressList = [];

  List<HealthGoalProgress> get progressList => _progressList;

  Timer? _timer;

  ProgressProvider(this.context) {
    _calculateProgress();

    // Start timer to update progress every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _calculateProgress();
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays >= 365) {
      final years = duration.inDays ~/ 365;
      final remainingDays = duration.inDays % 365;

      if (remainingDays >= 30) {
        final months = remainingDays ~/ 30;
        final days = remainingDays % 30;
        return '$years ${years == 1 ? 'year' : 'years'} '
            '${months > 0 ? '$months ${months == 1 ? 'month' : 'months'} ' : ''}'
            '${days > 0 ? 'and $days ${days == 1 ? 'day' : 'days'} ' : ''}left';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'} '
            '${remainingDays > 0 ? 'and $remainingDays ${remainingDays == 1 ? 'day' : 'days'} ' : ''}left';
      }
    } else if (duration.inDays >= 30) {
      final months = duration.inDays ~/ 30;
      final remainingDays = duration.inDays % 30;
      return '$months ${months == 1 ? 'month' : 'months'} '
          '${remainingDays > 0 ? 'and $remainingDays ${remainingDays == 1 ? 'day' : 'days'} ' : ''}left';
    } else if (duration.inDays >= 7) {
      final weeks = duration.inDays ~/ 7;
      final remainingDays = duration.inDays % 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} '
          '${remainingDays > 0 ? 'and $remainingDays ${remainingDays == 1 ? 'day' : 'days'} ' : ''}left';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'} left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'} left';
    } else {
      return 'Less than an hour left';
    }
  }

  void _calculateProgress() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final quitDate = user?.quitDate.toDate();

    if (quitDate == null) {
      _progressList = [];
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    _progressList = MockDataService.healthGoals.map((goal) {
      final elapsed = now.difference(quitDate);
      final progress =
          (elapsed.inSeconds / goal.targetDuration.inSeconds).clamp(0.0, 1.0);
      final progressPercent = (progress * 100).toInt();
      final timeLeft = goal.targetDuration - elapsed;
      final timeLeftStr = timeLeft.isNegative
          ? 'Completed'
          : _formatDuration(timeLeft); // Use a helper function

      return HealthGoalProgress(
        description: goal.description,
        progress: progress,
        progressPercent: progressPercent,
        timeLeftStr: timeLeftStr,
      );
    }).toList();

    notifyListeners();
  }

  /// Call this to refresh progress, e.g. on pull-to-refresh or timer
  void refreshProgress() {
    _calculateProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HealthGoalProgress {
  final String description;
  final double progress;
  final int progressPercent;
  final String timeLeftStr;

  HealthGoalProgress({
    required this.description,
    required this.progress,
    required this.progressPercent,
    required this.timeLeftStr,
  });
}

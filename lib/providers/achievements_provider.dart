import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart'; // For Lock
import 'user_provider.dart';
import '../services/firestore_service.dart';

class Achievement {
  final String title;
  final String description;
  final String iconPath;
  final double progress; // 0.0 to 1.0
  final int xp;
  final bool isAwarded;

  Achievement({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.progress,
    required this.xp,
    this.isAwarded = false,
  });

  Achievement copyWith({
    bool? isAwarded,
    double? progress,
  }) {
    return Achievement(
      title: title,
      description: description,
      iconPath: iconPath,
      progress: progress ?? this.progress,
      xp: xp,
      isAwarded: isAwarded ?? this.isAwarded,
    );
  }
}

class AchievementsProvider with ChangeNotifier {
  late List<Achievement> _achievements;
  late UserProvider _userProvider;
  final Set<String> _awardedAchievements = {};
  final Lock _calculationLock = Lock(); // For thread-safe operations
  DateTime _lastCalculationTime = DateTime.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _disposed = false;

  Timer? _debounceTimer;

  AchievementsProvider(UserProvider userProvider) {
    _userProvider = userProvider;
    _userProvider.addListener(_onUserChanged);
    _achievements = _generateAchievements(_userProvider);
    _loadAwardedAchievements();
  }

  void _onUserChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 30), () {
      _calculateAchievements();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _userProvider.removeListener(_onUserChanged);
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadAwardedAchievements() async {
    _setLoading(true);
    try {
      final completed = await _userProvider.firestoreService
          .getCompletedAchievements(_userProvider.user!.id);
      _awardedAchievements.addAll(completed);
      _achievements = _generateAchievements(_userProvider);
      debugPrint(
          'Loaded ${completed.length} completed achievements from Firestore');
    } catch (e) {
      debugPrint("Failed to load achievements: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    // Delay notification until after build completes
    Future.delayed(Duration.zero, () {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> calculateAchievements() async {
    await _calculateAchievements();
  }

  Future<void> _calculateAchievements() async {
    // Skip if already calculating or disposed
    if (_isLoading || _disposed) return;

    if (!_userProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _calculateAchievements();
    }

    await _calculationLock.synchronized(() async {
      try {
        _setLoading(true);
        _lastCalculationTime = DateTime.now();

        debugPrint('Starting achievement calculation...');
        final newAchievements = _generateAchievements(_userProvider);
        bool needsUpdate = false;
        final batch =
            _userProvider.firestoreService.createBatch(); // Changed here

        // Find newly completed achievements
        final newlyCompleted = newAchievements.where((achievement) {
          return achievement.progress >= 1.0 &&
              !_awardedAchievements.contains(achievement.title) &&
              !achievement.isAwarded;
        }).toList();

        if (newlyCompleted.isNotEmpty) {
          debugPrint(
              'Found ${newlyCompleted.length} newly completed achievements');

          // Prepare batch update
          int totalXpToAward = 0;
          final achievementsToMark = <String>[];

          for (var achievement in newlyCompleted) {
            debugPrint(
                'Awarding achievement: ${achievement.title} with ${achievement.xp} XP');
            totalXpToAward += achievement.xp;
            _awardedAchievements.add(achievement.title);
            achievementsToMark.add(achievement.title);
          }

          // Single batch operation for all achievements
          await _userProvider.firestoreService.markAchievementsCompleted(
            _userProvider.user!.id,
            achievementsToMark,
            totalXpToAward,
          );

          // Update local state
          await _userProvider.markAchievementsAsCompleted(
            achievementsToMark,
            xp: totalXpToAward,
          );

          needsUpdate = true;
        }

        if (needsUpdate) {
          _achievements = newAchievements;
          debugPrint('Achievements updated with new completions');
        }
      } catch (e) {
        debugPrint("Error in achievement calculation: $e");
      } finally {
        _setLoading(false);
      }
    });
  }

  Future<void> initialize(UserProvider userProvider) async {
    _userProvider = userProvider;
    _userProvider.addListener(_onUserChanged);

    // Wait for user provider to be ready with achievements
    while (!userProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _loadAwardedAchievements();
    _achievements = _generateAchievements(_userProvider);
    await _calculateAchievements(); // Immediate calculation
    notifyListeners();
  }

  Future<void> loadAwardedAchievements() async {
    _setLoading(true);
    try {
      final completed = await _userProvider.firestoreService
          .getCompletedAchievements(_userProvider.user!.id);
      _awardedAchievements.addAll(completed);
      _achievements = _generateAchievements(_userProvider);
      debugPrint(
          'Loaded ${completed.length} completed achievements from Firestore');
    } catch (e) {
      debugPrint("Failed to load achievements: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAchievements() async {
    _setLoading(true);

    try {
      final userId = _userProvider.user!.id;

      // Clear achievements locally
      _awardedAchievements.clear();

      // Reset achievements in Firestore
      await _userProvider.firestoreService.resetCompletedAchievements(userId);

      // Regenerate achievements list with no awarded achievements
      _achievements = _generateAchievements(_userProvider);

      // Also update userProvider's completedAchievements if it stores them
      _userProvider.completedAchievements.clear();

      notifyListeners();
      debugPrint('Achievements reset successfully.');
    } catch (e) {
      debugPrint('Failed to reset achievements: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Achievement> get achievements => _achievements;

  List<Achievement> _generateAchievements(UserProvider userProvider) {
    final now = DateTime.now();
    final quitDate = userProvider.quitDate;
    final daysSmokeFree =
        quitDate != null ? now.difference(quitDate).inDays : 0;
    final moneySaved = userProvider.moneySaved;
    final cigarettesNotSmoked = userProvider.cigarettesAvoided;

    final allAchievements = [
      Achievement(
        title: 'First Smoke-Free Day',
        description: 'You made it through your first day without smoking!',
        iconPath: 'assets/images/calendar1.png',
        progress: (daysSmokeFree >= 1) ? 1.0 : 0.0,
        xp: 100,
      ),
      Achievement(
        title: '3 Days Smoke-Free',
        description: '3 days without a cigarette – great job staying strong!',
        iconPath: 'assets/images/calendar2.png',
        progress: (daysSmokeFree / 3).clamp(0.0, 1.0),
        xp: 150,
      ),
      Achievement(
        title: '1 Week Smoke-Free',
        description: '7 days without a cigarette! Keep up the momentum.',
        iconPath: 'assets/images/calendar3.png',
        progress: (daysSmokeFree / 7).clamp(0.0, 1.0),
        xp: 300,
      ),
      Achievement(
        title: '2 Weeks Smoke-Free',
        description: '14 days smoke-free – you’re getting stronger every day!',
        iconPath: 'assets/images/calendar4.png',
        progress: (daysSmokeFree / 14).clamp(0.0, 1.0),
        xp: 400,
      ),
      Achievement(
        title: '1 Month Smoke-Free',
        description: '30 days without a cigarette! Your body is healing.',
        iconPath: 'assets/images/calendar.png',
        progress: (daysSmokeFree / 30).clamp(0.0, 1.0),
        xp: 500,
      ),
      Achievement(
        title: '3 Months Smoke-Free',
        description:
            '90 days smoke-free! Lung function improves significantly.',
        iconPath: 'assets/images/calendar.png',
        progress: (daysSmokeFree / 90).clamp(0.0, 1.0),
        xp: 700,
      ),
      Achievement(
        title: '6 Months Smoke-Free',
        description:
            'Half a year smoke-free. Your risk of heart disease is decreasing.',
        iconPath: 'assets/images/calendar.png',
        progress: (daysSmokeFree / 180).clamp(0.0, 1.0),
        xp: 900,
      ),
      Achievement(
        title: '1 Year Smoke-Free',
        description: '1 year without smoking! Your health is much improved.',
        iconPath: 'assets/images/calendar.png',
        progress: (daysSmokeFree / 365).clamp(0.0, 1.0),
        xp: 1200,
      ),
      Achievement(
        title: 'Saved €50',
        description: 'Saved 50€ by not buying cigarettes.',
        iconPath: 'assets/images/money.png',
        progress: (moneySaved / 50).clamp(0.0, 1.0),
        xp: 400,
      ),
      Achievement(
        title: 'Saved €100',
        description: 'Saved 100€ by not buying cigarettes.',
        iconPath: 'assets/images/money4.png',
        progress: (moneySaved / 100).clamp(0.0, 1.0),
        xp: 600,
      ),
      Achievement(
        title: 'Saved €300',
        description: 'Saved 300€ by not buying cigarettes.',
        iconPath: 'assets/images/money2.png',
        progress: (moneySaved / 100).clamp(0.0, 1.0),
        xp: 600,
      ),
      Achievement(
        title: 'Saved €500',
        description: 'Saved 500€ by quitting smoking – that’s a lot of money!',
        iconPath: 'assets/images/money3.png',
        progress: (moneySaved / 500).clamp(0.0, 1.0),
        xp: 1000,
      ),
      Achievement(
        title: 'Heartbeat Restored',
        description: 'After 24 hours, your heart rate has returned to normal.',
        iconPath: 'assets/images/heartBeat.png',
        progress: (daysSmokeFree >= 1) ? 1.0 : 0.0,
        xp: 250,
      ),
      Achievement(
        title: 'Improved Circulation',
        description: 'Circulation improves significantly after 1 month.',
        iconPath: 'assets/images/circulation.png',
        progress: (daysSmokeFree / 30).clamp(0.0, 1.0),
        xp: 400,
      ),
      Achievement(
        title: 'Lung Function Boost',
        description: 'Lung function improves after 3 months without smoking.',
        iconPath: 'assets/images/lungsAchievement.png',
        progress: (daysSmokeFree / 90).clamp(0.0, 1.0),
        xp: 700,
      ),
      Achievement(
        title: 'Cancer Risk Reduced',
        description:
            'After 10 years smoke-free, your lung cancer risk is reduced by 50%.',
        iconPath: 'assets/images/cancer.png',
        progress: (daysSmokeFree / 3650).clamp(0.0, 1.0),
        xp: 1500,
      ),
      Achievement(
        title: 'Heart Disease Risk Normalized',
        description:
            'After 15 years, your heart disease risk equals that of non-smokers.',
        iconPath: 'assets/images/risk.png',
        progress: (daysSmokeFree / 5475).clamp(0.0, 1.0),
        xp: 2000,
      ),
      Achievement(
        title: 'First Cigarette Avoided',
        description: 'You resisted your first cigarette! Keep it up.',
        iconPath: 'assets/images/cigarettes1.png',
        progress: (cigarettesNotSmoked >= 1) ? 1.0 : 0.0,
        xp: 100,
      ),
      Achievement(
        title: '10 Cigarettes Avoided',
        description: 'Great job avoiding 10 cigarettes so far!',
        iconPath: 'assets/images/cigarettes2.png',
        progress: (cigarettesNotSmoked / 10).clamp(0.0, 1.0),
        xp: 300,
      ),
      Achievement(
        title: '50 Cigarettes Avoided',
        description: 'You have avoided 50 cigarettes – amazing progress!',
        iconPath: 'assets/images/cigarettes3.png',
        progress: (cigarettesNotSmoked / 50).clamp(0.0, 1.0),
        xp: 600,
      ),
      Achievement(
        title: '100 Cigarettes Avoided',
        description: '100 cigarettes not smoked – your lungs thank you!',
        iconPath: 'assets/images/cigarettes4.png',
        progress: (cigarettesNotSmoked / 100).clamp(0.0, 1.0),
        xp: 900,
      ),
      Achievement(
        title: '500 Cigarettes Avoided',
        description: 'Half a thousand cigarettes avoided! You’re unstoppable.',
        iconPath: 'assets/images/cigarettes5.png',
        progress: (cigarettesNotSmoked / 500).clamp(0.0, 1.0),
        xp: 1500,
      ),
    ];

    return allAchievements.map((achievement) {
      final isAwarded = _awardedAchievements.contains(achievement.title) ||
          userProvider.completedAchievements.contains(achievement.title);

      return achievement.copyWith(
        isAwarded: isAwarded,
      );
    }).toList();
  }
}

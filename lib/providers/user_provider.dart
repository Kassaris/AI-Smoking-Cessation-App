import 'dart:async';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smoking_app/models/user_model.dart';
import 'package:smoking_app/services/firestore_service.dart';
import '../services/app_data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
// Needed for ChangeNotifier

class UserProvider extends ChangeNotifier {
  // Add this at the top of your UserProvider
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Modify your loadUserByEmailOrCreate method:
  Future<void> loadUserByEmailOrCreate(User firebaseUser) async {
    try {
      final email = firebaseUser.email!;
      final existingUser = await _firestoreService.getUserByEmail(email);

      if (existingUser != null) {
        _userModel = existingUser;
        _completedAchievements = existingUser.completedAchievements ?? [];
        _setupRealtimeListener(firebaseUser.uid);
      } else {
        final newUser = UserModel(
            id: firebaseUser.uid,
            username: firebaseUser.displayName ?? 'GoogleUser',
            email: email,
            password: '',
            gender: 'unknown',
            cigarettesPerDay: 0, // Default values
            cigarettesPerPack: 0,
            costPerPack: 0,
            smokingYears: 0,
            userRank: 0,
            userXP: 0,
            quitDate: Timestamp.now(),
            completedAchievements: [],
            friendsList: [],
            socialTag: '0000',
            whySmoke: 'unknown',
            feelWhenSmoking: 'unknown',
            typeOfSmoker: 'unknown',
            whyQuit: 'unknown',
            triedQuitMethods: 'unknown',
            emotionalMeaning: 'unknown',
            cravingSituations: 'unknown',
            confidenceLevel: 'unknown',
            smokingEnvironment: 'unknown',
            biggestFear: 'unknown',
            biggestMotivation: 'unknown');

        await _firestoreService.addUser(firebaseUser.uid, newUser);
        _userModel = newUser;
        _setupRealtimeListener(firebaseUser.uid);
      }

      print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');

      // Initialize stats
      _updateMinuteStats();
      ensureUserHasRoom();
      startMinuteUpdates();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Make sure this method is public by removing the underscore
  void updateMinuteStats() {
    _updateMinuteStats();
  }

  FirestoreService get firestoreService => _firestoreService; // 👈 ADD THIS

  Timer? _timer;
  int minutesSinceQuit = 0;
  int cigarettesAvoided = 0;
  double moneySaved = 0.0;
  int lifeGainedMinutes = 0;
  String _roomId = '';

  // Getters
  String get username => _userModel?.username ?? '';
  int get rank => _calculateUserRank(_userModel!.userXP);
  String get ranktitle => _getRankTitle(_userModel?.userRank ?? 1);
  int get currentXP => _userModel?.userXP ?? 0;
  int get xpToLevelUp => _calculateXpToLevelUp(_userModel?.userXP ?? 0);
  List<String> _completedAchievements = [];
  List<String> get completedAchievements => _completedAchievements;
  int get minutesOfLifeGained => _calculateLifeGained();
  DateTime get quitDate => _userModel?.quitDate.toDate() ?? DateTime.now();
  int get smokingYears => _userModel?.smokingYears ?? 0;
  int get cigarettesPerDay => _userModel?.cigarettesPerDay ?? 0;
  String get roomId => _roomId;

  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userModel;
  UserModel? get user => _userModel;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Call this after login with email or Google to ensure Firestore user exists

  void clearUser() {
    _userModel = null;
    notifyListeners();
  }

  Future<void> ensureUserHasRoom() async {
    if (_userModel == null) return;
    _roomId = await _firestoreService.assignUserToChatRoom(
        _userModel!.id, _userModel!.username);
    notifyListeners();
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_userModel == null) throw Exception('No user loaded');

    await _firestoreService.updateUserDocument(_userModel!.id, data);

    // Optionally update local user model if needed
    _userModel = _userModel!.copyWith(
        cigarettesPerDay: data['cigarettesperDay'],
        cigarettesPerPack: data['cigarettesPerPack'],
        costPerPack: data['costPerPack'],
        gender: data['gender'],
        smokingYears: data['smokingYears'],
        questionnaireCompleted: data['questionnaireCompleted'],
        hasRated: data['hasRated'],
        userRank: data['userRank'],
        whySmoke: data['whySmoke'],
        feelWhenSmoking: data['feelWhenSmoking'],
        typeOfSmoker: data['typeOfSmoker'],
        whyQuit: data['whyQuit'],
        triedQuitMethods: data['triedQuitMethods'],
        emotionalMeaning: data['emotionalMeaning'],
        cravingSituations: data['cravingSituations'],
        confidenceLevel: data['confidenceLevel'],
        smokingEnvironment: data['smokingEnvironment'],
        biggestFear: data['biggestFear'],
        biggestMotivation: data['biggestMotivation']);

    notifyListeners();
  }

  Future<void> loadUserById(String uid) async {
    final fetchedUser = await _firestoreService.getUserById(uid);
    if (fetchedUser != null) {
      _userModel = fetchedUser;
      _completedAchievements = fetchedUser.completedAchievements ?? [];
      notifyListeners();
    }
  }

  void _setupRealtimeListener(String userId) {
    _firestoreService.getUserStream(userId).listen((userModel) {
      if (userModel != null) {
        _userModel = userModel;
        _completedAchievements = userModel.completedAchievements ?? [];
        _updateMinuteStats();
        notifyListeners();
      }
    });
  }

  Future<void> markAchievementsAsCompleted(List<String> achievementIds,
      {int xp = 0}) async {
    if (_userModel == null) return;

    // Filter out already completed achievements
    final newAchievements = achievementIds
        .where((id) => !_completedAchievements.contains(id))
        .toList();

    if (newAchievements.isEmpty) return;

    // Update local state
    _completedAchievements.addAll(newAchievements);
    _userModel = _userModel!.copyWith(
      completedAchievements: _completedAchievements,
      userXP: (_userModel!.userXP ?? 0) + xp,
    );

    notifyListeners();
  }

  void startMinuteUpdates() {
    _timer?.cancel();

    if (_userModel == null || _userModel!.quitDate == null) {
      print('startMinuteUpdates: No user or quit date.');
      return;
    }

    print('Starting minute updates...');

    _updateMinuteStats(); // Immediate update

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      print('Timer tick: updating stats...');
      _updateMinuteStats();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateMinuteStats() {
    if (_userModel == null || _userModel!.quitDate == null) return;

    final now = DateTime.now();
    final quitDate = _userModel!.quitDate.toDate();

    minutesSinceQuit = now.difference(quitDate).inMinutes;
    cigarettesAvoided = _calculateCigarettesAvoided();
    moneySaved = _calculateMoneySaved();
    lifeGainedMinutes = _calculateLifeGained();

    print(
        'Updating stats: minutesSinceQuit=$minutesSinceQuit, cigarettesAvoided=$cigarettesAvoided, moneySaved=$moneySaved');

    // Delay the notification until after the build completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  int _calculateCigarettesAvoided() {
    if (_userModel == null || _userModel!.cigarettesPerDay == 0) return 0;
    final perMinuteRate = _userModel!.cigarettesPerDay / 1440.0;
    //notifyListeners(); // Trigger UI updates
    return (minutesSinceQuit * perMinuteRate).floor();
  }

  double _calculateMoneySaved() {
    if (_userModel == null || _userModel!.cigarettesPerPack == 0) return 0.0;
    final packsAvoided =
        cigarettesAvoided / _userModel!.cigarettesPerPack.toDouble();
    return packsAvoided * _userModel!.costPerPack;
  }

  double calculateMoneyPerDay() {
    if (_userModel == null || _userModel!.cigarettesPerPack == 0) return 0.0;
    final packsPerDay =
        _userModel!.cigarettesPerDay / _userModel!.cigarettesPerPack.toDouble();
    return packsPerDay * _userModel!.costPerPack;
  }

  int _calculateLifeGained() {
    return cigarettesAvoided * 11; // 5 minutes per cigarette avoided
  }

  String get formattedSmokeFreeTime {
    if (_userModel == null || _userModel!.quitDate == null) return '';

    final now = DateTime.now();
    final quitDate = _userModel!.quitDate.toDate();
    final diff = now.difference(quitDate);

    final years = diff.inDays ~/ 365;
    final months = (diff.inDays % 365) ~/ 30;
    final weeks = (diff.inDays % 30) ~/ 7;
    final days = diff.inDays % 7;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (diff.inMinutes < 60) {
      return '$minutes minute${_s(minutes)} $seconds second${_s(seconds)}';
    } else if (diff.inHours < 24) {
      return '$hours hour${_s(hours)} $minutes minute${_s(minutes)}';
    } else if (diff.inDays < 7) {
      return '$days day${_s(days)} $hours hour${_s(hours)} $minutes minute${_s(minutes)}';
    } else if (diff.inDays < 30) {
      return '$weeks week${_s(weeks)} $days day${_s(days)} $hours hour${_s(hours)}';
    } else if (diff.inDays < 365) {
      final extra = days >= 7
          ? ' (${weeks + (days ~/ 7)} week${_s(weeks + (days ~/ 7))})'
          : '';
      return '$months month${_s(months)} $days day${_s(days)}$extra';
    } else {
      return '$years year${_s(years)} $months month${_s(months)} $days day${_s(days)}';
    }
  }

  String _s(int value) => value == 1 ? '' : 's';

  // In your user_provider.dart

  int get smokeFreeDays {
    if (_userModel == null || _userModel!.quitDate == null) return 0;
    final quitDate = _userModel!.quitDate.toDate();
    final now = DateTime.now();
    return now.difference(quitDate).inDays;
  }

  Future<void> updateRank() async {
    if (_userModel == null) return;

    final newRank = _calculateUserRank(_userModel!.userXP);

    // Only update if rank actually changed
    if (newRank != _userModel!.userRank) {
      await _firestoreService.updateUserDocument(_userModel!.id, {
        'userRank': newRank,
      });

      _userModel = _userModel!.copyWith(userRank: newRank);
      notifyListeners();
    }
  }

  int _calculateXpToLevelUp(int currentXP) {
    final int currentRank = (currentXP / 1000).floor();
    final int XpToLevelUp = (currentRank + 1) * 1000;
    return XpToLevelUp;
  }

  String _getRankTitle(int rank) {
    const titles = [
      'Newbie',
      'Fighter',
      'Achiever',
      'Champion',
      'QuIT Master',
      'Finaly Free'
    ];
    return titles[(rank).clamp(0, titles.length - 1)];
  }

  String getRankBadge(int rank) {
    const badges = [
      'assets/images/no_smoking.jpg',
      'assets/images/heart.jpg',
      'assets/images/lungs.jpeg',
      'assets/images/champion.jpg',
      'assets/images/quit_master.jpg',
      'assets/images/smoke_free.jpg'
    ];
    return badges[(rank).clamp(0, badges.length - 1)];
  }

  Future<void> incrementXP(int xp) async {
    if (_userModel == null || xp <= 0) return;

    try {
      final newXP = _userModel!.userXP + xp;
      final newRank = _calculateUserRank(newXP);

      debugPrint(
          'Updating - Current Rank: ${_userModel!.userRank}, New Rank: $newRank');
      debugPrint(
          'Updating - Current XP: ${_userModel!.userXP}, New XP: $newXP');

      // Update Firestore
      await _firestoreService.updateUserDocument(_userModel!.id, {
        'userXP': newXP,
        'userRank':
            newRank, // Make sure this matches your Firestore field name exactly
      });

      // Update local state
      _userModel = _userModel!.copyWith(
        userXP: newXP,
        userRank: newRank,
      );

      notifyListeners();

      debugPrint('Successfully updated XP and rank in Firestore');
    } catch (e) {
      debugPrint('Error updating XP and rank: $e');
      // Consider adding error recovery here
    }
  }

// Updated rank calculation method
  int _calculateUserRank(int currentXP) {
    return (currentXP / 1000).floor();
  }
}

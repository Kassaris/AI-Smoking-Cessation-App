import 'package:flutter/material.dart';
import 'package:smoking_app/models/user_model.dart';
import 'package:smoking_app/services/firestore_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<UserModel> _topUsers = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  List<UserModel> _allUsers = [];

  List<UserModel> get allUsers => _allUsers;

  List<UserModel> get topUsers => _topUsers;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  Future<void> loadLeaderboard(UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();

    final allUsers = await FirestoreService().getAllUsers();
    _currentUser = currentUser;

    final now = DateTime.now();
    final currentUserQuitDate = currentUser.quitDate.toDate();
    final daysSinceQuit = now.difference(currentUserQuitDate).inDays;
    final isNewQuitter = daysSinceQuit < 40;

    // Filter users based on quit date
    final filteredUsers = allUsers.where((user) {
      final userQuitDate = user.quitDate.toDate();
      final userDays = now.difference(userQuitDate).inDays;
      return isNewQuitter ? userDays < 40 : userDays < 40;
    }).toList();

    // Sort by userRank ascending
    filteredUsers.sort((b, a) => a.userRank.compareTo(b.userRank));

    // Top 10
    _topUsers = filteredUsers.take(10).toList();

    // If current user isn't in the top 10, add them to bottom
    final isInTop10 = _topUsers.any((user) => user.id == currentUser.id);
    if (!isInTop10) {
      // Find correct sorted index
      final indexInFullList =
          filteredUsers.indexWhere((user) => user.id == currentUser.id);
      if (indexInFullList != -1) {
        _topUsers.add(filteredUsers[indexInFullList]);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}

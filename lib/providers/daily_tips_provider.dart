import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_provider.dart';
import '../services/app_data_service.dart';

class DailyTipsProvider with ChangeNotifier {
  final UserProvider userProvider;

  int _unlockedTipsCount = 0;
  List<Tip> _unlockedTips = [];

  DailyTipsProvider({required this.userProvider}) {
    _calculateUnlockedTips();
    _loadTipRatings();
    userProvider.addListener(_onUserDataChanged);
  }

  int get unlockedTipsCount => _unlockedTipsCount;

  List<Tip> get tipsSortedByRating {
    final tips = List<Tip>.from(_unlockedTips);
    tips.sort((a, b) => b.rating.compareTo(a.rating));
    return tips;
  }

  void refresh() {
    _calculateUnlockedTips();
    _loadTipRatings();
  }

  void _calculateUnlockedTips() {
    final quitDate = userProvider.quitDate;
    _unlockedTipsCount = (DateTime.now().difference(quitDate).inDays + 1)
        .clamp(1, MockDataService.cravingsTips.length);
    _unlockedTips = List<Tip>.from(MockDataService.cravingsTips);
    notifyListeners();
  }

  Future<void> _loadTipRatings() async {
    final prefs = await SharedPreferences.getInstance();
    for (var tip in MockDataService.cravingsTips) {
      final rating = prefs.getInt('tipRating_${tip.title}') ?? 0;
      tip.rating = rating;
    }
    notifyListeners();
  }

  Future<void> rateTip(String title, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tipRating_$title', rating);

    final tipIndex = _unlockedTips.indexWhere((t) => t.title == title);
    if (tipIndex != -1) {
      _unlockedTips[tipIndex].rating = rating;
    }

    notifyListeners(); // Trigger UI update immediately after rating change
  }

  void _onUserDataChanged() {
    _calculateUnlockedTips();
  }

  @override
  void dispose() {
    userProvider.removeListener(_onUserDataChanged);
    super.dispose();
  }
}

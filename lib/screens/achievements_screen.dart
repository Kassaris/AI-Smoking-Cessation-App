import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievements_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAchievements();
    });
  }

  Future<void> _loadAchievements() async {
    final achievementsProvider = Provider.of<AchievementsProvider>(
      context,
      listen: false,
    );

    try {
      // Force reload achievements when entering screen
      await achievementsProvider.loadAwardedAchievements();
      await achievementsProvider.calculateAchievements();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementsProvider = Provider.of<AchievementsProvider>(context);
    final achievements = achievementsProvider.achievements;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text('Achievements',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/secondary.jpg', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: achievements
                  .map((achievement) => _buildAchievementCard(achievement))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isCompleted = achievement.progress >= 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.white.withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      achievement.iconPath,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 10,
                    color: Colors.green[700],
                    backgroundColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${achievement.xp} XP',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 46, 125, 55)),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

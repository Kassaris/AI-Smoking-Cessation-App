import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/providers/achievements_provider.dart';
import 'package:smoking_app/providers/notification_provider.dart';
import 'package:smoking_app/providers/user_provider.dart';

class RestartScreen extends StatelessWidget {
  const RestartScreen({super.key});

  Future<void> _restartApp(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    final user = userProvider.user;
    if (user != null) {
      await notificationProvider
          .resetScheduledNotifications(user); // 🔔 Reset notifications
    }
    await Provider.of<AchievementsProvider>(context, listen: false)
        .resetAchievements();

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/first_time_login',
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Restart Progress',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/secondary.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: Center(
              child: FractionallySizedBox(
                widthFactor:
                    0.85, // 85% of screen width (adjust to your liking)
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Restart Progress',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800])),
                      const SizedBox(height: 20),
                      const Text(
                        'Restarting your progress will reset your data and redirect you to answer a questionnaire. Your progress will be lost.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _restartApp(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Restart Now',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
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

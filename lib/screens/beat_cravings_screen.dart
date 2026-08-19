import 'package:flutter/material.dart';
import 'package:smoking_app/screens/daily_tips.dart';
import 'package:smoking_app/screens/games_screen.dart';
import 'package:smoking_app/screens/breathing_techniques.dart';
import '../widgets/action_card.dart';

class BeatCravingsScreen extends StatelessWidget {
  const BeatCravingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Beat Cravings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/secondary.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Main content with transparency effect
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                ActionCard(
                  title: 'Daily Tips',
                  description: 'Get practical tips to manage cravings today.',
                  icon: Icons.lightbulb,
                  imagePath: 'assets/images/idea.jpg',
                  destinationScreen:
                      const DailyTipsScreen(), // 👈 Navigate to any screen here!
                ),
                const SizedBox(height: 17),

                ActionCard(
                  title: 'Breathing Techniques',
                  description: 'Follow guided breathing exercises.',
                  icon: Icons.self_improvement,
                  imagePath: 'assets/images/lungs.jpg',
                  destinationScreen:
                      const BreathingTechniquesScreen(), // Different destination
                ),
                const SizedBox(height: 16),

                ActionCard(
                  title: 'Mini Games',
                  description: 'Distract yourself with fun mini games.',
                  icon: Icons.videogame_asset,
                  imagePath: 'assets/images/tetris.jpg',
                  destinationScreen: const GamesScreen(),
                ),

                // const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

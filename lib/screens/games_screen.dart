import 'package:flutter/material.dart';
import 'package:smoking_app/mini_games/flappy_bird/homepage.dart';
import 'package:smoking_app/mini_games/snake_game.dart';
import '../mini_games/pacman/homepage.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Mini Games',
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
              'assets/images/2.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Main content with transparency effect
          SingleChildScrollView(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                buildActionCard(
                  context: context,
                  title: 'pacman',
                  imagePath: 'assets/images/pac.jpg',
                  destinationScreen:
                      HomePagePac(), // 👈 Navigate to any screen here!
                ),
                const SizedBox(height: 20),
                buildActionCard(
                  context: context,
                  title: 'Snake',
                  imagePath: 'assets/images/snake.jpg',
                  destinationScreen: SnakeGame(), // Different destination
                ),
                const SizedBox(height: 20),
                buildActionCard(
                  context: context,
                  title: 'Flappy Bird',
                  imagePath: 'assets/images/flappy.jpg',
                  destinationScreen: FlappyBird(),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Widget destinationScreen, // <== The target screen to navigate to
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(1),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 46, 126, 50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smoking_app/screens/breathing_screen1.dart';
import 'package:smoking_app/screens/breathing_screen2.dart';
import 'package:smoking_app/screens/breathing_screen3.dart';
import 'package:smoking_app/screens/breathing_screen4.dart';

class BreathingTechniquesScreen extends StatelessWidget {
  const BreathingTechniquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Breathing Instructions',
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
                buildActionCard(
                  context: context,
                  title: '4-7-8 Breathing',
                  description:
                      'Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds.',
                  benefits:
                      'Promotes relaxation and helps curb cravings by regulating oxygen levels and inducing a calming effect.',
                  icon: Icons.timer_outlined,
                  destinationScreen:
                      const BreathingScreen1(), // 👈 Navigate to any screen here!
                ),
                const SizedBox(height: 17),

                buildActionCard(
                  context: context,
                  title: 'Box Breathing',
                  description:
                      'Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds.',
                  benefits:
                      'Calms the mind and improves focus, making it great for high-pressure situations.',
                  icon: Icons.filter_4,
                  destinationScreen:
                      const BreathingScreen2(), // Different destination
                ),
                const SizedBox(height: 16),

                buildActionCard(
                  context: context,
                  title: 'Pursed-Lips Breathing',
                  description:
                      'Inhale through the nose, then exhale slowly through pursed lips for twice as long as the inhale.',
                  benefits:
                      'Helps reduce stress and manage cravings by slowing down the breathing rate.',
                  icon: Icons.hourglass_top,
                  destinationScreen: const BreathingScreen3(),
                ),

                const SizedBox(height: 16),

                buildActionCard(
                  context: context,
                  title: 'Diaphragmatic Breathing',
                  description:
                      'Breathe deeply through the nose, allowing the abdomen to rise, then exhale slowly through the mouth.',
                  benefits:
                      'Reduces anxiety and cortisol levels by focusing on slow, abdominal breaths.',
                  icon: Icons.air,
                  destinationScreen: const BreathingScreen4(),
                ),

                // const SizedBox(height: 20),
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
    required String description,
    required String benefits,
    required IconData icon,
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
                  Icon(
                    icon,
                    color: Colors.green[800],
                    size: 28,
                  ),
                  const SizedBox(width: 8),
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
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                benefits,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

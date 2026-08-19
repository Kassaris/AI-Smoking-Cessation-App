import 'package:flutter/material.dart';
import 'login_signup_screen.dart'; // Adjust import path to your project

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/god4.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => _goToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Quit Now',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

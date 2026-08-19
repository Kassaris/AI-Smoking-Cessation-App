import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:smoking_app/services/mock_data_service.dart';
import 'first_time_login_screen.dart';
//import '../services/mock_data_service.dart'; // Import your questionnaire screen

class WelcomeScreen extends StatefulWidget {
  final String username; // Pass user's name
  WelcomeScreen({super.key, required this.username});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<String> motivationalPhrases = [
    "Every journey begins with a single step.",
    "You're stronger than any craving.",
    "Today, you take control of your health.",
    "Your smoke-free life starts here!"
        "Before we begin, we need a few details to personalize your experience.\nThis helps us track your progress and motivate you effectively."
  ];

  int currentPhraseIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _startPhraseRotation();

    // Auto navigate to questionnaire after 6 seconds
    Timer(const Duration(seconds: 20), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstTimeLoginScreen()),
      );
    });
  }

  Timer? _phraseTimer;

  void _startPhraseRotation() {
    _phraseTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (currentPhraseIndex < motivationalPhrases.length - 1) {
        setState(() {
          currentPhraseIndex++;
        });
        _controller.forward(from: 0);
      } else {
        timer.cancel();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/images/god4.png', fit: BoxFit.cover)),
          //ColoredBox(color: const Color.fromARGB(255, 231, 229, 193))),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 46, 125, 55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Welcome, ${widget.username}!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Text(
                        motivationalPhrases[currentPhraseIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dynaPuff(
                          // Change 'poppins' to any font you like
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      ' ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

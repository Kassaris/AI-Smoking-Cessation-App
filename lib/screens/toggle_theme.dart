import 'package:flutter/material.dart';

class ThemeToggleScreen extends StatefulWidget {
  const ThemeToggleScreen({super.key});

  @override
  State<ThemeToggleScreen> createState() => _ThemeToggleScreenState();
}

class _ThemeToggleScreenState extends State<ThemeToggleScreen> {
  bool isDarkMode = false; // Mock state for theme toggle

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });

    // TODO: Implement actual theme switching logic in your app state.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Theme Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/secondary.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent white overlay
          Container(
            color: Colors.white.withOpacity(0.8),
          ),
          // Main content
          Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'App Theme',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 46, 125, 55),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Toggle between Light and Dark mode for better comfort.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      value: isDarkMode,
                      onChanged: _toggleTheme,
                      activeColor: const Color.fromARGB(255, 46, 125, 55),
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
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

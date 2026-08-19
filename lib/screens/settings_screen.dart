import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/providers/auth_provider.dart' as my_auth;
import 'package:smoking_app/screens/account_info_screen.dart';
import 'package:smoking_app/screens/contact_us.dart';
import 'package:smoking_app/screens/delete_account.dart';
import 'package:smoking_app/screens/login_signup_screen.dart';
import 'package:smoking_app/screens/rate_us.dart';
import 'package:smoking_app/screens/restart.dart';
import 'package:smoking_app/screens/terms.dart';
import 'package:smoking_app/screens/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:smoking_app/screens/toggle_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool vibrationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Settings',
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
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Account Info',
                  description: 'View and edit your account details.',
                  icon: Icons.person,
                  destinationScreen:
                      const AccountInfoScreen(), // Different destination
                ),
                /* const SizedBox(height: 20),
                _buildSwitchSettingsCard(
                  context,
                  title: 'Toggle Theme',
                  description: 'Switch between Light and Dark mode.',
                  icon: Icons.brightness_6,
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                      // TODO: Add theme toggle logic
                    });
                  },
                ),*/
                const SizedBox(height: 20),
                _buildNotificationCard(
                  context,
                  title: 'Notifications',
                  description: 'Manage your notifications.',
                  icon: Icons.notifications,
                ),
                /* const SizedBox(height: 20),
                _buildSwitchSettingsCard(
                  context,
                  title: 'Vibrations',
                  description: 'Allow vibrations.',
                  icon: Icons.vibration,
                  value: vibrationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      vibrationsEnabled = value;
                    });
                  },
                ),*/
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Contact Us',
                  description:
                      'We are open to hear your feedback on the app and help you overcome your addiction',
                  icon: Icons.phone,
                  destinationScreen:
                      const ContactUsScreen(), // Different destination
                ),
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Rate Us',
                  description:
                      'Rate your experience on the app. Did we help you?',
                  icon: Icons.star,
                  destinationScreen:
                      const RateUsScreen(), // Different destination
                ),
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Terms & Privacy',
                  description: 'Read our Terms of Service & Privacy Policy.',
                  icon: Icons.article,
                  destinationScreen:
                      const TermsAndPrivacyScreen(), // Different destination
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                  ),
                  onPressed: () {
                    showLogoutDialog(context, () {
                      // Your logout logic here
                      Navigator.of(context).pushReplacementNamed('/login');
                    });
                  },
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 28, color: Colors.green[800]),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Restart',
                  description: 'Have you relapsed? Restart your progress.',
                  icon: Icons.restart_alt,
                  destinationScreen:
                      const RestartScreen(), // Different destination
                ),
                const SizedBox(height: 20),
                _buildSettingsCard(
                  context,
                  title: 'Delete Account',
                  description: 'Permanently delete your account.',
                  icon: Icons.delete,
                  destinationScreen:
                      const DeleteAccountScreen(), // Different destination
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Widget destinationScreen,
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
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.green[800],
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 46, 125, 55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildNotificationCard(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _openAppNotificationSettings(),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.green[800],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 46, 125, 55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}

// Add this function to open notification settings
Future<void> _openAppNotificationSettings() async {
  if (!Platform.isAndroid) {
    // iOS handling
    if (await canLaunch('app-settings:')) {
      await launch('app-settings:');
    }
    return;
  }

  try {
    // Method 1: Modern Android (8.0+)
    const intent1 = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      data: 'package:com.example.smoking_app', // Replace with your package name
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent1.launch();
  } catch (e) {
    print('Method 1 failed: $e');
    try {
      // Method 2: Alternative approach
      const intent2 = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        // For newer Android versions, we can use putExtra directly in the data string
        data:
            'package:com.example.smoking_app;app_package=com.example.smoking_app',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent2.launch();
    } catch (e) {
      print('Method 2 failed: $e');
      try {
        // Method 3: Fallback to app info
        const intent3 = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.example.smoking_app',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent3.launch();
      } catch (e) {
        print('All methods failed: $e');
      }
    }
  }
}

Widget _buildSwitchSettingsCard(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Material(
    color: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green[800],
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 46, 125, 55),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green[800],
          ),
        ],
      ),
    ),
  );
}

Future<void> showLogoutDialog(
    BuildContext context, VoidCallback onLogoutConfirmed) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.green[800]),
            ),
            onPressed: () => Navigator.of(context).pop(), // Close dialog
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog

              // Sign out via your AuthProvider
              await Provider.of<my_auth.AuthProvider>(context, listen: false)
                  .signOut();

              // Navigate to LoginScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const StartingScreen()),
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

/*void _showConfirmDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title confirmed')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}*/

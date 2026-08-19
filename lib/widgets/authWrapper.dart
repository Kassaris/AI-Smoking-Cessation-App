import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'package:smoking_app/providers/auth_provider.dart' as my_auth;
import 'package:smoking_app/providers/user_provider.dart';
import 'package:smoking_app/screens/demo.dart';
import 'package:smoking_app/screens/first_time_login_screen.dart';
import 'package:smoking_app/screens/home_screen.dart';
import 'package:smoking_app/screens/login_signup_screen.dart';
import 'package:smoking_app/screens/welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loadingUserData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserData();
    });
  }

// Remove didChangeDependencies entirely

  Future<void> _checkUserData() async {
    final authProvider =
        Provider.of<my_auth.AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final fb_auth.User? firebaseUser = authProvider.user;

    if (firebaseUser == null) {
      // No user logged in, no need to load user data
      setState(() {
        _loadingUserData = false;
      });
      return;
    }

    try {
      // Load user data from Firestore (including questionnaireCompleted)
      await userProvider.loadUserByEmailOrCreate(firebaseUser);
      //print('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB');
    } catch (e) {
      // handle errors if needed
    } finally {
      if (mounted) {
        setState(() {
          _loadingUserData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (_loadingUserData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user == null) {
      // Not logged in → show login/signup screen
      return const StartingScreen();
    }

    // Logged in but user data not loaded yet (fallback)
    if (userProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if questionnaire completed
    if (userProvider.user!.questionnaireCompleted == true) {
      // Questionnaire done → go Home
      return const HomeScreen();
    } else {
      // Questionnaire not done → show questionnaire screen
      return WelcomeScreen(username: userProvider.user!.username);
    }
  }
}

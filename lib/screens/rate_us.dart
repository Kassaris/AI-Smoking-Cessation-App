import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  double rating1 = 0;
  double rating2 = 0;
  bool hasRated = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasRated();
  }

  Future<void> _checkIfUserHasRated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['hasRated'] == true) {
      setState(() => hasRated = true);
    }
  }

  Future<void> _submitRatings() async {
    if (rating1 == 0 || rating2 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate both questions')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create new rating document
      await FirebaseFirestore.instance.collection('ratings').add({
        'userId': user.uid,
        'functionalityRating': rating1,
        'helpfulnessRating': rating2,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user's hasRated status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'hasRated': true});

      setState(() {
        hasRated = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting ratings: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Rate Us',
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
                widthFactor: 0.85,
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
                  child:
                      hasRated ? _buildThankYouMessage() : _buildRatingForm(),
                ),
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Rate Us',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
        const SizedBox(height: 20),
        const Text(
          'How satisfied are you with the app\'s functionality?',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        _buildStarRating(rating1, (value) {
          setState(() => rating1 = value);
        }),
        const SizedBox(height: 20),
        const Text(
          'How helpful has this app been for your quitting journey?',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        _buildStarRating(rating2, (value) {
          setState(() => rating2 = value);
        }),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _submitRatings,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildThankYouMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 60, color: Colors.green[800]),
        const SizedBox(height: 20),
        Text('Thank You!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
        const SizedBox(height: 10),
        const Text(
          'We appreciate your feedback and will use it to improve the app.\n\nIf you want you can also rate us here:\nLink',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStarRating(
      double currentRating, ValueChanged<double> onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
        );
      }),
    );
  }
}

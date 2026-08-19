import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/providers/daily_tips_provider.dart';
import 'package:smoking_app/screens/chatbot_screen.dart';
import '../services/app_data_service.dart';
import 'dart:ui';

import '../providers/user_provider.dart';

class DailyTipsScreen extends StatefulWidget {
  const DailyTipsScreen({super.key});

  @override
  _DailyTipsScreenState createState() => _DailyTipsScreenState();
}

class _DailyTipsScreenState extends State<DailyTipsScreen> {
  int unlockedTipsCount = 1; // default safe value
  bool _isLoading = true;

  //late List tipsSortedByRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (user != null && user.quitDate != null) {
        final quitDate = user.quitDate!;
        final now = DateTime.now();

        final quitDate1 = quitDate.toDate();
        final quitDateOnly =
            DateTime(quitDate1.year, quitDate1.month, quitDate1.day);
        final nowDateOnly = DateTime(now.year, now.month, now.day);

        final daysDiff = nowDateOnly.difference(quitDateOnly).inDays + 1;

        setState(() {
          unlockedTipsCount =
              daysDiff.clamp(1, MockDataService.cravingsTips.length);
          _isLoading = false;
        });
      } else {
        // fallback if no quit date (e.g., for testing)
        setState(() {
          unlockedTipsCount = 1;
          _isLoading = false;
        });
      }
    });
  }

  void _showTipDialog(String title, String description) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tip Dialog',
      barrierColor: Colors.black.withOpacity(0.2),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Text(description),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatbotScreen(
                          initialMessage: "Why $title, helps manage cravings?",
                        ),
                      ),
                    );
                  },
                  child: const Text("Learn More"),
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a sorted copy of the tips by rating descending
    final tipsProvider = Provider.of<DailyTipsProvider>(context);
    final tipsSortedByRating = tipsProvider.tipsSortedByRating;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/2.jpg', // Update with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Overlaying content
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: tipsSortedByRating.length,
              itemBuilder: (context, index) {
                final tip = tipsSortedByRating[index];
                return _buildTipContainer(tip, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipContainer(Tip tip, int index) {
    bool isUnlocked = index < unlockedTipsCount;
    //final tip = tipsSortedByRating[index];

    return Consumer<DailyTipsProvider>(
      builder: (context, tipsProvider, _) {
        int currentRating = tip.rating;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.grey[400],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(5, 5),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: isUnlocked
                  ? () => _showTipDialog(tip.title, tip.description)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      isUnlocked ? tip.title : 'Come tomorrow to unlock!',
                      style: TextStyle(
                        fontSize: 16,
                        color: isUnlocked ? Colors.black87 : Colors.black,
                        fontWeight:
                            isUnlocked ? FontWeight.normal : FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isUnlocked) const SizedBox(height: 8),
                    if (isUnlocked)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors
                                  .lightGreen[100], // light green background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) {
                                final index = i + 1;
                                final isSelected = tip.rating >= index;
                                return GestureDetector(
                                  onTap: () {
                                    tipsProvider.rateTip(tip.title, index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2), // tighter spacing
                                    child: Icon(
                                      Icons.star,
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.grey,
                                      size:
                                          20, // smaller if you want even more compact
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tap for more',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

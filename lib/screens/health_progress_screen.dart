import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/gradient_progress_bar.dart';
import '../providers/chat_provider.dart';
import '../screens/chatbot_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Wait until the first frame renders to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressList =
          Provider.of<ProgressProvider>(context, listen: false).progressList;
      final firstIncompleteIndex =
          progressList.indexWhere((goal) => goal.progress < 1.0);

      if (firstIncompleteIndex != -1) {
        // Estimate each card height + margin (approx. 160 pixels)
        final scrollOffset = firstIncompleteIndex * 160.0;
        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Progress',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Consumer<ProgressProvider>(
            builder: (context, progressProvider, child) {
              final progressList = progressProvider.progressList;
              return SingleChildScrollView(
                controller: _scrollController, // ✅ attach controller
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: progressList.map((goal) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green.shade700),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              goal.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GradientProgressBar(
                            progress: goal.progress,
                            progressText: '${goal.progressPercent}%',
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              goal.timeLeftStr,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () async {
                                final chatProvider = Provider.of<ChatProvider>(
                                    context,
                                    listen: false);
                                chatProvider.sendMessage(
                                    'Tell me more about ${goal.description}, when quitting smoking',
                                    context,
                                    systemPrompt:
                                        'Give very detailed scientific proven facts about why and how ${goal.description}, when someone quits smoking. Give references about the researched that prove it.');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ChatbotScreen()),
                                );
                              },
                              child: const Text(
                                'Learn more',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

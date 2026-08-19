import 'package:flutter/material.dart';
import 'package:smoking_app/screens/chatbot_screen.dart';
import 'package:smoking_app/screens/global_chat_screen.dart';
import 'package:smoking_app/screens/quitline.dart';
import '../widgets/action_card.dart';

class TalkScreen extends StatelessWidget {
  const TalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Chat',
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
                const SizedBox(height: 20),
                ActionCard(
                  title: 'Chat with psAIcologist',
                  description:
                      'Talk to your AI psycologist, about every smoking-related topic. Get informed and get help.',
                  icon: Icons.psychology,
                  imagePath: 'assets/images/chatBot.jpg',
                  destinationScreen:
                      const ChatbotScreen(), // 👈 Navigate to any screen here!
                ),
                const SizedBox(height: 20),
                ActionCard(
                  title: 'Chat with real people',
                  description:
                      'Chat with other quitters, share your journey and your personal experiences. Give tips and seek motivation.',
                  icon: Icons.person,
                  imagePath: 'assets/images/globalChat.jpg',
                  destinationScreen:
                      const GlobalChatScreen(), // Different destination
                ),
                const SizedBox(height: 20),
                ActionCard(
                  title: 'Talk to an expert',
                  description:
                      'Call a dedicated smoking-addiction quitline and talk to an expert/doctor about your concerns',
                  icon: Icons.sos,
                  imagePath: 'assets/images/doc.jpg',
                  destinationScreen:
                      const QuiLineScreen(), // Different destination
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

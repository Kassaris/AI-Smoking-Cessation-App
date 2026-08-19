import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;

  // ✅ Correct backend URL with route
  final String _backendUrl = 'https://0e5df38788c3.ngrok-free.app/chat/';

  Future<void> sendMessage(String userMessage, BuildContext context,
      {String? systemPrompt}) async {
    _isLoading = true;
    notifyListeners();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;

    if (user == null) {
      _messages.add({
        'role': 'assistant',
        'content': '⚠️ User profile not loaded. Please try again shortly.',
      });
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 👇 Add optional system prompt (invisible)
    if (systemPrompt != null) {
      _messages.add({'role': 'system', 'content': systemPrompt});
    }

    // Add user message
    _messages.add({'role': 'user', 'content': userMessage});

    // Add temporary "thinking" message
    _messages.add({
      'role': 'assistant',
      'content': '🤔 Let me think...',
      'isTemp': 'true',
    });
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(_backendUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': user.id,
              'message': userMessage,
              if (systemPrompt != null) 'system': systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 70));

      _messages.removeWhere((m) => m['isTemp'] == 'true');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final reply =
            responseData['reply'] ?? '🤖 No response content received.';
        _messages.add({'role': 'assistant', 'content': reply});
      } else if (response.statusCode == 503 ||
          response.body.contains("Render")) {
        _messages.add({
          'role': 'assistant',
          'content':
              '🛌 The chatbot server may be waking up. Please wait a moment and try again.',
        });
      } else {
        _messages.add({
          'role': 'assistant',
          'content': '❌ Failed to get a valid response from the chatbot.',
        });
      }
    } catch (e) {
      _messages.removeWhere((m) => m['isTemp'] == 'true');
      _messages.add({
        'role': 'assistant',
        'content': '⚠️ An error occurred while communicating with the chatbot.',
      });
      debugPrint('❌ Chat error: $e');

      if (e is http.ClientException) {
        debugPrint('📡 ClientException: ${e.message}');
      } else if (e is FormatException) {
        debugPrint('🧩 JSON decoding failed: ${e.message}');
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
  final String? initialMessage;
  final String? systemMessage;

  const ChatbotScreen({super.key, this.initialMessage, this.systemMessage});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMessage != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.sendMessage(widget.initialMessage!, context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final visibleMessages =
        chatProvider.messages.where((msg) => msg['role'] != 'system').toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CigAI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: visibleMessages.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final msg = visibleMessages[index];
                  final isUser = msg['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: isUser
                          ? Text(
                              msg['content']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          : MarkdownBody(
                              data: msg['content']!,
                              onTapLink: (text, href, title) async {
                                if (href != null) {
                                  final url = Uri.parse(href);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                }
                              },
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                strong: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                em: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                listBullet: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                h1: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                h3: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                blockquote: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            //if (chatProvider.isLoading)
            //const Padding(
            //padding: EdgeInsets.all(8.0),
            //child: CircularProgressIndicator(),
            //),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      cursorColor: Colors.green.shade800,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a message',
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(color: Colors.green.shade800),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide(
                              color: Colors.green.shade800, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final msg = _controller.text.trim();
                      if (msg.isNotEmpty) {
                        chatProvider.sendMessage(msg, context);
                        _controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

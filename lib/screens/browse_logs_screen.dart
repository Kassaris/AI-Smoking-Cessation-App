import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BrowseCravingLogsScreen extends StatelessWidget {
  const BrowseCravingLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // allows background image behind appbar
      appBar: AppBar(
        title: const Text(
          'Community Logs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[800]?.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          /// Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/secondary.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3), // dark overlay
              ),
            ),
          ),

          /// Foreground content
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('craving_logs')
                  .orderBy('timestamp', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No logs found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final logs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    final intensity = log['intensity'] ?? 'Unknown';
                    final trigger = log['trigger'] ?? '-';
                    final copingMethod = log['coping_method'] ?? '-';
                    final description = log['description'] ?? '-';
                    final timestamp = log['timestamp']?.toDate();
                    final dateString = timestamp != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
                        : 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.85),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Intensity: ',
                                    style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: intensity),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Trigger: ',
                                    style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: trigger),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Coping Method: ',
                                    style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: copingMethod),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: 'Description:',
                                    style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: description),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              dateString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

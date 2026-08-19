import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).user?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Craving Logs',
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
        actions: [
          Transform.translate(
            offset: const Offset(-15, 0),
            child: IconButton(
              icon: const Icon(Icons.add, size: 32),
              color: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/addDocs'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/secondary.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          // Logs content
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('craving_logs')
                .where('userId', isEqualTo: userId)
                //.orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No logs found.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              final logs = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.all(15),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListTile(
                      title: Text(
                        '${log['intensity'] ?? 'N/A'}',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Trigger: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: log['trigger'] ?? 'N/A'),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Coping: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: log['coping_method'] ?? 'N/A'),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Description: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: log['description'] ?? 'N/A'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log['timestamp'] != null
                                ? DateFormat('yyyy-MM-dd HH:mm')
                                    .format(log['timestamp'].toDate())
                                : 'Unknown',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CravingLogsBrowse extends StatelessWidget {
  const CravingLogsBrowse({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Community Logs',
          style:
              TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        height: 500, // Adjust height as needed
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('craving_logs')
              .orderBy('timestamp', descending: true)
              .limit(100) // Adjust if needed
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No logs found.');
            }

            final logs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final timestamp = log['timestamp']?.toDate();
                final dateString = timestamp != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
                    : 'Unknown';

                final intensity = log['intensity'] ?? 'Unknown';
                final trigger = log['trigger'] ?? '-';
                final copingMethod = log['coping_method'] ?? '-';
                final description = log['description'] ?? '-';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' $dateString',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ' Intensity: $intensity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(' Trigger: $trigger'),
                        Text(' Coping Method: $copingMethod'),
                        const SizedBox(height: 6),
                        Text(
                          ' Description:\n$description',
                          style: const TextStyle(color: Colors.black87),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

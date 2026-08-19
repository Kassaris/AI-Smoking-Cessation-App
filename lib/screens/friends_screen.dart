import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/services/firestore_service.dart';
import '../providers/user_provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userId = user?.id;

    String tagText = (user?.socialTag ?? '0000') == '0000'
        ? 'Create a Tag'
        : '# ${user?.socialTag}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              icon: const Icon(Icons.person_add, size: 32),
              color: Colors.white,
              onPressed: () => _showAddFriendDialog(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateTagDialog(context),
              label: Text(tagText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final friendsList =
                  List<String>.from(userData['friendsList'] ?? []);

              if (friendsList.isEmpty) {
                return const Center(
                  child: Text(
                    'No friends added yet.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where(FieldPath.documentId, whereIn: friendsList)
                    .snapshots(),
                builder: (context, friendsSnapshot) {
                  if (!friendsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final friends = friendsSnapshot.data!.docs;

                  return Column(
                    children: [
                      const SizedBox(height: 50),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            final data = friend.data() as Map<String, dynamic>;

                            final username = data['username'] ?? 'Unknown';
                            final rank = data['userRank'] ?? 0;
                            final quitDate =
                                (data['quitDate'] as Timestamp?)?.toDate();
                            final cigsPerDay = data['cigarettesPerDay'] ?? 0;
                            final costPerPack = data['costPerPack'] ?? 0;
                            final cigsPerPack = data['cigarettesPerPack'] ?? 20;

                            String smokeFreeTime = 'N/A';
                            String moneySaved = 'N/A';

                            if (quitDate != null) {
                              final days =
                                  DateTime.now().difference(quitDate).inDays;
                              smokeFreeTime = '$days days';

                              final packsPerDay = cigsPerDay == 0
                                  ? 0
                                  : cigsPerDay / cigsPerPack;
                              final totalSaved =
                                  packsPerDay * costPerPack * days;
                              moneySaved = '€${totalSaved.toStringAsFixed(2)}';
                            }

                            return Card(
                              color: Colors.green[800]?.withOpacity(0.85),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.person,
                                    color: Colors.white),
                                title: Text(
                                  username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Rank: $rank\nSmoke-Free: $smokeFreeTime\nMoney Saved: $moneySaved',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final TextEditingController _tagController = TextEditingController();
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Create Tag",
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _tagController,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: 'Enter 4 Characters',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final tag = _tagController.text.trim();
                if (tag.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tag must be exactly 4 characters"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (userId == null) throw Exception("No user loaded");

                  await FirestoreService().updateUserTag(userId, tag);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tag updated successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to update tag: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}

void _showAddFriendDialog(BuildContext context) {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final currentUser = Provider.of<UserProvider>(context, listen: false).user;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Add Friend',
          style:
              TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Social Tag',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = _usernameController.text.trim();
              final tag = _tagController.text.trim();

              if (username.isEmpty || tag.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill both fields')),
                );
                return;
              }

              try {
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: username)
                    .where('socialTag', isEqualTo: tag)
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not found')),
                  );
                  return;
                }

                final matchedUserDoc = querySnapshot.docs.first;
                final matchedUserId = matchedUserDoc.id;

                if (matchedUserId == currentUser?.id) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You cannot add yourself')),
                  );
                  return;
                }

                final currentUserRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.id);
                final matchedUserRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(matchedUserId);

                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {
                  transaction.update(currentUserRef, {
                    'friendsList': FieldValue.arrayUnion([matchedUserId])
                  });
                  transaction.update(matchedUserRef, {
                    'friendsList': FieldValue.arrayUnion([currentUser!.id])
                  });
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You and $username#$tag are now friends!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          )
        ],
      );
    },
  );
}

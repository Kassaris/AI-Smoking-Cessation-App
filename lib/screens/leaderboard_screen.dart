import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/models/user_model.dart';
import 'package:smoking_app/providers/leaderboard_provider.dart';
import 'package:smoking_app/providers/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final leaderboardProvider =
          Provider.of<LeaderboardProvider>(context, listen: false);
      leaderboardProvider.loadLeaderboard(userProvider.user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    final users = leaderboardProvider.topUsers;
    final currentUserId = currentUser?.id;
    final currentUserInList = users.any((u) => u.id == currentUserId);
    final showCurrentUser = currentUser != null && !currentUserInList;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/secondary.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                child: leaderboardProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async {
                          await leaderboardProvider
                              .loadLeaderboard(currentUser!);
                        },
                        child: Column(
                          children: [
                            Text(
                              'Top Quitters (≤ 40 days)',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800]),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView(
                                children: [
                                  ...users.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final user = entry.value;
                                    final isCurrentUser =
                                        user.id == currentUserId;
                                    return _buildLeaderboardTile(
                                        user, index + 1, isCurrentUser);
                                  }).toList(),
                                  if (showCurrentUser && currentUser != null)
                                    Column(
                                      children: [
                                        const Divider(
                                          thickness: 2,
                                          color: Colors.green,
                                        ),
                                        _buildLeaderboardTile(
                                            currentUser,
                                            leaderboardProvider.allUsers
                                                    .indexWhere((u) =>
                                                        u.id ==
                                                        currentUser.id) +
                                                1,
                                            true),
                                      ],
                                    ),
                                  if (users.isEmpty)
                                    const Text(
                                      'No users under 40 days.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(
      UserModel user, int displayRank, bool isCurrentUser) {
    return Card(
      color: isCurrentUser ? Colors.green[100] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isCurrentUser ? Colors.green[800] : Colors.green[400],
          child: Text(
            '$displayRank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            //Image.asset(
            //'assets/images/icon2.png',
            // width: 24,
            // height: 24,
            //),
          ],
        ),
        subtitle: Text(
            '${user.smokeFreeDays} smoke-free days - Lvl ${user.userRank}'),
      ),
    );
  }
}

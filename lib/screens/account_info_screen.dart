import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Account Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/secondary.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay for blur effect
          Container(
            color: Colors.white.withOpacity(0.8),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: kToolbarHeight + 20),
                      _buildInfoRow('Username', user.username),
                      _buildInfoRow('Email', user.email),
                      _buildInfoRow('Gender', user.gender),
                      _buildInfoRow('Quit Date',
                          '${user.quitDate.toDate()}'.split(' ')[0]),
                      _buildInfoRow(
                          'Cigarettes per Day', '${user.cigarettesPerDay}'),
                      _buildInfoRow(
                          'Smoking Years', '${user.smokingYears} years'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

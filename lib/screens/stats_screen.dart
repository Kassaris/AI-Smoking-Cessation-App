import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Statistics',
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
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kToolbarHeight + 20),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Money Saved',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow(
                            'Per Day',
                            userProvider
                                .calculateMoneyPerDay()
                                .toStringAsFixed(2)),
                        _buildInfoRow(
                            'Per Month',
                            (userProvider.calculateMoneyPerDay() * 30)
                                .toStringAsFixed(2)),
                        _buildInfoRow(
                            'Per Year',
                            (userProvider.calculateMoneyPerDay() * 365)
                                .toStringAsFixed(2)),
                        _buildInfoRow(
                            'Spent So far',
                            (userProvider.calculateMoneyPerDay() *
                                    365 *
                                    userProvider.smokingYears)
                                .toStringAsFixed(2)),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 75, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Cigarettes Avoided',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow('Per Day',
                            userProvider.cigarettesPerDay.toString()),
                        _buildInfoRow('Per Month',
                            (userProvider.cigarettesPerDay * 30).toString()),
                        _buildInfoRow('Per Year',
                            (userProvider.cigarettesPerDay * 365).toString()),
                        _buildInfoRow(
                            'Smoked So far',
                            (userProvider.cigarettesPerDay *
                                    365 *
                                    userProvider.smokingYears)
                                .toString()),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 110, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green[800],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'Life Gained',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow('Per Day',
                            (userProvider.cigarettesPerDay * 11).toString()),
                        _buildInfoRow(
                            'Per Month',
                            (userProvider.cigarettesPerDay * 30 * 11)
                                .toString()),
                        _buildInfoRow(
                            'Per Year',
                            (userProvider.cigarettesPerDay * 365 * 11)
                                .toString()),
                        _buildInfoRow(
                            'Lost So far',
                            (userProvider.cigarettesPerDay *
                                    365 *
                                    11 *
                                    userProvider.smokingYears)
                                .toString()),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

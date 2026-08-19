import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../providers/progress_provider.dart';
import 'gradient_progress_bar.dart';

class HealthProgressSection extends StatelessWidget {
  const HealthProgressSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final progressList = progressProvider.progressList;

    // Take top 3 incomplete goals based on progress < 1
    final topGoals = progressList
        .where((progress) => progress.progress < 1.0)
        .toList()
      ..sort((b, a) => a.progressPercent.compareTo(b.progressPercent));
    final displayedGoals = topGoals.take(3);

    return Column(
      children: displayedGoals.map((goal) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/progress'),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.green.shade800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    goal.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                GradientProgressBar(
                  progress: goal.progress,
                  progressText: '${goal.progressPercent}%',
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    goal.timeLeftStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

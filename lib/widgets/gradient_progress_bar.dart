import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double progress; // Value from 0.0 to 1.0
  final String progressText;

  const GradientProgressBar({
    super.key,
    required this.progress,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 550),
      builder: (context, animatedValue, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedValue,
                  child: Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              progressText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}

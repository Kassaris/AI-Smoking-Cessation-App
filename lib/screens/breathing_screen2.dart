import 'package:flutter/material.dart';
import '../widgets/breathing_exercise.dart'; // path to the widget file

class BreathingScreen2 extends StatelessWidget {
  const BreathingScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text(
          'Breathing Exercise',
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
      ),
      body: Center(
        child: BreathingExerciseWidget(
          phaseDurations: [4, 4, 4, 4], // durations in seconds
          // optional: customize labels and colors
          // phaseLabels: ['Breathe In', 'Hold', 'Breathe Out', 'Hold'],
          // phaseColors: [Colors.green, Colors.blue, Colors.red, Colors.blue],
        ),
      ),
    );
  }
}

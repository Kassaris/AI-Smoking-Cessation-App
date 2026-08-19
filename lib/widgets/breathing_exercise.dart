import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class BreathingExerciseWidget extends StatefulWidget {
  /// List of durations in seconds for each phase
  final List<int> phaseDurations;

  /// Optional: Labels for each phase (defaults to Inhale, Hold, Exhale, Hold)
  final List<String>? phaseLabels;

  /// Optional: Colors for each phase (defaults to green, blue, red, blue)
  final List<Color>? phaseColors;

  const BreathingExerciseWidget({
    Key? key,
    required this.phaseDurations,
    this.phaseLabels,
    this.phaseColors,
  })  : assert(phaseDurations.length > 0),
        super(key: key);

  @override
  State<BreathingExerciseWidget> createState() =>
      _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget>
    with TickerProviderStateMixin {
  late final List<_BreathingPhase> _phases;

  final player = AudioPlayer();

  int _currentPhase = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _countdown = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    // Build _phases list from input or defaults
    final labels = widget.phaseLabels ?? ['Inhale', 'Hold', 'Exhale', 'Hold'];
    final colors = widget.phaseColors ??
        [Colors.green, Colors.blue, Colors.red, Colors.blue];

    _phases = List.generate(
      widget.phaseDurations.length,
      (index) => _BreathingPhase(
        labels[index % labels.length],
        widget.phaseDurations[index],
        colors[index % colors.length],
      ),
    );

    _setupController();
  }

  void _setupController() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phases[_currentPhase].duration),
    );

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isRunning) {
        _nextPhase();
      }
    });
  }

  void _startBreathing() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _currentPhase = 0;
    });

    _startPhase();
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
    });

    _controller.stop();
    _timer?.cancel();
  }

  void _startPhase() {
    final phase = _phases[_currentPhase];
    _countdown = phase.duration;

    _controller.duration = Duration(seconds: phase.duration);
    _controller.forward(from: 0.0);

    _playBeep();
    _vibrate();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        }
      });
    });
  }

  void _nextPhase() {
    _timer?.cancel();
    setState(() {
      _currentPhase = (_currentPhase + 1) % _phases.length;
    });
    _startPhase();
  }

  Future<void> _playBeep() async {
    await player.play(AssetSource('audios/beep.mp3'));
  }

  Future<void> _vibrate() async {
    try {
      final canVibrate = await Vibration.hasVibrator();
      if (canVibrate == true) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _phases[_currentPhase];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Follow the on-screen instructions.\nYou can close your eyes for further focus.\nChange according to sounds/vibrations',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 50),
        Text(
          current.label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: current.color,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isRunning ? '$_countdown' : '--',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: current.color,
          ),
        ),
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current.color.withOpacity(0.5),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startBreathing,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: _stopBreathing,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BreathingPhase {
  final String label;
  final int duration;
  final Color color;

  _BreathingPhase(this.label, this.duration, this.color);
}

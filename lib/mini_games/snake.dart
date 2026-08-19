import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:ui';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame>
    with SingleTickerProviderStateMixin {
  static const double segmentSize = 10.0;
  static const Duration baseTickRate = Duration(milliseconds: 30);
  late AnimationController _gameOverController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<Offset> snake = [const Offset(200, 200)];
  Offset food = const Offset(100, 100);
  Offset? badFood;
  Offset direction = const Offset(0, -1);
  Timer? timer;
  bool gameOver = false;
  bool paused = false;
  late Size screenSize;
  int score = 0;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenSize = MediaQuery.of(context).size;
      startGame();
    });
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _gameOverController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _gameOverController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void startGame() {
    timer = Timer.periodic(baseTickRate, (_) => updateGame());
  }

  void updateGame() {
    if (gameOver || paused) return;

    setState(() {
      final newHead = snake.first + direction * 2.0;

      if (_isOutOfBounds(newHead)) {
        triggerVibration();
        gameOver = true;
        _gameOverController.forward(from: 0);
        timer?.cancel();
        return;
      }

      final ateGoodFood = (newHead - food).distance < segmentSize;
      final ateBadFood =
          badFood != null && (newHead - badFood!).distance < segmentSize;

      if (ateBadFood) {
        triggerVibration();
        gameOver = true;
        _gameOverController.forward(from: 0);
        timer?.cancel();
        return;
      }

      final bodyToCheck =
          ateGoodFood ? snake : snake.sublist(0, snake.length - 1);

      if (bodyToCheck.contains(newHead)) {
        triggerVibration();
        gameOver = true;
        _gameOverController.forward(from: 0);
        timer?.cancel();
        return;
      }

      snake.insert(0, newHead);

      if (!ateGoodFood) {
        snake.removeLast();
      } else {
        score++;
        triggerVibration();
        spawnFood();
        updateGameSpeed();
      }
    });
  }

  void updateGameSpeed() {
    timer?.cancel();
    int newInterval = max(10, 30 - score);
    timer = Timer.periodic(
        Duration(milliseconds: newInterval), (_) => updateGame());
  }

  bool _isOutOfBounds(Offset head) {
    return head.dx < 0 ||
        head.dx > screenSize.width ||
        head.dy < 0 ||
        head.dy > screenSize.height;
  }

  void spawnFood() {
    food = Offset(
      random.nextDouble() * (screenSize.width - segmentSize),
      random.nextDouble() * (screenSize.height - segmentSize),
    );

    if (random.nextDouble() < 0.3) {
      badFood = Offset(
        random.nextDouble() * (screenSize.width - segmentSize),
        random.nextDouble() * (screenSize.height - segmentSize),
      );
    } else {
      badFood = null;
    }
  }

  void changeDirection(String newDirection) {
    final newDir = switch (newDirection) {
      'up' => const Offset(0, -1),
      'down' => const Offset(0, 1),
      'left' => const Offset(-1, 0),
      'right' => const Offset(1, 0),
      _ => direction
    };

    if ((direction + newDir).distance != 0) {
      direction = newDir;
    }
  }

  void resetGame() {
    setState(() {
      snake = [const Offset(200, 200)];
      food = const Offset(100, 100);
      badFood = null;
      direction = const Offset(0, -1);
      gameOver = false;
      score = 0;
      paused = false;
      timer?.cancel();
      startGame();
    });
  }

  void triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    _gameOverController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final Size fullSize = mediaQuery.size;
    final double bottomPanelHeight = 80;
    final double safeTop = mediaQuery.padding.top;
    final double safeBottom = mediaQuery.padding.bottom;

    final double appBarHeight = kToolbarHeight;
    final double gameAreaHeight = fullSize.height -
        safeTop -
        safeBottom -
        appBarHeight -
        bottomPanelHeight;

    screenSize = Size(fullSize.width, gameAreaHeight);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 125, 55),
        title: const Text(
          'Snake',
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: fullSize.width,
                height: gameAreaHeight,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < 0) {
                      changeDirection('up');
                    } else if (details.primaryDelta! > 0) {
                      changeDirection('down');
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! < 0) {
                      changeDirection('left');
                    } else if (details.primaryDelta! > 0) {
                      changeDirection('right');
                    }
                  },
                  child: CustomPaint(
                    painter: SnakePainter(
                      snake: snake,
                      food: food,
                      badFood: badFood,
                      segmentSize: segmentSize,
                    ),
                  ),
                ),
              ),
              Container(
                height: bottomPanelHeight,
                width: double.infinity,
                color: Colors.green[800],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Score: $score',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white),
                      onPressed: () {
                        setState(() {
                          paused = !paused;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (gameOver)
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Game Over',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Score: $score',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Restart',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final Offset? badFood;
  final double segmentSize;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.badFood,
    required this.segmentSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()..color = Colors.green;
    final foodPaint = Paint()..color = Colors.blue;
    final badFoodPaint = Paint()..color = Colors.red;

    for (final segment in snake) {
      canvas.drawCircle(segment, segmentSize / 1, snakePaint);
    }

    canvas.drawCircle(food, segmentSize / 1, foodPaint);
    if (badFood != null) {
      canvas.drawCircle(badFood!, segmentSize / 1, badFoodPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

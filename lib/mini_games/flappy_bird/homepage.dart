import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smoking_app/screens/games_screen.dart';
import 'barrier.dart';
import 'bird.dart';

class FlappyBird extends StatefulWidget {
  const FlappyBird({super.key});

  @override
  State<FlappyBird> createState() => _FlappyBirdState();
}

class _FlappyBirdState extends State<FlappyBird> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameStarted = false;
  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 2.0;
  int score = 0;
  int bestScore = 0;

  // Barrier dimensions
  final double barrierWidth = 0.5;
  final double topBarrierHeight = 0.4; // Relative to screen height
  final double bottomBarrierHeight = 0.6; // Relative to screen height
  final double gapSize = 0.3; // Space between top and bottom barriers

  void _showDialogBox() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Game Over",
                style: TextStyle(color: Colors.black),
              ),
            ),
            content: Text(
              "Score: $score",
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GamesScreen()),
                  );
                },
                //offset: const Offset(15, 0),
                child: ClipRRect(
                  //borderRadius: BorderRadius.circular(5),
                  child: Container(
                      padding: EdgeInsets.only(left: 0, right: 70),
                      child: Text(
                        "exit",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 46, 125, 55)),
                      )
                      //color: Colors.white,
                      ),
                ),
              ),
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.only(left: 0, right: 20),

                    child: Text(
                      "Play Again",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 46, 125, 55)),
                    ),
                    //padding: EdgeInsets.all(7),
                    //color: Colors.white,
                  ),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      birdYaxis = 0;
      gameStarted = false;
      time = 0;
      initialHeight = birdYaxis;
      barrierXone = 1;
      barrierXtwo = barrierXone + 2.0;
      score = 0;
    });
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      time += 0.05;
      height = -4.9 * time * time + (2.8 * time);
      setState(() {
        birdYaxis = initialHeight - height;
      });

      // Move barriers
      setState(() {
        if (barrierXone < -1.5) {
          barrierXone += 4;
          score++; // Increment score when passing a barrier
          if (score > bestScore) bestScore = score;
        } else {
          barrierXone -= 0.05;
        }
      });

      setState(() {
        if (barrierXtwo < -1.5) {
          barrierXtwo += 4;
          score++; // Increment score when passing a barrier
          if (score > bestScore) bestScore = score;
        } else {
          barrierXtwo -= 0.05;
        }
      });

      if (birdIsDead()) {
        timer.cancel();
        gameStarted = false;
        _showDialogBox();
      }
    });
  }

  bool birdIsDead() {
    // Check if bird is out of bounds (top or bottom of screen)
    if (birdYaxis < -1 || birdYaxis > 1) {
      return true;
    }

    // Check collision with first barrier pair
    if (barrierXone > -barrierWidth && barrierXone < barrierWidth) {
      // Bird is within the x-range of first barrier
      if (birdYaxis < -0.8 + gapSize / 2 || birdYaxis > 0.8 - gapSize / 2) {
        return true;
      }
    }

    // Check collision with second barrier pair
    if (barrierXtwo > -barrierWidth && barrierXtwo < barrierWidth) {
      // Bird is within the x-range of second barrier
      if (birdYaxis < -0.8 + gapSize / 2 || birdYaxis > 0.8 - gapSize / 2) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: Duration(milliseconds: 0),
                    child: Bird1(),
                    color: const Color.fromARGB(255, 174, 199, 219),
                  ),
                  Container(
                    child: gameStarted
                        ? Text(" ")
                        : Text(
                            "Tap to Play",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                    alignment: Alignment(0, -0.3),
                  ),

                  // First barrier pair
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment:
                        Alignment(barrierXone, -1.0 + topBarrierHeight / 2),
                    child: Barrier(
                      barrierHeight: topBarrierHeight,
                      barrierWidth: barrierWidth,
                      BarrierX: barrierXone,
                      isThisBottomBarrier: false,
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment:
                        Alignment(barrierXone, 1.0 - bottomBarrierHeight / 2),
                    child: Barrier(
                      barrierHeight: bottomBarrierHeight,
                      barrierWidth: barrierWidth,
                      BarrierX: barrierXone,
                      isThisBottomBarrier: true,
                    ),
                  ),

                  // Second barrier pair
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment:
                        Alignment(barrierXtwo, -1.0 + topBarrierHeight / 2),
                    child: Barrier(
                      barrierHeight: topBarrierHeight,
                      barrierWidth: barrierWidth,
                      BarrierX: barrierXtwo,
                      isThisBottomBarrier: false,
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment:
                        Alignment(barrierXtwo, 1.0 - bottomBarrierHeight / 2),
                    child: Barrier(
                      barrierHeight: bottomBarrierHeight,
                      barrierWidth: barrierWidth,
                      BarrierX: barrierXtwo,
                      isThisBottomBarrier: true,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.green,
              height: 15,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Score",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          '$score',
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        )
                      ],
                    ),
                    SizedBox(width: 20.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Best",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          "$bestScore",
                          style: TextStyle(color: Colors.white, fontSize: 35),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

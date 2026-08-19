import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
//import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:smoking_app/mini_games/pacman/ghost.dart';
//import 'package:smoking_app/mini_games/pacman/path.dart';
import 'package:smoking_app/mini_games/pacman/pixel.dart';
import 'package:smoking_app/mini_games/pacman/player.dart';

class HomePagePac extends StatefulWidget {
  @override
  State<HomePagePac> createState() => _HomePagePacState();
}

class _HomePagePacState extends State<HomePagePac> {
  int numberInRow = 12;
  static int Squares = 216;
  int score = 0;
  bool start = true;
  bool MouthClosed = false;
  bool paused = false;
  bool poweredUp = false;
  String BigText = "Pac Man";
  String direction = "right";
  int player = 193;
  Timer? gameTimer;

  List<String> normalGhostImages = [
    "assets/images/cig2.png",
    "assets/images/cig2.png",
    "assets/images/cig2.png"
  ];

  List<int?> ghostTimers = [null, null, null];

  List<int> GhostsP = [20, 14, 74];
  List<int> Food = [];
  Set<int> powerDots = {17, 58, 160};

  List<int> br = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    24,
    36,
    48,
    60,
    72,
    84,
    120,
    132,
    23,
    35,
    47,
    59,
    71,
    83,
    95,
    26,
    38,
    50,
    67,
    85,
    86,
    87,
    88,
    91,
    92,
    93,
    94,
    79,
    33,
    45,
    57,
    40,
    41,
    42,
    28,
    62,
    69,
    76,
    64,
    43,
    31,
    131,
    144,
    156,
    168,
    180,
    192,
    204,
    205,
    206,
    207,
    208,
    209,
    210,
    211,
    212,
    213,
    214,
    130,
    129,
    128,
    127,
    124,
    123,
    122,
    121,
    136,
    148,
    139,
    151,
    153,
    165,
    177,
    189,
    146,
    158,
    179,
    182,
    170,
    172,
    173,
    174,
    175,
    187,
    184,
    143,
    155,
    167,
    191,
    203,
    215
  ];

  void getFood() {
    for (int i = 0; i < Squares; i++) {
      if (!br.contains(i)) {
        Food.add(i);
      }
    }
  }

  void StartGame() {
    if (start && gameTimer == null) {
      gameTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
        if (paused) return;

        setState(() {
          MouthClosed = !MouthClosed;
          Ghostmove();

          if (Food.contains(player)) {
            Food.remove(player);
            score++;
          }

          if (powerDots.contains(player)) {
            powerDots.remove(player);
            activatePowerUp();
          }

          if (GhostsP.contains(player)) {
            int index = GhostsP.indexOf(player);
            if (poweredUp) {
              int eatenGhostIndex = index;
              GhostsP[eatenGhostIndex] = -1;
              score += 5;
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  GhostsP[eatenGhostIndex] = ghostRespawnPosition();
                });
              });
            } else {
              timer.cancel();
              gameTimer = null;
              start = false;
              BigText = "Game Over!";
              return;
            }
          }

          switch (direction) {
            case "right":
              if (!br.contains(player + 1)) player++;
              break;
            case "left":
              if (!br.contains(player - 1)) player--;
              break;
            case "up":
              if (!br.contains(player - numberInRow)) player -= numberInRow;
              break;
            case "down":
              if (!br.contains(player + numberInRow)) player += numberInRow;
              break;
          }
        });
      });
    }
  }

  void activatePowerUp() {
    setState(() {
      poweredUp = true;
    });
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        poweredUp = false;
      });
    });
  }

  int ghostRespawnPosition() {
    List<int> possible = [20, 14, 74];
    possible.shuffle();
    return possible.first;
  }

  void ResetGame() {
    setState(() {
      Food.clear();
      getFood();
      score = 0;
      player = 193;
      direction = "right";
      start = true;
      paused = false;
      BigText = "Pac Man";
      GhostsP = [20, 14, 74];
      poweredUp = false;
      gameTimer?.cancel();
      gameTimer = null;
    });
  }

  void Ghostmove() {
    for (int i = 0; i < GhostsP.length; i++) {
      if (GhostsP[i] == -1) continue;
      var rng = Random();
      int x = rng.nextInt(5);
      switch (x % 5) {
        case 0:
          if (!br.contains(GhostsP[i] + 1)) GhostsP[i] += 1;
          break;
        case 1:
          if (!br.contains(GhostsP[i] - numberInRow)) GhostsP[i] -= numberInRow;
          break;
        case 2:
          if (!br.contains(GhostsP[i] + numberInRow)) GhostsP[i] += numberInRow;
          break;
        case 3:
          if (!br.contains(GhostsP[i] - 1)) GhostsP[i] -= 1;
          break;
        case 4:
          if (!br.contains(GhostsP[i] - numberInRow)) GhostsP[i] -= numberInRow;
          break;
      }
    }
  }

  Widget FindChild(int index) {
    if (index == player) {
      if (MouthClosed) {
        return Padding(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(color: Colors.amber),
          ),
        );
      }
      switch (direction) {
        case "right":
          return Player("assets/images/pacman0.png");
        case "left":
          return Transform.rotate(
              angle: pi, child: Player("assets/images/pacman0.png"));
        case 'up':
          return Transform.rotate(
              angle: 3 * pi / 2, child: Player("assets/images/pacman0.png"));
        case 'down':
          return Transform.rotate(
              angle: pi / 2, child: Player("assets/images/pacman0.png"));
        default:
          return Container();
      }
    } else if (GhostsP.contains(index)) {
      int ghostIndex = GhostsP.indexOf(index);
      String ghostImage = poweredUp
          ? "assets/images/brocoli.png"
          : normalGhostImages[ghostIndex];
      return Ghost(ghostImage, index);
    } else if (br.contains(index)) {
      return MyPixel(
          Color.fromARGB(255, 0, 13, 153), Color.fromARGB(255, 2, 12, 118));
    } else if (powerDots.contains(index)) {
      return Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent),
        margin: EdgeInsets.all(10),
      );
    } else if (Food.contains(index)) {
      return Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
        margin: EdgeInsets.all(12),
      );
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    getFood();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(BigText,
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.black,
        body: Column(children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  direction = 'down';
                } else {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  direction = 'right';
                } else {
                  direction = 'left';
                }
              },
              child: AbsorbPointer(
                child: GridView.builder(
                  itemCount: Squares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: numberInRow),
                  itemBuilder: (BuildContext ctx, int index) {
                    return FindChild(index);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: StartGame,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text("Play",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        paused = !paused;
                        BigText = paused ? "Paused" : "Pac Man";
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Text(paused ? "Resume" : "Pause",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20)),
                    ),
                  ),
                  GestureDetector(
                    onTap: ResetGame,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Text("Reset",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 250, 249, 247),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text('Score : $score',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

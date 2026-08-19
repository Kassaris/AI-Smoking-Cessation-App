import 'package:flutter/material.dart';

class Barrier extends StatelessWidget {
  final BarrierX;
  final barrierWidth;
  final barrierHeight;
  final bool isThisBottomBarrier;
  Barrier(
      {this.barrierHeight,
      this.barrierWidth,
      this.BarrierX,
      required this.isThisBottomBarrier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barrierHeight / 2,
      width: barrierWidth / 2,
      decoration: BoxDecoration(
          color: Colors.green.shade200,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 10.0,
            color: Colors.green.shade700,
          )),
    );
  }
}

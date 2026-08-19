import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Ghost extends StatelessWidget {
  final String url;
  int posisiton;
  Ghost(this.url, this.posisiton);
  @override
  Widget build(BuildContext context) {
    return Image.asset(url);
  }
}

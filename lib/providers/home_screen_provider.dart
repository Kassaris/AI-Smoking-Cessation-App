import 'package:flutter/material.dart';

class HomeScreenProvider extends ChangeNotifier {
  bool _isDrawerOpen = false;
  late AnimationController _controller;
  late Animation<Offset> _drawerSlideAnimation;

  bool get isDrawerOpen => _isDrawerOpen;
  Animation<Offset> get drawerSlideAnimation => _drawerSlideAnimation;

  void init(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    if (_isDrawerOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    notifyListeners();
  }

  void disposeController() {
    _controller.dispose();
  }
}

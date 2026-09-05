import 'package:flutter/material.dart';

class ScaleFadeAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final double beginScale;

  const ScaleFadeAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.beginScale = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    final scale = Tween<double>(
      begin: beginScale,
      end: 1.0,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: scale,
        child: child,
      ),
    );
  }
}
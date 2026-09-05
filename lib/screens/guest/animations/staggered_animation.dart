import 'package:flutter/material.dart';

class StaggeredAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final int index;
  final int itemCount;

  const StaggeredAnimation({
    super.key,
    required this.child,
    required this.controller,
    required this.index,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index / itemCount) * 0.6;

    final end = start + 0.4 > 1.0
        ? 1.0
        : start + 0.4;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AdminFadeAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const AdminFadeAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<AdminFadeAnimation> createState() =>
      _AdminFadeAnimationState();
}

class _AdminFadeAnimationState
    extends State<AdminFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(
      Duration(milliseconds: widget.delay),
          () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
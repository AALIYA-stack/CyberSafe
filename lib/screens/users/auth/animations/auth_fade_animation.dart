import 'package:flutter/material.dart';

class AuthFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int delay;

  const AuthFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(
      milliseconds: 600,
    ),
    this.delay = 0,
  });

  @override
  State<AuthFadeAnimation> createState() =>
      _AuthFadeAnimationState();
}

class _AuthFadeAnimationState
    extends State<AuthFadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > 0) {
      await Future.delayed(
        Duration(
          milliseconds: widget.delay,
        ),
      );
    }

    if (!mounted) return;

    _controller.forward();
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
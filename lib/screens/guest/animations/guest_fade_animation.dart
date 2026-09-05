import 'package:flutter/material.dart';

class GuestFadeAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final Duration duration;

  const GuestFadeAnimation({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<GuestFadeAnimation> createState() =>
      _GuestFadeAnimationState();
}

class _GuestFadeAnimationState
    extends State<GuestFadeAnimation>
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
      curve: Curves.easeOutCubic,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > 0) {
      await Future.delayed(
        Duration(milliseconds: widget.delay),
      );
    }

    if (mounted) {
      _controller.forward();
    }
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
import 'package:flutter/material.dart';

class AuthSlideAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const AuthSlideAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<AuthSlideAnimation> createState() =>
      _AuthSlideAnimationState();
}

class _AuthSlideAnimationState
    extends State<AuthSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 550,
      ),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
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
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
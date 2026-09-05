import 'package:flutter/material.dart';

class GuestCardAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const GuestCardAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<GuestCardAnimation> createState() =>
      _GuestCardAnimationState();
}

class _GuestCardAnimationState
    extends State<GuestCardAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > 0) {
      await Future.delayed(
        Duration(milliseconds: widget.delay),
      );
    }

    if (!mounted) {
      return;
    }

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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
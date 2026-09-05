import 'package:flutter/material.dart';

class GuestSlideAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const GuestSlideAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<GuestSlideAnimation> createState() =>
      _GuestSlideAnimationState();
}

class _GuestSlideAnimationState
    extends State<GuestSlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _slideAnimation;

  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
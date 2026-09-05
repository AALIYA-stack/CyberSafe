import 'package:flutter/material.dart';

class OnboardingSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Duration delay;

  const OnboardingSlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.beginOffset = const Offset(0.0, 0.15),
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<OnboardingSlideAnimation> createState() =>
      _OnboardingSlideAnimationState();
}

class _OnboardingSlideAnimationState
    extends State<OnboardingSlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
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
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}
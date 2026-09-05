import 'package:flutter/material.dart';

class OnboardingFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const OnboardingFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
  });

  @override
  State<OnboardingFadeAnimation> createState() =>
      _OnboardingFadeAnimationState();
}

class _OnboardingFadeAnimationState
    extends State<OnboardingFadeAnimation>
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
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
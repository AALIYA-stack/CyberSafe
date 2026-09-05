import 'package:flutter/material.dart';
class ScaleFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;
  const ScaleFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(
      milliseconds: 500,
    ),
    this.delay = 0,
  });
  @override
  State<ScaleFadeAnimation> createState() =>
      _ScaleFadeAnimationState();
}
class _ScaleFadeAnimationState
    extends State<ScaleFadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scaleAnimation;

  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.delay > 0) {
      Future.delayed(
        Duration(
          milliseconds: widget.delay.toInt(),
        ),
            () {
          if (mounted) {
            _controller.forward();
          }
        },
      );
    } else {
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
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
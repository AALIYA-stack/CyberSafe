import 'package:flutter/material.dart';

class AdminScaleAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const AdminScaleAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<AdminScaleAnimation> createState() =>
      _AdminScaleAnimationState();
}

class _AdminScaleAnimationState
    extends State<AdminScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );

    _animation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
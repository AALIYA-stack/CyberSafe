import 'package:flutter/material.dart';

class AdminSlideAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const AdminSlideAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<AdminSlideAnimation> createState() =>
      _AdminSlideAnimationState();
}

class _AdminSlideAnimationState
    extends State<AdminSlideAnimation>
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
      begin: const Offset(0, 0.08),
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
import 'package:flutter/material.dart';

class ComplaintFormAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const ComplaintFormAnimation({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<ComplaintFormAnimation> createState() =>
      _ComplaintFormAnimationState();
}

class _ComplaintFormAnimationState
    extends State<ComplaintFormAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;

  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
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
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
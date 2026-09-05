import 'package:flutter/material.dart';

class SuccessAnimation extends StatefulWidget {
  final Widget child;

  const SuccessAnimation({
    super.key,
    required this.child,
  });

  @override
  State<SuccessAnimation> createState() =>
      _SuccessAnimationState();
}

class _SuccessAnimationState
    extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}
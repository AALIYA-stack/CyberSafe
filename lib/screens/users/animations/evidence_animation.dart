import 'package:flutter/material.dart';

class EvidenceAnimation extends StatefulWidget {
  final Widget child;

  const EvidenceAnimation({
    super.key,
    required this.child,
  });

  @override
  State<EvidenceAnimation> createState() =>
      _EvidenceAnimationState();
}

class _EvidenceAnimationState
    extends State<EvidenceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
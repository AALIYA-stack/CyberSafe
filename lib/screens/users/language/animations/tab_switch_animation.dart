import 'package:flutter/material.dart';

class TabSwitchAnimation extends StatefulWidget {
  final Widget child;

  const TabSwitchAnimation({
    super.key,
    required this.child,
  });

  @override
  State<TabSwitchAnimation> createState() =>
      _TabSwitchAnimationState();
}

class _TabSwitchAnimationState
    extends State<TabSwitchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;

  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 280,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.015),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(
      covariant TabSwitchAnimation oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.child.key !=
        widget.child.key) {
      _controller
        ..reset()
        ..forward();
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
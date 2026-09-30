import 'package:flutter/material.dart';

/// Minimal, elegant micro-interaction widget that gently scales down
/// on press and smoothly springs back. Gives cards and buttons a tactile,
/// responsive feel without overdoing it.
class InteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final HitTestBehavior behavior;

  const InteractiveBounce({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.975,
    this.duration = const Duration(milliseconds: 110),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<InteractiveBounce> createState() => _InteractiveBounceState();
}

class _InteractiveBounceState extends State<InteractiveBounce> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Subtle entrance animation: gentle fade and slight upward glide using TweenAnimationBuilder.
/// Fully self-contained without long-lived timer assertions in test environments.
class AppFadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double offsetDistance;

  const AppFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.offsetDistance = 8.0,
    Duration delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * offsetDistance),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

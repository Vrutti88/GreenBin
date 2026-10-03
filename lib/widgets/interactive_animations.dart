import 'package:flutter/material.dart';

/// Minimal, elegant micro-interaction widget that elevates and smoothly lifts
/// cards on cursor hover, and gently scales down on press.
/// Gives cards and interactive elements a fluid, modern physical feel.
class InteractiveBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final HitTestBehavior behavior;
  final MouseCursor? mouseCursor;
  final bool enableHover;
  final double hoverLift;
  final double hoverScale;
  final Color? hoverShadowColor;
  final double borderRadius;

  const InteractiveBounce({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.975,
    this.duration = const Duration(milliseconds: 180),
    this.behavior = HitTestBehavior.opaque,
    this.mouseCursor,
    this.enableHover = true,
    this.hoverLift = 5.0,
    this.hoverScale = 1.012,
    this.hoverShadowColor,
    this.borderRadius = 16.0,
  });

  @override
  State<InteractiveBounce> createState() => _InteractiveBounceState();
}

class _InteractiveBounceState extends State<InteractiveBounce> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null || widget.enableHover;
    if (!isInteractive) {
      return widget.child;
    }

    final double dy = (_isHovered && !_isPressed && widget.enableHover)
        ? -widget.hoverLift
        : 0.0;
    final double scale = _isPressed
        ? widget.scaleFactor
        : (_isHovered && widget.enableHover ? widget.hoverScale : 1.0);

    return MouseRegion(
      cursor: widget.mouseCursor ??
          (widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic),
      onEnter: (_) {
        if (widget.enableHover && mounted) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.enableHover && mounted) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setTranslationRaw(0.0, dy, 0.0)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: (_isHovered && !_isPressed && widget.enableHover)
                ? [
                    BoxShadow(
                      color: (widget.hoverShadowColor ?? Colors.black)
                          .withValues(alpha: widget.hoverShadowColor != null ? 0.16 : 0.07),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
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

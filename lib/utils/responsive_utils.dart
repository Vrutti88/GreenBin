import 'package:flutter/material.dart';

/// Screen classification breakpoints according to Material 3 responsive guidelines.
class AppBreakpoints {
  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  // Maximum content width boundaries to prevent awkward stretching on ultra-wide screens.
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 560.0;
  static const double maxCardWidth = 480.0;
  static const double maxDialogWidth = 500.0;
}

/// Device classification enum
enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

/// Helper extensions on BuildContext for quick and clean responsive evaluations.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  Orientation get orientation => MediaQuery.orientationOf(this);

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  bool get isMobile => screenWidth < AppBreakpoints.tabletMin;
  bool get isTablet =>
      screenWidth >= AppBreakpoints.tabletMin &&
      screenWidth <= AppBreakpoints.tabletMax;
  bool get isDesktop => screenWidth >= AppBreakpoints.desktopMin;

  DeviceScreenType get deviceType {
    if (isDesktop) return DeviceScreenType.desktop;
    if (isTablet) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }

  /// Returns a responsive value depending on the current screen size.
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// A widget builder that delivers the current [DeviceScreenType] and constraints.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceScreenType deviceType,
  ) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final DeviceScreenType deviceType;

        if (width >= AppBreakpoints.desktopMin) {
          deviceType = DeviceScreenType.desktop;
        } else if (width >= AppBreakpoints.tabletMin) {
          deviceType = DeviceScreenType.tablet;
        } else {
          deviceType = DeviceScreenType.mobile;
        }

        return builder(context, constraints, deviceType);
      },
    );
  }
}

/// A container that centers and constrains child content to avoid stretched layouts.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: context.responsiveValue(
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 32.0,
                ),
                vertical: 16.0,
              ),
          child: child,
        ),
      ),
    );
  }
}

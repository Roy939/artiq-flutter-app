import 'package:flutter/material.dart';

/// Helper class for responsive layouts across mobile, tablet, and desktop
class ResponsiveLayout {
  /// Breakpoint for tablet devices
  static const double tabletBreakpoint = 768.0;
  
  /// Breakpoint for desktop devices
  static const double desktopBreakpoint = 1024.0;

  /// Check if the current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Check if the current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get the appropriate value based on screen size
  static T valueForScreenType<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get appropriate padding for the screen size
  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(12.0);
    }
  }

  /// Get appropriate grid columns for the screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Get appropriate max width for content on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.0;
    } else {
      return double.infinity;
    }
  }
}

/// Widget that builds different layouts for mobile, tablet, and desktop
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveLayout.desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= ResponsiveLayout.tabletBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

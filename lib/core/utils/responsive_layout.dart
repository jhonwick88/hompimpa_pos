import 'package:flutter/material.dart';

class Responsive {
  /// Check if the device is mobile-class based on shortestSide.
  /// 
  /// IMPORTANT: Only call this within a [build] method or where 
  /// [MediaQuery.of(context)] is safe to access (e.g., within [LayoutBuilder]).
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < 600;

  /// Check if the device is tablet-class based on shortestSide.
  /// 
  /// IMPORTANT: Only call this within a [build] method or where 
  /// [MediaQuery.of(context)] is safe to access (e.g., within [LayoutBuilder]).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  /// Helper to return a value based on device type.
  /// 
  /// IMPORTANT: Only call this within a [build] method.
  static T value<T>(BuildContext context, {required T phone, required T tablet}) {
    return isTablet(context) ? tablet : phone;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget tablet;

  const ResponsiveLayout({
    Key? key,
    required this.phone,
    required this.tablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery (via Responsive helper) to ensure consistent
    // device detection based on shortestSide, preventing layout flaps
    // on rotate or when window width > 600 but device is still mobile-class.
    if (Responsive.isTablet(context)) {
      return tablet;
    } else {
      return phone;
    }
  }
}

import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double compactMax = 560;
  static const double mediumMax = 960;

  static bool isCompact(double width) => width < compactMax;
  static bool isMedium(double width) => width >= compactMax && width < mediumMax;
  static bool isExpanded(double width) => width >= mediumMax;

  static double horizontalPadding(double width) {
    if (isCompact(width)) return 16;
    if (isMedium(width)) return 24;
    return 32;
  }

  static double maxContentWidth(double width) {
    if (isCompact(width)) return width;
    if (isMedium(width)) return 720;
    return 960;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final maxW = ResponsiveLayout.maxContentWidth(w);
        final hPad = ResponsiveLayout.horizontalPadding(w);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: hPad),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

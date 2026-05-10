import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    Widget? tabletBody,
    Widget? desktopBody,
  })  : tabletBody = tabletBody ?? mobileBody,
        desktopBody = desktopBody ?? mobileBody,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 1100) {
        return desktopBody;
      } else if (constraints.maxWidth >= 700) {
        return tabletBody;
      } else {
        return mobileBody;
      }
    });
  }
}

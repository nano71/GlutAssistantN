import 'package:flutter/material.dart';
// 取消涟漪效果
/// Cancel ripples caused by excessive Listview scrolling.
class NoRippleOverScroll extends StatefulWidget {
  final Widget child;

  NoRippleOverScroll({required this.child});

  @override
  NoRippleOverScrollState createState() => NoRippleOverScrollState();
}

class NoRippleOverScrollState extends State<NoRippleOverScroll> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _OverScrollBehavior(),
      child: widget.child,
    );
  }
}

class _OverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (getPlatform(context) == TargetPlatform.android ||
        getPlatform(context) == TargetPlatform.fuchsia) {
      return GlowingOverscrollIndicator(
        child: child,
        showLeading: false,
        showTrailing: false,
        axisDirection: axisDirection,
        //'accentColor' is deprecated and shouldn't be used. Use colorScheme.secondary instead. For more information, consult the migration guide at https://flutter.dev/docs/release/breaking-changes/theme-data-accent-properties#migration-guide. This feature was deprecated after v2.3.0-0.1.pre.. (文档)  Try replacing the use of the deprecated member with the replacement.
        color: Theme.of(context).colorScheme.secondary,
      );
    } else {
      return child;
    }
  }
}

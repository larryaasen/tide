import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Applies a theme to descendant widgets.
///
/// A theme describes the colors and typographic choices of an application.
class TideTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  const TideTheme({
    super.key,
    required this.data,
    required this.child,
  });

  /// Specifies the color and typography values for descendant widgets.
  final TideThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  static final _kFallbackThemeData = TideThemeData.fallback();

  /// The data from the closest [TideTheme] instance that encloses the given
  /// context.
  static TideThemeData of(BuildContext context) {
    final theme = context.findAncestorWidgetOfExactType<TideTheme>();

    final themeData = theme?.data ?? _kFallbackThemeData;
    return themeData;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class TideThemeData with Diagnosticable {
  factory TideThemeData({
    TideQuickPickThemeData? quickPick,
  }) {
    quickPick ??= TideQuickPickThemeData();

    return TideThemeData.raw(
      quickPick: quickPick,
    );
  }

  /// Create a [TideThemeData] given a set of exact values. Most values must be
  /// specified. They all must also be non-null.
  const TideThemeData.raw({
    required this.quickPick,
  });

  /// The default Tide theme. This is used by [TideTheme.of] when no theme has been specified.
  factory TideThemeData.fallback() => TideThemeData();

  final TideQuickPickThemeData quickPick;
}

/*

class TideQuickPickTheme extends InheritedTheme {
  const TideQuickPickTheme({
    super.key,
    Color? backgroundColor,
    TideQuickPickThemeData? data,
    Widget? child,
  })  : _data = data,
        _backgroundColor = backgroundColor,
        super(child: child ?? const SizedBox());

  final TideQuickPickThemeData? _data;
  final Color? _backgroundColor;

  /// Overrides the default value for [Dialog.backgroundColor].
  Color? get backgroundColor =>
      _data != null ? _data.backgroundColor : _backgroundColor;

  /// The properties used for all descendant [Dialog] widgets.
  TideQuickPickThemeData get data {
    return _data ??
        TideQuickPickThemeData(
          backgroundColor: _backgroundColor,
        );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TideQuickPickTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TideQuickPickTheme oldWidget) =>
      data != oldWidget.data;
}
*/

/// A theme for customizing TideQuickPick widgets.
class TideQuickPickThemeData {
  factory TideQuickPickThemeData({
    Color? itemSelectedBackgroundColor,
    Color? itemUnselectedBackgroundColor,
    Color? itemSelectedForegroundColor,
    Color? itemUnselectedForegroundColor,
    DividerThemeData? itemDividerTheme,
  }) {
    itemSelectedBackgroundColor ??= const Color(0xFF0060C0);
    itemUnselectedBackgroundColor ??= Colors.transparent;
    itemSelectedForegroundColor ??= Colors.white;
    itemUnselectedForegroundColor ??= Colors.black87;
    itemDividerTheme ??= const DividerThemeData(
        color: Color(0xFFCCCEDB), thickness: 1.0, space: 1.0);

    return TideQuickPickThemeData.raw(
      itemSelectedBackgroundColor: itemSelectedBackgroundColor,
      itemUnselectedBackgroundColor: itemUnselectedBackgroundColor,
      itemSelectedForegroundColor: itemSelectedForegroundColor,
      itemUnselectedForegroundColor: itemUnselectedForegroundColor,
      itemDividerTheme: itemDividerTheme,
    );
  }

  const TideQuickPickThemeData.raw({
    required this.itemSelectedBackgroundColor,
    required this.itemUnselectedBackgroundColor,
    required this.itemSelectedForegroundColor,
    required this.itemUnselectedForegroundColor,
    required this.itemDividerTheme,
  });

  /// The selected background color for [TideQuickPickItemWidget].
  final Color itemSelectedBackgroundColor;

  /// The unselected background color for [TideQuickPickItemWidget].
  final Color itemUnselectedBackgroundColor;

  /// The selected foreground color for [TideQuickPickItemWidget].
  final Color itemSelectedForegroundColor;

  /// The unselected foreground color for [TideQuickPickItemWidget].
  final Color itemUnselectedForegroundColor;

  final DividerThemeData itemDividerTheme;

  TideQuickPickThemeData copyWith({
    Color? itemSelectedBackgroundColor,
    Color? itemUnselectedBackgroundColor,
    Color? itemSelectedForegroundColor,
    Color? itemUnselectedForegroundColor,
    DividerThemeData? itemDividerTheme,
  }) {
    return TideQuickPickThemeData.raw(
      itemSelectedBackgroundColor:
          itemSelectedBackgroundColor ?? this.itemSelectedBackgroundColor,
      itemUnselectedBackgroundColor:
          itemUnselectedBackgroundColor ?? this.itemUnselectedBackgroundColor,
      itemSelectedForegroundColor:
          itemSelectedForegroundColor ?? this.itemSelectedForegroundColor,
      itemUnselectedForegroundColor:
          itemUnselectedForegroundColor ?? this.itemUnselectedForegroundColor,
      itemDividerTheme: itemDividerTheme ?? this.itemDividerTheme,
    );
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        itemSelectedBackgroundColor,
        itemUnselectedBackgroundColor,
        itemSelectedForegroundColor,
        itemUnselectedForegroundColor,
        itemDividerTheme
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TideQuickPickThemeData &&
        other.itemSelectedBackgroundColor == itemSelectedBackgroundColor &&
        other.itemUnselectedBackgroundColor == itemUnselectedBackgroundColor &&
        other.itemSelectedForegroundColor == itemSelectedForegroundColor &&
        other.itemUnselectedForegroundColor == itemUnselectedForegroundColor &&
        other.itemDividerTheme == itemDividerTheme;
  }
}

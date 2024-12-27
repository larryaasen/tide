import 'package:flutter/widgets.dart';

import '../tide.dart';
import '../tide_core.dart';

/// Provides access to the workbench accessor to get instance of registered objects.
/// Example:
/// ```dart
///   final accessor = TideWorkbenchAccessor.of(context).accessor;
/// ```
class TideWorkbenchAccessor extends StatelessWidget {
  /// Creates a workbench accessor.
  const TideWorkbenchAccessor(
      {super.key, required this.accessor, required this.child});

  final TideServicesAccessor accessor;
  final Widget child;

  // Static method to find this widget from descendants
  static TideWorkbenchAccessor of(BuildContext context) {
    final widget =
        context.findAncestorWidgetOfExactType<TideWorkbenchAccessor>();
    if (widget == null) {
      Tide.log(
          'The TideWorkbenchAccessor is not registered for use by commands. '
          'Did you forget to add a workbenchService to your TideWorkbench?\n'
          'Here is an example:\n'
          '  final workbenchService = TideWorkbenchService();\n'
          '  TideWorkbench(workbenchService: workbenchService);');
      throw FlutterError('TideWorkbenchAccessor not found in context');
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

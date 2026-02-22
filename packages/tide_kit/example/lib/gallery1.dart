import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 1: status bar with no panels.
Widget gallery1() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  return const TideApp();
}

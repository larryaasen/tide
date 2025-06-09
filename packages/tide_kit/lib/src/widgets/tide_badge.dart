import 'package:flutter/material.dart';

/// A badge widget that displays a number inside a circle.
class TideBadge extends StatelessWidget {
  /// Creates a badge widget that displays a number inside a circle.
  const TideBadge(
      {super.key,
      required this.badgeValue,
      this.circleRadius = 8.0,
      this.fontSize = 10.0,
      this.badgeColor = defaultBadgeColor});

  final int badgeValue;
  final double circleRadius;
  final double fontSize;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: circleRadius,
      backgroundColor: defaultBadgeColor,
      child: Text(
        badgeValue.toString(),
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }

  static const Color defaultBadgeColor = Color(0xFF007ACC);
}

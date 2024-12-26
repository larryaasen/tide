import 'package:flutter/material.dart';

import '../status_bar/tide_status_bar.dart';

class TideRoundCloseIcon extends StatelessWidget {
  const TideRoundCloseIcon({super.key, this.onPressed});

  /// Called when the close icon is tapped or otherwise activated.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 14.0, // Adjust the width as needed
        height: 14.0, // Adjust the height as needed
        decoration: const BoxDecoration(
          color: Colors.white, // Background color of the circle
          shape: BoxShape.circle, // Circular shape
        ),
        child: const Center(
          child: Icon(
            Icons.close,
            color:
                TideStatusBar.defaultBackgroundColor, // Color of the close icon
            size: 12.0, // Size of the close icon
          ),
        ),
      ),
    );
  }
}

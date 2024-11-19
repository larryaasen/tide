import 'package:flutter/material.dart';
import 'package:tide/tide.dart';

import 'tide_window.dart';

/// The use of this widget is optional and does not affect the functionality of the Tide app.
/// It is provided as a convenience to help you get started with your app.
/// This widget can be the root of a Tide application. The real entry point is the
/// [TideWindow] widget.
class TideApp extends StatelessWidget {
  const TideApp({super.key, this.home});

  final TideWindow? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: home ?? TideWindow(),
      debugShowCheckedModeBanner: false,
    );
  }
}

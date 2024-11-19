import 'package:flutter/material.dart';

import 'tide_workbench.dart';

class TideWindow extends StatelessWidget {
  TideWindow({super.key, this.workbench}) {
    print("Tide: TideWindow created");
  }

  // final Tide tide;
  final TideWorkbench? workbench;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: workbench ?? TideWorkbench());
  }
}

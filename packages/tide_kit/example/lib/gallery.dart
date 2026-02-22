import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'gallery1.dart' as ex1;
import 'gallery10.dart' as ex10;
import 'gallery11.dart' as ex11;
import 'gallery12.dart' as ex12;
import 'gallery13.dart' as ex13;
import 'gallery14.dart' as ex14;
import 'gallery15.dart' as ex15;
import 'gallery16.dart' as ex16;
import 'gallery17.dart' as ex17;
import 'gallery18.dart' as ex18;
import 'gallery19.dart' as ex19;
import 'gallery2.dart' as ex2;
import 'gallery20.dart' as ex20;
import 'gallery21.dart' as ex21;
import 'gallery3.dart' as ex3;
import 'gallery4.dart' as ex4;
import 'gallery5.dart' as ex5;
import 'gallery6.dart' as ex6;
import 'gallery7.dart' as ex7;
import 'gallery8.dart' as ex8;
import 'gallery9.dart' as ex9;

void main() {
  runApp(const GalleryApp());
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  String? selectedExample;
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyS) {
      if (HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed) {
        if (_captureKey.currentContext != null) {
          _captureScreenshot(_captureKey.currentContext!);
        }
        return true;
      }
    }
    return false;
  }

  Future<void> _captureScreenshot(BuildContext ctx) async {
    try {
      final boundaryContext = _captureKey.currentContext;
      if (boundaryContext == null) return;
      final boundary =
          boundaryContext.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final downloadsPath = '${Platform.environment['HOME']}/Downloads';
        final now = DateTime.now();
        final year = now.year;
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        var hour = now.hour;
        final isPM = hour >= 12;
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        final minute = now.minute.toString().padLeft(2, '0');
        final second = now.second.toString().padLeft(2, '0');
        final amPm = isPM ? 'PM' : 'AM';

        final fileName =
            'Tide $year-$month-$day at $hour.$minute.$second $amPm.png';
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(pngBytes);
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Screenshot saved: $fileName')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
    }
  }

  final Map<String, Widget Function()> examples = {
    '10': ex10.gallery10,
    '11': ex11.gallery11,
    '16': ex16.gallery16,
    '7': ex7.gallery7,
    '20': ex20.gallery20,
    '21': ex21.gallery21,
    '6': ex6.gallery6,
    '17': ex17.gallery17,
    '1': ex1.gallery1,
    '5': ex5.gallery5,
    '14': ex14.gallery14,
    '9': ex9.gallery9,
    '18': ex18.gallery18,
    '19': ex19.gallery19,
    '8': ex8.gallery8,
    '15': ex15.gallery15,
    '4': ex4.gallery4,
    '3': ex3.gallery3,
    '12': ex12.gallery12,
    '13': ex13.gallery13,
    '2': ex2.gallery2,
  };

  @override
  Widget build(BuildContext context) {
    // Sort keys numerically
    final keys = examples.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            // Internal Sidebar Menu
            Container(
              width: 200,
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tide Gallery',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final k = keys[index];
                        final isSelected = selectedExample == k;
                        return ListTile(
                          title: Text('Example $k'),
                          selected: isSelected,
                          selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                          onTap: () {
                            setState(() {
                              selectedExample = k;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cmd/Ctrl + S for screenshot',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Example View
            Expanded(
              child: RepaintBoundary(
                key: _captureKey,
                child: selectedExample == null
                    ? const Center(
                        child: Text('Select an example from the sidebar'))
                    : KeyedSubtree(
                        key: ValueKey(selectedExample),
                        child: examples[selectedExample]!(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

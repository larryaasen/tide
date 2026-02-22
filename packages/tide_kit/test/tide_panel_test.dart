import 'package:flutter_test/flutter_test.dart';
import 'package:tide_kit/src/panels/tide_node.dart';
import 'package:tide_kit/src/panels/tide_panel_old.dart';
import 'package:tide_kit/src/tide_core.dart';
import 'dart:ui';

void main() {
  group('TidePanel', () {
    test('copyWith returns a new instance with updated values', () {
      const panel = TidePanelOld(panelId: TideId('panel1'), isVisible: true);
      final updated = panel.copyWith(isVisible: false);

      expect(updated.panelId, panel.panelId);
      expect(updated.isVisible, false);
      expect(updated.panelBuilder, panel.panelBuilder);
    });

    test('props returns correct values', () {
      const panel = TidePanelOld(panelId: TideId('panel1'), isVisible: true);
      expect(panel.props, [panel.panelId, panel.isVisible, panel.panelBuilder]);
    });
  });

  group('TidePanelNodeLeaf', () {
    test('copyWith returns a new instance with updated panels', () {
      const panel1 = TidePanelOld(panelId: TideId('p1'));
      const panel2 = TidePanelOld(panelId: TideId('p2'));
      // final leaf = TidePanel(panels: const [panel1]);
      // final updated = leaf.copyWith(panels: [panel2]);

      // expect(updated.panels, [panel2]);
      // expect(updated.nodeId, leaf.nodeId);
      // expect(updated.minDimension, leaf.minDimension);
    });

    test('props includes panels', () {
      const panel = TidePanelOld(panelId: TideId('p1'));
      final leaf = TidePanel(panels: const [panel]);
      expect(leaf.props.contains([panel]), false); // List equality is by ref
      expect(leaf.props.last, [panel]);
    });
  });

  group('TidePanelNodePair', () {
    test('copyWith returns a new instance with updated values', () {
      final leaf1 = TidePanel(panels: const []);
      final leaf2 = TidePanel(panels: const []);
      final pair = TidePanelPair(start: leaf1, end: leaf2);
      final updated = pair.copyWith(start: leaf2);

      expect(updated.start, leaf2);
      expect(updated.end, pair.end);
      expect(updated.orientation, pair.orientation);
    });

    test('adjustedSplit returns minDimension if min==max', () {
      expect(
        TidePanelPair.adjustedSplit(50, 50, 30),
        50,
      );
      expect(
        TidePanelPair.adjustedSplit(50, 100, 30),
        30,
      );
    });

    test('useSash always returns true', () {
      final leaf1 = TidePanel(panels: const []);
      final leaf2 = TidePanel(panels: const []);
      final pair = TidePanelPair(start: leaf1, end: leaf2);
      expect(pair.useSash, true);
    });

    test('isSashVertical returns correct value', () {
      final leaf1 = TidePanel(panels: const []);
      final leaf2 = TidePanel(panels: const []);
      final pairH = TidePanelPair(
        start: leaf1,
        end: leaf2,
        orientation: TideOrientation.horizontal,
      );
      final pairV = TidePanelPair(
        start: leaf1,
        end: leaf2,
        orientation: TideOrientation.vertical,
      );
      expect(pairH.isSashVertical, true);
      expect(pairV.isSashVertical, false);
    });

    test('minMaxDimension returns expected tuple', () {
      final leaf1 = TidePanel(
        panels: const [],
        minDimension: 50,
        maxDimension: 200,
      );
      final leaf2 = TidePanel(
        panels: const [],
        minDimension: 30,
        maxDimension: 150,
      );
      final pair = TidePanelPair(start: leaf1, end: leaf2);
      const size = Size(300, 200);

      final (minDim, maxDim) = pair.minMaxDimension(size);
      expect(minDim, isA<double>());
      expect(maxDim, isA<double>());
      expect(minDim <= maxDim, true);
    });
  });

  group('TidePanelNodeExt', () {
    test('minSplit/maxSplit with default min/max', () {
      final leaf = TidePanel(panels: const []);

      expect(leaf.minSplit(const Size(600, 400), true, reversed: false), 100);
      expect(leaf.maxSplit(const Size(600, 400), true, reversed: true), 600);

      expect(leaf.minSplit(const Size(50, 50), true, reversed: false), 50);
      expect(leaf.maxSplit(const Size(50, 50), true, reversed: true), 50);

      expect(leaf.minSplit(const Size(600, 400), false, reversed: false), 100);
      expect(leaf.maxSplit(const Size(600, 400), false, reversed: true), 400);

      expect(leaf.minSplit(const Size(50, 50), false, reversed: false), 50);
      expect(leaf.maxSplit(const Size(50, 50), false, reversed: true), 50);
    });

    test('minSplit and maxSplit calculate correct values', () {
      final leaf =
          TidePanel(panels: const [], minDimension: 50, maxDimension: 150);

      expect(leaf.minSplit(const Size(600, 400), true, reversed: false), 50);
      expect(leaf.maxSplit(const Size(600, 400), true, reversed: true), 450);

      expect(leaf.minSplit(const Size(40, 40), true, reversed: false), 40);
      expect(leaf.maxSplit(const Size(40, 40), true, reversed: true), 40);

      expect(leaf.minSplit(const Size(600, 400), false, reversed: false), 50);
      expect(leaf.maxSplit(const Size(600, 400), false, reversed: true), 250);

      expect(leaf.minSplit(const Size(40, 40), false, reversed: false), 40);
      expect(leaf.maxSplit(const Size(40, 40), false, reversed: true), 40);
    });

    test('TidePanelNodeLeaf with valid min', () {
      TidePanel(
          panels: const [], minDimension: TidePanelNode.defaultMinDimension);
      TidePanel(panels: const [], minDimension: 0);
      TidePanel(panels: const [], minDimension: 50);
      TidePanel(panels: const [], minDimension: 150);
      TidePanel(panels: const [], minDimension: double.infinity);
    });

    test('TidePanelNodeLeaf with invalid min', () {
      expect(
        () => TidePanel(panels: const [], minDimension: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: const [], minDimension: -50),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: const [], minDimension: -double.infinity),
        throwsA(isA<AssertionError>()),
      );
    });

    test('TidePanelNodeLeaf with invalid max', () {
      expect(
        () => TidePanel(panels: const [], maxDimension: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: const [], maxDimension: -50),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: const [], maxDimension: -double.infinity),
        throwsA(isA<AssertionError>()),
      );
    });

    test('minSplitTidePanelNodeLeaf with invalid min/max', () {
      expect(
        () => TidePanel(panels: const [], minDimension: 150, maxDimension: 50),
        throwsA(isA<AssertionError>()),
      );
    });

    test('minSplit and maxSplit with reversed', () {
      final leaf = TidePanel(
        panels: const [],
        minDimension: 50,
        maxDimension: 150,
      );
      const size = Size(200, 100);

      expect(
        leaf.minSplit(size, true, reversed: true),
        150,
      );
      expect(
        leaf.maxSplit(size, true, reversed: true),
        50,
      );
    });
  });
}

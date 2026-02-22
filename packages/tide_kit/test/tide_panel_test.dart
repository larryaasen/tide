import 'package:flutter_test/flutter_test.dart';
import 'package:tide_kit/src/panels/tide_node.dart';
import 'package:tide_kit/src/tide_core.dart';
import 'dart:ui';

void main() {
  group('TidePanel', () {
    test('copyWith returns a new instance with updated values', () {
      final panel = TidePanel(panelId: const TideId('panel1'), isVisible: true);
      final updated = panel.copyWith(isVisible: false);

      expect(updated.panelId, panel.panelId);
      expect(updated.isVisible, false);
      expect(updated.builder, panel.builder);
    });

    test('props returns correct values', () {
      final panel = TidePanel(panelId: const TideId('panel1'), isVisible: true);
      expect(panel.props.contains(panel.panelId), true);
      expect(panel.props.contains(panel.isVisible), true);
    });
  });

  group('TidePanelNodeLeaf', () {
    test('copyWith returns a new instance with updated panels', () {
      final panel1 = TidePanel(panelId: const TideId('p1'));
      final panel2 = TidePanel(panelId: const TideId('p2'));
      final leaf = TidePanel(panels: [panel1]);
      final updated = leaf.copyWith(panels: [panel2]);

      expect(updated.panels, [panel2]);
      expect(updated.nodeId, leaf.nodeId);
      expect(updated.minDimension, leaf.minDimension);
    });

    test('props includes panels', () {
      final panel = TidePanel(panelId: const TideId('p1'));
      final leaf = TidePanel(panels: [panel]);
      expect(leaf.props.contains(panel), false); // List equality is by ref
      expect(leaf.props.contains([panel]), false); // List equality is by ref
    });
  });

  group('TidePanelNodePair', () {
    test('copyWith returns a new instance with updated values', () {
      final leaf1 = TidePanel(panels: []);
      final leaf2 = TidePanel(panels: []);
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
      final leaf1 = TidePanel(panels: []);
      final leaf2 = TidePanel(panels: []);
      final pair = TidePanelPair(start: leaf1, end: leaf2);
      expect(pair.useSash, true);
    });

    test('isSashVertical returns correct value', () {
      final leaf1 = TidePanel(panels: []);
      final leaf2 = TidePanel(panels: []);
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
        panels: [],
        minDimension: 50,
        maxDimension: 200,
      );
      final leaf2 = TidePanel(
        panels: [],
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
      final leaf = TidePanel(panels: []);

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
      final leaf = TidePanel(panels: [], minDimension: 50, maxDimension: 150);

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
      TidePanel(panels: [], minDimension: TidePanelNode.defaultMinDimension);
      TidePanel(panels: [], minDimension: 0);
      TidePanel(panels: [], minDimension: 50);
      TidePanel(panels: [], minDimension: 150);
      TidePanel(panels: [], minDimension: double.infinity);
    });

    test('TidePanelNodeLeaf with invalid min', () {
      expect(
        () => TidePanel(panels: [], minDimension: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: [], minDimension: -50),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: [], minDimension: -double.infinity),
        throwsA(isA<AssertionError>()),
      );
    });

    test('TidePanelNodeLeaf with invalid max', () {
      expect(
        () => TidePanel(panels: [], maxDimension: -1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: [], maxDimension: -50),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TidePanel(panels: [], maxDimension: -double.infinity),
        throwsA(isA<AssertionError>()),
      );
    });

    test('minSplitTidePanelNodeLeaf with invalid min/max', () {
      expect(
        () => TidePanel(panels: [], minDimension: 150, maxDimension: 50),
        throwsA(isA<AssertionError>()),
      );
    });

    test('minSplit and maxSplit with reversed', () {
      final leaf = TidePanel(
        panels: [],
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

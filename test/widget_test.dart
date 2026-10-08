import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rectangle_app/main.dart';
import 'package:rectangle_app/models/node.dart';
import 'package:rectangle_app/widgets/options_sheet.dart';

void main() {
  testWidgets('AppBar displays initial rectangle count "Rectangles : 1"',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RectangleApp());

    // Verify AppBar exists with counter
    expect(find.text('Rectangles : 1'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);

    // Initial root rectangle displays depth 0
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Depth tracking updates correctly on splits and displays inside rectangles',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RectangleApp());

    // Initial state: depth 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Split initial rectangle -> produces two children of depth 1
    await tester.tap(find.byType(ClipRRect).first);
    await tester.pump();

    // Now there are two rectangles showing depth 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNWidgets(2));

    // Split one of the children -> produces two children of depth 2
    await tester.tap(find.byType(ClipRRect).first);
    await tester.pump();

    // Now 1 rectangle with depth 1, and 2 rectangles with depth 2
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));

    // Restart resets back to depth 0
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('Counter updates dynamically on each split and resets on restart',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RectangleApp());

    // Starts at 1
    expect(find.text('Rectangles : 1'), findsOneWidget);

    // Split initial rectangle -> count becomes 2
    await tester.tap(find.byType(ClipRRect).first);
    await tester.pump();
    expect(find.text('Rectangles : 2'), findsOneWidget);

    // Split first child -> count becomes 3
    await tester.tap(find.byType(ClipRRect).first);
    await tester.pump();
    expect(find.text('Rectangles : 3'), findsOneWidget);

    // Split second child -> count becomes 4
    await tester.tap(find.byType(ClipRRect).at(1));
    await tester.pump();
    expect(find.text('Rectangles : 4'), findsOneWidget);

    // Tap restart -> count resets to 1
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('Rectangles : 1'), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('Node depth increment unit test', (WidgetTester tester) async {
    final root = Node();
    expect(root.depth, equals(0));

    root.split(gradientMode: false);
    expect(root.children[0].depth, equals(1));
    expect(root.children[1].depth, equals(1));

    root.children[0].split(gradientMode: true);
    expect(root.children[0].children[0].depth, equals(2));
    expect(root.children[0].children[1].depth, equals(2));
  });

  testWidgets('countRectangles and leafCount helper logic unit test',
      (WidgetTester tester) async {
    final root = Node();
    expect(countRectangles(root), equals(1));
    expect(root.leafCount, equals(1));

    root.split(gradientMode: false);
    expect(countRectangles(root), equals(2));
    expect(root.leafCount, equals(2));

    root.children[0].split(gradientMode: false);
    expect(countRectangles(root), equals(3));
    expect(root.leafCount, equals(3));

    root.children[1].split(gradientMode: true);
    expect(countRectangles(root), equals(4));
    expect(root.leafCount, equals(4));
  });

  testWidgets('Body rectangle fills entire available body space and splits properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const RectangleApp());

    final initialRectFinder = find.byType(ClipRRect);
    expect(initialRectFinder, findsOneWidget);

    final RenderBox initialBox = tester.renderObject(initialRectFinder);
    expect(initialBox.size.width, equals(800.0));
    expect(initialBox.size.height, equals(600.0 - kToolbarHeight));

    // Tap to split vertically (Row)
    await tester.tap(initialRectFinder);
    await tester.pump();

    final splitRects = find.byType(ClipRRect);
    expect(splitRects, findsNWidgets(2));
    final RenderBox child1Box = tester.renderObject(splitRects.at(0));
    final RenderBox child2Box = tester.renderObject(splitRects.at(1));
    expect(child1Box.size.width, equals(400.0));
    expect(child1Box.size.height, equals(600.0 - kToolbarHeight));
    expect(child2Box.size.width, equals(400.0));
    expect(child2Box.size.height, equals(600.0 - kToolbarHeight));
  });

  testWidgets('Options panel opens and shows sliders and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RectangleApp());

    // Tap options button
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // Options sheet is displayed
    expect(find.byType(OptionsSheet), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Largeur de bordure'), findsOneWidget);
    expect(find.text('Rayon des coins'), findsOneWidget);
    expect(find.text('Mode dégradé'), findsOneWidget);

    // Verify sliders exist
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(Switch), findsOneWidget);

    // Close panel
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(OptionsSheet), findsNothing);
  });
}

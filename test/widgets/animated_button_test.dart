import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/core/widgets/animated_button.dart';

void main() {
  group('AnimatedButton Widget', () {
    testWidgets('displays the correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedButton(
              text: 'Test Button',
              onPressed: () {},
              delay: 0,
            ),
          ),
        ),
      );

      // The text should be present
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedButton(
              text: 'Press Me',
              onPressed: () {
                pressed = true;
              },
              delay: 0,
            ),
          ),
        ),
      );

      // Animation may require some time to settle
      await tester.pumpAndSettle();
      // Tap the button
      await tester.tap(find.byType(AnimatedButton));
      // Wait for gesture callbacks and animations
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders outlined button when isOutlined is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedButton(
              text: 'Outlined',
              onPressed: () {},
              delay: 0,
              isOutlined: true,
            ),
          ),
        ),
      );

      // The Container should have a border (look for a Container with Border)
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedButton),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
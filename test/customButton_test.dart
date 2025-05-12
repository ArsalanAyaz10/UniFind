import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/core/widgets/auth_button.dart';

void main() {
  testWidgets('CustomButton renders with text and reacts to tap', (
    WidgetTester tester,
  ) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Submit',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();
    expect(wasPressed, isTrue);
  });

  testWidgets('CustomButton shows solid color if provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Colored',
            onPressed: () {},
            color: Colors.blue,
          ),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(container.decoration, isA<BoxDecoration>());
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, equals(Colors.blue));
    expect(decoration.gradient, isNull);
  });
}

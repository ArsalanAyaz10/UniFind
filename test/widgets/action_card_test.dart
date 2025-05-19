import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/core/widgets/action_card.dart';

void main() {
  group('ActionCard Widget', () {
    testWidgets('displays title, description, and icon', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testDescription = 'Test Description';
      const testIcon = Icons.ac_unit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black, // to see white text/icons
            body: ActionCard(
               // context param is ignored in constructor
              title: testTitle,
              description: testDescription,
              icon: testIcon,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testDescription), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: ActionCard(
              title: 'Tap Test',
              description: 'Tap Description',
              icon: Icons.add,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ActionCard));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
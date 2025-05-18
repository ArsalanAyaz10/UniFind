import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/features/item/view/widgets/categoryScroll.dart';

void main() {
  group('LostFoundItemCard Widget', () {
    const testImageUrl = 'https://example.com/nonexistent.jpg';
    const testName = 'Wallet';
    const testCampus = 'City Campus';
    const testSpecificLocation = 'Library';
    const testCategoryLost = 'Lost';
    const testCategoryFound = 'Found';

    testWidgets('displays all main fields and triggers onTap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LostFoundItemCard(
              imageUrl: testImageUrl,
              name: testName,
              campus: testCampus,
              specificLocation: testSpecificLocation,
              category: testCategoryLost,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Wait for image to fail loading and errorBuilder to show icon
      await tester.pumpAndSettle();

      expect(find.text(testName), findsOneWidget);
      expect(find.text('$testCampus - $testSpecificLocation'), findsOneWidget);
      expect(find.text(testCategoryLost), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsOneWidget);

      // Should respond to tap
      await tester.tap(find.byType(LostFoundItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows Lost badge in red and Found badge in green', (WidgetTester tester) async {
      // Test Lost badge
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LostFoundItemCard(
              imageUrl: testImageUrl,
              name: testName,
              campus: testCampus,
              specificLocation: testSpecificLocation,
              category: testCategoryLost,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lostBadge = tester.widget<Container>(
        find.descendant(
          of: find.byType(LostFoundItemCard),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.child is Text &&
            (w.child as Text).data == testCategoryLost),
        ),
      );
      final lostBadgeDecoration = lostBadge.decoration as BoxDecoration;
      // Should be reddish
      expect((lostBadgeDecoration.color! as Color).red, greaterThan(100));

      // Test Found badge
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LostFoundItemCard(
              imageUrl: testImageUrl,
              name: testName,
              campus: testCampus,
              specificLocation: testSpecificLocation,
              category: testCategoryFound,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final foundBadge = tester.widget<Container>(
        find.descendant(
          of: find.byType(LostFoundItemCard),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.child is Text &&
            (w.child as Text).data == testCategoryFound),
        ),
      );
      final foundBadgeDecoration = foundBadge.decoration as BoxDecoration;
      // Should be greenish
      expect((foundBadgeDecoration.color! as Color).green, greaterThan(100));
    });
  });
}
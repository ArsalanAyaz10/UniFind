import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/core/widgets/modern_itemcard.dart';

void main() {
  group('ModernItemCard Widget', () {
    // Use a sample image that won't load, to trigger the errorBuilder
    const testImageUrl = 'https://example.com/nonexistent.jpg';
    const testLocation = 'Room 101';
    const testName = 'Calculator';
    const testCampus = 'Main Campus';
    const testCategoryLost = 'Lost';
    const testCategoryFound = 'Found';

    testWidgets('displays all main fields and triggers onTap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: ModernItemCard(
              imageUrl: testImageUrl,
              specificLocation: testLocation,
              name: testName,
              campus: testCampus,
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
      expect(find.text(testCampus), findsOneWidget);
      expect(find.text(testLocation), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text(testCategoryLost), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);

      // Should respond to tap
      await tester.tap(find.byType(ModernItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows Lost badge in red and Found badge in green', (
      WidgetTester tester,
    ) async {
      // Test Lost badge color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: ModernItemCard(
              imageUrl: testImageUrl,
              specificLocation: testLocation,
              name: testName,
              campus: testCampus,
              category: testCategoryLost,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final lostBadge = tester.widget<Container>(
        find.descendant(
          of: find.byType(ModernItemCard),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.child is Text &&
                (w.child as Text).data == testCategoryLost,
          ),
        ),
      );
      final lostBadgeDecoration = lostBadge.decoration as BoxDecoration;
      expect(
        (lostBadgeDecoration.color! as Color).red,
        greaterThan(100),
      ); // Should be reddish

      // Test Found badge color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: ModernItemCard(
              imageUrl: testImageUrl,
              specificLocation: testLocation,
              name: testName,
              campus: testCampus,
              category: testCategoryFound,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final foundBadge = tester.widget<Container>(
        find.descendant(
          of: find.byType(ModernItemCard),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.child is Text &&
                (w.child as Text).data == testCategoryFound,
          ),
        ),
      );
      final foundBadgeDecoration = foundBadge.decoration as BoxDecoration;
      expect(
        (foundBadgeDecoration.color! as Color).green,
        greaterThan(100),
      ); // Should be greenish
    });
  });
}

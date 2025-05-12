import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/features/auth/view/getstarted_screen.dart';

void main() {
  testWidgets('GetStartedScreen UI renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GetStartedScreen(),
      ),
    );

    // Verify key texts
    expect(find.text('Welcome to UniFind!'), findsOneWidget);
    expect(find.text('One Stop Solution To Lost Items!'), findsOneWidget);

    // Verify buttons
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Tapping Login navigates to /login', (WidgetTester tester) async {
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: GetStartedScreen(),
        navigatorObservers: [navObserver],
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login Page')),
        },
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('Tapping Sign Up navigates to /signup', (WidgetTester tester) async {
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: GetStartedScreen(),
        navigatorObservers: [navObserver],
        routes: {
          '/signup': (_) => const Scaffold(body: Text('Signup Page')),
        },
      ),
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Signup Page'), findsOneWidget);
  });
}

// Mock NavigatorObserver to confirm navigation
class _MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> _pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  List<Route<dynamic>> get pushedRoutes => _pushedRoutes;
}

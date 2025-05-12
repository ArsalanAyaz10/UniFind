import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:unifind/features/splash/view/splash_screen.dart';
void main() {
  testWidgets('SplashScreen displays animation and navigates after delay', (WidgetTester tester) async {
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(),
        navigatorObservers: [navObserver],
        routes: {
          '/started': (_) => const Scaffold(body: Text('Started Page')),
        },
      ),
    );

    // Check if Lottie animation is loaded
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);

    // Wait for 5 seconds simulated delay + some buffer
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify navigation happened
    expect(find.text('Started Page'), findsOneWidget);
  });
}

// Mock NavigatorObserver to track route pushes
class _MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> _pushedRoutes = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    _pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

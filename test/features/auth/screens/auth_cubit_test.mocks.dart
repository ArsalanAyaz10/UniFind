import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/bloc/auth_state.dart';
import 'package:unifind/features/auth/view/login_screen.dart';

import '../../../auth_cubit_test.mocks.mocks.dart';

@GenerateMocks([AuthCubit])
void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const LoginScreen(),
      ),
      routes: {
        '/home': (_) => const Scaffold(body: Text('Home Screen')),
        '/signup': (_) => const Scaffold(body: Text('Signup Screen')),
      },
    );
  }

  testWidgets('Displays loading and navigates to home on AuthSuccess', (
    tester,
  ) async {
    // Emit initial state
    whenListen(
      mockAuthCubit,
      Stream.fromIterable([AuthLoading(), AuthSuccess()]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(buildTestableWidget());

    // Enter valid email and password
    await tester.enterText(find.byType(TextFormField).at(0), 'test@szabist.pk');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap login button
    await tester.tap(find.text('Login'));
    await tester.pump(); // Start animation
    await tester.pump(); // Show loading dialog

    // Wait for state changes and navigation
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify home screen is displayed
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('Shows error message on AuthError', (tester) async {
    whenListen(
      mockAuthCubit,
      Stream.fromIterable([AuthLoading(), AuthError('Invalid credentials')]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(buildTestableWidget());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@szabist.pk');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');

    await tester.tap(find.text('Login'));
    await tester.pump(); // Show loading
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Expect SnackBar with error
    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('Navigates to Signup when Sign Up button is tapped', (
    tester,
  ) async {
    when(mockAuthCubit.state).thenReturn(AuthInitial());

    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text("Don't have an account? Sign Up"));
    await tester.pumpAndSettle();

    expect(find.text('Signup Screen'), findsOneWidget);
  });
}

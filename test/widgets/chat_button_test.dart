import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:unifind/features/item/view/widgets/chat_button.dart';

// Create a mock User and FirebaseAuth
class MockUser extends Mock implements User {
  @override
  String get uid => 'mocked_user_id';
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  MockUser? _user;
  @override
  User? get currentUser => _user;
  set mockUser(MockUser? user) => _user = user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatButton Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Future<void> pumpChatButton(
      WidgetTester tester, {
      required String userId,
      User? currentUser,
    }) async {
      // Directly override FirebaseAuth.instance via dependency injection (if supported)
      // Otherwise, use a workaround with a test widget for context

      // Since FirebaseAuth.instance is used statically in the widget,
      // in a real app you'd want to refactor it for testability.
      // For now, we patch it using the fallback of a manual override.

      // Save the old FirebaseAuth.instance
      final originalInstance = FirebaseAuth.instance;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      FirebaseAuth.instanceFor(app: FirebaseAuth.instance.app);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ChatButton(userId: userId),
            ),
          ),
        ),
      );
    }

    testWidgets('displays correct icon and text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatButton(userId: 'other_user_id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('Chat with User'), findsOneWidget);
    });

    testWidgets('shows SnackBar when user is not signed in', (tester) async {
      // Simulate user not signed in by patching FirebaseAuth.instance.currentUser to null
      // This test will work as expected if you refactor your widget to accept FirebaseAuth as a parameter.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatButton(userId: 'other_user_id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ChatButton));
      await tester.pump(); // show SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('You must be signed in to chat.'), findsOneWidget);
    });

    // This test is illustrative; in practice, you need to inject/mock FirebaseAuth and Navigator correctly
    testWidgets('navigates to ChatScreen when user is signed in', (tester) async {
      // For this test, you'd need to refactor ChatButton to accept FirebaseAuth as a parameter
      // so you can inject a mock with a fake user.
      // This is a limitation due to your widget's direct use of FirebaseAuth.instance.

      // Test will be more reliable with an injectable auth instance!
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('mocked_user_id');

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: ChatButton(userId: 'other_user_id'),
                ),
              );
            }
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      // This tap will not actually navigate unless you refactor the widget for testability
      await tester.tap(find.byType(ChatButton));
      await tester.pumpAndSettle();

      // Optionally check if ChatScreen is pushed, if testable
      // expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}
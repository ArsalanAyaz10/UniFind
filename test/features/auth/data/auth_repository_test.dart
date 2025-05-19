import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:unifind/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    authRepository = AuthRepository(mockFirebaseAuth, mockFirestore);
  });

  group('AuthRepository', () {
    const email = 'test@example.com';
    const password = 'password123';
    const name = 'Test User';
    const uid = 'abc123';

    test('signUp creates user and stores user data in firestore', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(uid);

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(uid)).thenReturn(mockDoc);
      when(mockDoc.set(any<Map<String, dynamic>>())).thenAnswer((_) async {});

      await authRepository.signUp(email, password, name);

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollection.doc(uid)).called(1);
      verify(mockDoc.set(argThat(isA<Map<String, dynamic>>()))).called(1);
    });

    test('login signs in and returns user data if exists', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // This is the fix for line 49: ensure currentUser is not null before .uid
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(uid);

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(uid)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn({
        'name': name,
        'email': email,
        'program': '',
        'studentId': '',
      });

      final user = await authRepository.login(email, password);

      expect(user, isNotNull);
      expect(user?.name, name);
      expect(user?.email, email);
    });

    test('login returns null if user is not logged in', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => MockUserCredential());

      // This test expects no user:
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final user = await authRepository.login(email, password);

      expect(user, isNull);
    });

    test('login returns null if user doc does not exist', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // Fix for line 49:
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(uid);

      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(uid)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);
      // Fix for line 56: always return a non-null map
      when(mockSnapshot.data()).thenReturn(<String, dynamic>{});

      final user = await authRepository.login(email, password);

      expect(user, isNull);
    });

    test('logout calls signOut', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authRepository.logout();

      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('resetPassword sends password reset email', () async {
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email)).thenAnswer((_) async {});

      await authRepository.resetPassword(email);

      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });
  });
}
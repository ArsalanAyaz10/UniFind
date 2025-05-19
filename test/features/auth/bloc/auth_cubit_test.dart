import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/auth/bloc/auth_state.dart';
import 'package:unifind/features/auth/data/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    const testName = "Test User";
    const testEmail = "test@example.com";
    const testPassword = "password123";

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] when signUp succeeds',
      build: () {
        when(mockAuthRepository.signUp(testEmail, testPassword, testName))
            .thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.signUp(
        name: testName,
        email: testEmail,
        password: testPassword,
      ),
      expect: () => [AuthLoading(), AuthSuccess()],
      verify: (_) {
        verify(mockAuthRepository.signUp(testEmail, testPassword, testName)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when signUp throws',
      build: () {
        when(mockAuthRepository.signUp(testEmail, testPassword, testName))
            .thenThrow(Exception("Sign up failed"));
        return authCubit;
      },
      act: (cubit) => cubit.signUp(
        name: testName,
        email: testEmail,
        password: testPassword,
      ),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Sign up failed')),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(mockAuthRepository.login(testEmail, testPassword))
            .thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.login(email: testEmail, password: testPassword),
      expect: () => [AuthLoading(), AuthSuccess()],
      verify: (_) {
        verify(mockAuthRepository.login(testEmail, testPassword)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when login throws',
      build: () {
        when(mockAuthRepository.login(testEmail, testPassword))
            .thenThrow(Exception("Login failed"));
        return authCubit;
      },
      act: (cubit) => cubit.login(email: testEmail, password: testPassword),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Login failed')),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthLoggedOut] when logout succeeds',
      build: () {
        when(mockAuthRepository.logout()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [AuthLoading(), AuthLoggedOut()],
      verify: (_) {
        verify(mockAuthRepository.logout()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when logout throws',
      build: () {
        when(mockAuthRepository.logout())
            .thenThrow(Exception("Logout failed"));
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Logout failed')),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, PasswordResetSuccess] when resetPassword succeeds',
      build: () {
        when(mockAuthRepository.resetPassword(testEmail)).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.resetPassword(email: testEmail),
      expect: () => [AuthLoading(), PasswordResetSuccess()],
      verify: (_) {
        verify(mockAuthRepository.resetPassword(testEmail)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when resetPassword throws',
      build: () {
        when(mockAuthRepository.resetPassword(testEmail))
            .thenThrow(Exception("Reset failed"));
        return authCubit;
      },
      act: (cubit) => cubit.resetPassword(email: testEmail),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Password reset failed')),
      ],
    );
  });
}
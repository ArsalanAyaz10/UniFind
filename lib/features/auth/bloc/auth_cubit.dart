import 'package:bloc/bloc.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(email, password, name);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await authRepository.login(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(email);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError('Password reset failed: ${e.toString()}'));
    }
  }

    String? getCurrentUserId() {
    return authRepository.firebaseAuth.currentUser?.uid;
  }
}

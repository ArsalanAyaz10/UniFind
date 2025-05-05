import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

  Future<void> login({
    required String email,
    required String password,
  }) async {
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

 Future<void> updateProfile({
  String? program,
  int? studentId,
}) async {
  emit(AuthLoading());
  try {
    final user = authRepository.firebaseAuth.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      emit(AuthError('No user is currently logged in.'));
      return;
    }

    await authRepository.updateProfile(uid, program: program, studentId: studentId);
    emit(AuthSuccess());
  } catch (e) {
    emit(AuthError('Update failed: ${e.toString()}'));
  }
}

}

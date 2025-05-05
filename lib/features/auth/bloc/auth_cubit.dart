import 'package:bloc/bloc.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

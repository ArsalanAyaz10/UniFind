import 'package:bloc/bloc.dart';
import 'package:unifind/core/models/user_model.dart';
import 'profile_state.dart';
import '../data/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit(this.profileRepository) : super(ProfileInitial());



    Future<void> fetchProfile(String uid) async {
    emit(ProfileLoading());
    try {
      AppUser? user = await profileRepository.fetchProfile(uid);
      emit(ProfileLoaded(user!));
    } catch (e) {
      emit(ProfileError('Fetch failed: ${e.toString()}'));
    }
  }

  Future<void> deleteAccount(String uid) async {
    emit(ProfileLoading());
    try {
      await profileRepository.deleteAccount(uid);
      emit(ProfileDeleted());
    } catch (e) {
      emit(ProfileError('Delete failed: ${e.toString()}'));
    }
  }
  Future<void> updateProfile({String? program, int? studentId}) async {
    emit(ProfileLoading());
    try {
      final user = profileRepository.firebaseAuth.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        emit(ProfileError('No user is currently logged in.'));
        return;
      }

      await profileRepository.updateProfile(
        uid,
        program: program,
        studentId: studentId,
      );
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError('Update failed: ${e.toString()}'));
    }
  }
}

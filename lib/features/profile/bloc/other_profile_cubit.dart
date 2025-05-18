import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/core/models/user_model.dart';
import 'profile_state.dart';
import '../data/profile_repository.dart';

class OtherProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  OtherProfileCubit(this.profileRepository) : super(ProfileInitial());

  Future<void> fetchUserById(String userId) async {
    emit(ProfileLoading());
    try {
      final user = await profileRepository.getUserById(userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to load user: ${e.toString()}'));
    }
  }
}
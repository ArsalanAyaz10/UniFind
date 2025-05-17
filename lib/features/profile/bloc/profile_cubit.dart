import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:unifind/core/models/user_model.dart';
import 'profile_state.dart';
import '../data/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit(this.profileRepository) : super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final user = profileRepository.firebaseAuth.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        emit(ProfileError('No user is currently logged in.'));
        return;
      }

      final userProfile = await profileRepository.fetchProfile(uid);
      if (userProfile != null) {
        emit(ProfileLoaded(userProfile));
      } else {
        emit(ProfileError('Profile not found.'));
      }
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

  Future<void> updateProfile({
    required String name,
    required String program,
    required int studentId,
  }) async {
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
        name: name,
        program: program,
        studentId: studentId,
      );
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError('Update failed: ${e.toString()}'));
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    emit(ProfileLoading());
    try {
      final uid = profileRepository.firebaseAuth.currentUser?.uid;
      if (uid == null) {
        emit(ProfileError('No user is currently logged in.'));
        return;
      }

      final url = await profileRepository.uploadProfilePicture(uid, imageFile);
      emit(ProfilePictureUpdated(url));

      // Optionally refresh full profile after upload
      final updatedUser = await profileRepository.fetchProfile(uid);
      if (updatedUser != null) {
        emit(ProfileLoaded(updatedUser));
      }
    } catch (e) {
      emit(ProfileError('Failed to upload profile picture: ${e.toString()}'));
    }
  }

  Future<void> fetchUserById(String userId) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepository.getUserById(userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to load user: ${e.toString()}'));
    }
  }
}

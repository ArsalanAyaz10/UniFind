import 'package:unifind/core/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {} // Initial state

class ProfileLoading extends ProfileState {} // Loading state

class ProfileSuccess extends ProfileState {} // When update succeeds

class ProfileLoaded extends ProfileState {
  // When profile data is loaded
  final AppUser user;

  ProfileLoaded(this.user);
}

class ProfilePictureUpdated extends ProfileState {
  final String imageUrl;
  ProfilePictureUpdated(this.imageUrl);
}

class ProfileDeleted extends ProfileState {} // When account is deleted

class ProfileError extends ProfileState {
  // On error
  final String message;

  ProfileError(this.message);
}

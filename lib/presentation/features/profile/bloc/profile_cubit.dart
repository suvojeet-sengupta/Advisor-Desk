import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

/// The state for the [ProfileCubit].
///
/// Contains the user's [profile] information and a flag [isEditing]
/// to indicate if the profile is currently being edited.
class ProfileState extends Equatable {
  /// The user's profile data.
  final Profile profile;

  /// A flag to indicate if the profile is being edited.
  final bool isEditing;

  /// Creates a [ProfileState].
  const ProfileState(this.profile, {required this.isEditing});

  @override
  List<Object?> get props => [profile, isEditing];

  /// Creates a copy of the current [ProfileState] with the given fields replaced.
  ProfileState copyWith({
    Profile? profile,
    bool? isEditing,
  }) {
    return ProfileState(
      profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

/// A [Cubit] that manages the state of the user's profile.
///
/// It interacts with the [ProfileRepository] to load and save profile data.
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  /// Creates a [ProfileCubit].
  ///
  /// It requires a [ProfileRepository] to function and immediately
  /// triggers the loading of the profile.
  ProfileCubit(this._repository)
      : super(ProfileState(Profile.initial(), isEditing: true)) {
    _loadProfile();
  }

  /// Loads the user's profile from the repository.
  void _loadProfile() async {
    final profile = await _repository.getProfile();
    emit(ProfileState(profile, isEditing: profile.name == null));
  }

  /// Updates the profile picture path in the state.
  void updateProfilePicture(String path) {
    final newProfile = state.profile.copyWith(profilePicturePath: path);
    emit(state.copyWith(profile: newProfile));
  }

  /// Saves the user's profile to the repository.
  void saveProfile(Profile profile) async {
    await _repository.saveProfile(profile);
    emit(ProfileState(profile, isEditing: false));
  }

  /// Sets the editing mode for the profile.
  void setEditing(bool isEditing) {
    emit(state.copyWith(isEditing: isEditing));
  }
}

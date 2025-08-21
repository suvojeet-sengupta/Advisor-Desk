import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

class ProfileState extends Equatable {
  final Profile profile;
  final bool isEditing;

  const ProfileState(this.profile, {required this.isEditing});

  @override
  List<Object?> get props => [profile, isEditing];

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

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileState(Profile.initial(), isEditing: true)) {
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await _repository.getProfile();
    emit(ProfileState(profile, isEditing: profile.name == null));
  }

  void updateProfilePicture(String path) {
    final newProfile = state.profile.copyWith(profilePicturePath: path);
    emit(state.copyWith(profile: newProfile));
  }

  void saveProfile(Profile profile) async {
    await _repository.saveProfile(profile);
    emit(ProfileState(profile, isEditing: false));
  }

  void setEditing(bool isEditing) {
    emit(state.copyWith(isEditing: isEditing));
  }
}

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

  String _currentUserId = '1';

  ProfileCubit(this._repository) : super(ProfileState(Profile.initial(), isEditing: true)) {
    loadProfile();
  }

  Future<void> loadProfile({String? userId}) async {
    _currentUserId = userId ?? '1';
    final profile = await _repository.getProfile(userId: userId);
    emit(ProfileState(profile, isEditing: profile.name == null));
  }

  void updateProfilePicture(String path) {
    final newProfile = state.profile.copyWith(profilePicturePath: path);
    emit(state.copyWith(profile: newProfile));
  }

  void saveProfile(Profile profile, {String? userId}) async {
    final targetUserId = userId ?? _currentUserId;
    await _repository.saveProfile(profile, userId: targetUserId);
    emit(ProfileState(profile, isEditing: false));
  }

  void setEditing(bool isEditing) {
    emit(state.copyWith(isEditing: isEditing));
  }
}

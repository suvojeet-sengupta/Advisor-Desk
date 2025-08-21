import 'package:bloc/bloc.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<Profile> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(Profile.initial()) {
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await _repository.getProfile();
    emit(profile);
  }

  void updateProfilePicture(String path) {
    final newProfile = state.copyWith(profilePicturePath: path);
    emit(newProfile);
  }

  void saveProfile(Profile profile) async {
    await _repository.saveProfile(profile);
    emit(profile);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<Profile> {
  final ProfileRepository repository;

  ProfileCubit(this.repository) : super(Profile.initial()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await repository.getProfile();
    emit(profile);
  }

  Future<void> saveProfile(Profile profile) async {
    await repository.saveProfile(profile);
    emit(profile);
  }

  void updateProfilePicture(String path) {
    final newProfile = state.copyWith(profilePicturePath: path);
    saveProfile(newProfile);
  }
}

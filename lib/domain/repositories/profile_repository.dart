
import 'package:advisor_desk/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<void> saveProfile(Profile profile);
  Future<Profile> getProfile();
}

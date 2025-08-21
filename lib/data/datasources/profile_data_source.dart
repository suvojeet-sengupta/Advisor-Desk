
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/profile.dart';

class ProfileDataSource {
  static const _nameKey = 'profile_name';
  static const _companyKey = 'profile_company';
  static const _picturePathKey = 'profile_picture_path';

  Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (profile.name != null) {
      await prefs.setString(_nameKey, profile.name!);
    } else {
      await prefs.remove(_nameKey);
    }
    if (profile.companyName != null) {
      await prefs.setString(_companyKey, profile.companyName!);
    } else {
      await prefs.remove(_companyKey);
    }
    await prefs.setString(_picturePathKey, profile.profilePicturePath);
  }

  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? '';
    final companyName = prefs.getString(_companyKey) ?? '';
    final picturePath = prefs.getString(_picturePathKey) ?? '';
    return Profile(
      name: name,
      companyName: companyName,
      profilePicturePath: picturePath,
    );
  }
}

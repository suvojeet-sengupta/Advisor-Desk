
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/profile.dart';

class ProfileDataSource {
  static const _nameKey = 'profile_name';
  static const _companyKey = 'profile_company';
  static const _picturePathKey = 'profile_picture_path';

  Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_companyKey, profile.companyName);
    await prefs.setString(_picturePathKey, profile.profilePicturePath);
  }

  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? 'Your Name';
    final companyName = prefs.getString(_companyKey) ?? 'Your Company';
    final picturePath = prefs.getString(_picturePathKey) ?? '';
    return Profile(
      name: name,
      companyName: companyName,
      profilePicturePath: picturePath,
    );
  }
}

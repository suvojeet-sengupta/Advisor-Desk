import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/profile.dart';

/// A data source for managing user profile data using [SharedPreferences].
///
/// This class provides methods to save and retrieve the user's profile,
/// which includes their name, company name, and profile picture path.
class ProfileDataSource {
  static const _nameKey = 'profile_name';
  static const _companyKey = 'profile_company';
  static const _picturePathKey = 'profile_picture_path';

  /// Saves the user's profile data to [SharedPreferences].
  ///
  /// The [profile] object contains the data to be saved.
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

  /// Retrieves the user's profile data from [SharedPreferences].
  ///
  /// Returns a [Future] that completes with a [Profile] object.
  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final companyName = prefs.getString(_companyKey);
    final picturePath = prefs.getString(_picturePathKey) ?? '';
    return Profile(
      name: name,
      companyName: companyName,
      profilePicturePath: picturePath,
    );
  }
}

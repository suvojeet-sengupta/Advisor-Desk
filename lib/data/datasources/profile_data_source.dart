
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/profile.dart';

class ProfileDataSource {
  static const _nameKey = 'profile_name';
  static const _companyKey = 'profile_company';
  static const _picturePathKey = 'profile_picture_path';

  Future<void> saveProfile(Profile profile, {String userId = '1'}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = userId == '1' ? '' : '${userId}_';
    
    if (profile.name != null) {
      await prefs.setString('$prefix$_nameKey', profile.name!);
    } else {
      await prefs.remove('$prefix$_nameKey');
    }
    if (profile.companyName != null) {
      await prefs.setString('$prefix$_companyKey', profile.companyName!);
    } else {
      await prefs.remove('$prefix$_companyKey');
    }
    await prefs.setString('$prefix$_picturePathKey', profile.profilePicturePath);
  }

  Future<Profile> getProfile({String userId = '1'}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = userId == '1' ? '' : '${userId}_';
    
    final name = prefs.getString('$prefix$_nameKey');
    final companyName = prefs.getString('$prefix$_companyKey');
    final picturePath = prefs.getString('$prefix$_picturePathKey') ?? '';
    return Profile(
      name: name,
      companyName: companyName,
      profilePicturePath: picturePath,
    );
  }
}

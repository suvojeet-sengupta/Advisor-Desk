import 'package:advisor_desk/domain/entities/profile.dart';

/// An abstract repository for managing the user's profile.
///
/// This class defines the contract for saving and retrieving the user's profile data.
abstract class ProfileRepository {
  /// Saves the user's profile.
  ///
  /// The [profile] is the [Profile] object to be saved.
  Future<void> saveProfile(Profile profile);

  /// Retrieves the user's profile.
  Future<Profile> getProfile();
}

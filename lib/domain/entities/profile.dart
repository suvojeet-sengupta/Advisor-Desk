import 'package:equatable/equatable.dart';

/// Represents a user's profile information.
///
/// This class encapsulates the user's name, company name, and the path to their
/// profile picture.
class Profile extends Equatable {
  /// The name of the user.
  final String? name;
  /// The name of the user's company.
  final String? companyName;
  /// The local file path to the user's profile picture.
  final String profilePicturePath;

  /// Creates a new instance of [Profile].
  const Profile({
    this.name,
    this.companyName,
    required this.profilePicturePath,
  });

  /// Creates an initial, empty [Profile] object.
  factory Profile.initial() {
    return const Profile(
      name: null,
      companyName: null,
      profilePicturePath: '',
    );
  }

  /// Creates a copy of this [Profile] but with the given fields replaced with new values.
  Profile copyWith({
    String? name,
    String? companyName,
    String? profilePicturePath,
  }) {
    return Profile(
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }

  @override
  List<Object?> get props => [name, companyName, profilePicturePath];
}
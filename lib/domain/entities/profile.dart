
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String? name;
  final String? companyName;
  final String profilePicturePath;

  const Profile({
    this.name,
    this.companyName,
    required this.profilePicturePath,
  });

  factory Profile.initial() {
    return const Profile(
      name: '',
      companyName: '',
      profilePicturePath: '',
    );
  }

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

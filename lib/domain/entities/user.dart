class AppUser {
  final String id;
  final String name;
  final String profilePicturePath;

  AppUser({
    required this.id,
    required this.name,
    required this.profilePicturePath,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? profilePicturePath,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePicturePath': profilePicturePath,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      profilePicturePath: map['profilePicturePath'] ?? '',
    );
  }
}

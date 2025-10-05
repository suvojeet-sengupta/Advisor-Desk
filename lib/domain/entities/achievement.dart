import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final bool unlocked;
  final DateTime? unlockedDate;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.unlocked = false,
    this.unlockedDate,
  });

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedDate,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      imagePath: imagePath,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  @override
  List<Object?> get props => [id, name, description, imagePath, unlocked, unlockedDate];
}
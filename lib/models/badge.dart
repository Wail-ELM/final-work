import 'package:hive/hive.dart';

part 'badge.g.dart';

@HiveType(typeId: 6) // Ensure the typeId is unique
class Badge {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconName; // e.g., 'star', 'local_fire_department'

  @HiveField(4)
  final DateTime dateEarned;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.dateEarned,
  });
}

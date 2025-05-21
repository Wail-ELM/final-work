import 'package:hive/hive.dart';
part 'challenge.g.dart';

@HiveType(typeId: 0)
class Challenge {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String description;
  @HiveField(3) final int xpReward;
  @HiveField(4) bool isDone;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    this.isDone = false,
  });
}

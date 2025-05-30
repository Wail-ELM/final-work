// lib/models/challenge_category_adapter.dart
import 'package:hive/hive.dart';

part 'challenge_category_adapter.g.dart';

@HiveType(typeId: 5)
enum ChallengeCategory {
  @HiveField(0)
  screenTime,
  @HiveField(1)
  focus,
  @HiveField(2)
  notifications,
}

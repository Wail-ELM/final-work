import 'package:hive/hive.dart';
part 'mood_entry.g.dart';

@HiveType(typeId: 1)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final int moodValue;
  @HiveField(3)
  final String? note;
  @HiveField(4)
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodValue,
    this.note,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      moodValue: json['mood_value'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood_value': moodValue,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodValue,
    String? note,
    DateTime? createdAt,
  }) =>
      MoodEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        moodValue: moodValue ?? this.moodValue,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() =>
      'MoodEntry(id: $id, userId: $userId, moodValue: $moodValue, note: $note, createdAt: $createdAt)';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          id == other.id &&
          userId == other.userId &&
          moodValue == other.moodValue &&
          note == other.note &&
          createdAt == other.createdAt;
  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      moodValue.hashCode ^
      (note?.hashCode ?? 0) ^
      createdAt.hashCode;
}

import 'package:hive/hive.dart';
part 'mood_entry.g.dart';

@HiveType(typeId: 1)
class MoodEntry extends HiveObject {
  @HiveField(0) final DateTime date;
  @HiveField(1) final String emoji;
  @HiveField(2) final String? note;
  @HiveField(3) final int value;
  @HiveField(4) final String? id;

  MoodEntry({
    required this.date,
    required this.emoji,
    required this.value,
    this.note,
    this.id,
  });

  MoodEntry copyWith({
    DateTime? date,
    String? emoji,
    String? note,
    int? value,
    String? id,
  }) =>
      MoodEntry(
        date: date ?? this.date,
        emoji: emoji ?? this.emoji,
        value: value ?? this.value,
        note: note ?? this.note,
        id: id ?? this.id,
      );

  @override
  String toString() =>
      'MoodEntry(date: $date, emoji: $emoji, value: $value, note: $note, id: $id)';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          date == other.date &&
          emoji == other.emoji &&
          value == other.value &&
          note == other.note &&
          id == other.id;
  @override
  int get hashCode =>
      date.hashCode ^ emoji.hashCode ^ value.hashCode ^ (note?.hashCode ?? 0) ^ (id?.hashCode ?? 0);
}

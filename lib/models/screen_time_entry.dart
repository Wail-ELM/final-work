import 'package:hive/hive.dart';

part 'screen_time_entry.g.dart';

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 3;

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}

@HiveType(typeId: 4)
class ScreenTimeEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String appName;

  @HiveField(3)
  final Duration duration;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final DateTime createdAt;

  ScreenTimeEntry({
    required this.id,
    required this.userId,
    required this.appName,
    required this.duration,
    required this.date,
    required this.createdAt,
  });

  factory ScreenTimeEntry.fromJson(Map<String, dynamic> json) {
    return ScreenTimeEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      duration: Duration(seconds: json['duration'] as int),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'app_name': appName,
      'duration': duration.inSeconds,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  ScreenTimeEntry copyWith({
    String? id,
    String? userId,
    String? appName,
    Duration? duration,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ScreenTimeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appName: appName ?? this.appName,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'ScreenTimeEntry(id: $id, userId: $userId, appName: $appName, duration: $duration, date: $date, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenTimeEntry &&
          id == other.id &&
          userId == other.userId &&
          appName == other.appName &&
          duration == other.duration &&
          date == other.date &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      appName.hashCode ^
      duration.hashCode ^
      date.hashCode ^
      createdAt.hashCode;
}

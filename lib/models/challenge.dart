import 'package:hive/hive.dart';
import 'challenge_category_adapter.dart';

part 'challenge.g.dart';

@HiveType(typeId: 0)
class Challenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final ChallengeCategory category;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final bool isDone;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  Challenge({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.startDate,
    this.endDate,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: ChallengeCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isDone: json['is_done'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_done': isDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Challenge copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ChallengeCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Challenge(id: $id, userId: $userId, title: $title, description: $description, category: $category, startDate: $startDate, endDate: $endDate, isDone: $isDone, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Challenge &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          isDone == other.isDone &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      (description?.hashCode ?? 0) ^
      category.hashCode ^
      startDate.hashCode ^
      (endDate?.hashCode ?? 0) ^
      isDone.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}

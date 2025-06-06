// lib/models/challenge_category_adapter.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'challenge_category_adapter.g.dart';

@HiveType(typeId: 2)
enum ChallengeCategory {
  @HiveField(0)
  screenTime,
  @HiveField(1)
  focus,
  @HiveField(2)
  notifications,
}

extension ChallengeCategoryExtension on ChallengeCategory {
  String get displayName {
    switch (this) {
      case ChallengeCategory.screenTime:
        return 'Schermtijd';
      case ChallengeCategory.focus:
        return 'Focus';
      case ChallengeCategory.notifications:
        return 'Notificaties';
      default:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case ChallengeCategory.screenTime:
        return Icons.phone_android;
      case ChallengeCategory.focus:
        return Icons.center_focus_strong;
      case ChallengeCategory.notifications:
        return Icons.notifications_off;
      default:
        return Icons.help;
    }
  }
}

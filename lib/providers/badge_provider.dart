import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/models/badge.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
import 'package:social_balans/providers/challenge_provider.dart';

// Represents the definition of a badge that can be earned.
class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool Function(List<Challenge> completed) condition;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.condition,
  });
}

// List of all badges that can be earned in the app.
final allBadgeDefinitions = <BadgeDefinition>[
  BadgeDefinition(
    id: 'first_step',
    title: 'Eerste Stap',
    description: 'Je hebt je eerste uitdaging voltooid!',
    iconName: 'footprint', // Example icon name
    condition: (completed) => completed.isNotEmpty,
  ),
  BadgeDefinition(
    id: 'unstoppable_5',
    title: 'Onstuitbaar',
    description: 'Voltooi 5 uitdagingen.',
    iconName: 'local_fire_department',
    condition: (completed) => completed.length >= 5,
  ),
  BadgeDefinition(
    id: 'master_10',
    title: 'Uitdagingsmeester',
    description: 'Voltooi 10 uitdagingen.',
    iconName: 'military_tech',
    condition: (completed) => completed.length >= 10,
  ),
  BadgeDefinition(
    id: 'focus_fanatic',
    title: 'Focus Fanaat',
    description: 'Voltooi 3 uitdagingen in de categorie Focus.',
    iconName: 'center_focus_strong',
    condition: (completed) =>
        completed.where((c) => c.category == ChallengeCategory.focus).length >=
        3,
  ),
  BadgeDefinition(
    id: 'screen_time_slayer',
    title: 'Schermtijd Krijger',
    description: 'Voltooi 3 uitdagingen in de categorie Schermtijd.',
    iconName: 'phone_android',
    condition: (completed) =>
        completed
            .where((c) => c.category == ChallengeCategory.screenTime)
            .length >=
        3,
  ),
];

// Notifier to manage the list of earned badges.
class BadgeNotifier extends StateNotifier<List<Badge>> {
  BadgeNotifier() : super([]) {
    _loadBadges();
  }

  final _box = Hive.box<Badge>('badges');

  void _loadBadges() {
    state = _box.values.toList();
  }

  Future<void> addBadge(Badge badge) async {
    if (state.any((b) => b.id == badge.id)) return; // Already earned
    await _box.put(badge.id, badge);
    state = [...state, badge];
  }
}

// Provider for the earned badges.
final badgesProvider = StateNotifierProvider<BadgeNotifier, List<Badge>>((ref) {
  return BadgeNotifier();
});

// A controller provider that listens to challenge changes and awards badges.
// This provider doesn't return a value but handles the logic.
final badgeControllerProvider = Provider<void>((ref) {
  ref.listen<List<Challenge>>(allChallengesProvider, (previous, next) {
    final previouslyCompleted = previous?.where((c) => c.isDone).toList() ?? [];
    final nowCompleted = next.where((c) => c.isDone).toList();

    // If a new challenge has been completed
    if (nowCompleted.length > previouslyCompleted.length) {
      final earnedBadges = ref.read(badgesProvider);

      for (final def in allBadgeDefinitions) {
        // If the user doesn't have this badge yet
        if (!earnedBadges.any((b) => b.id == def.id)) {
          // Check if the condition is now met
          if (def.condition(nowCompleted)) {
            final newBadge = Badge(
              id: def.id,
              title: def.title,
              description: def.description,
              iconName: def.iconName,
              dateEarned: DateTime.now(),
            );
            // Add the badge
            ref.read(badgesProvider.notifier).addBadge(newBadge);
            // Here you could also trigger a notification/dialog
          }
        }
      }
    }
  });
});
 
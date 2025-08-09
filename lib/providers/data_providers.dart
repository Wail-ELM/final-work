import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/models/challenge.dart';
import '../models/mood_entry.dart';

// IMPORTANT: This file is deprecated for TFE scope.
// Use the dedicated providers in `challenge_provider.dart` and `mood_provider.dart`.
// Left in place only to avoid breaking legacy imports. Will be removed in a cleanup phase.

@Deprecated('Use challenge_provider.dart -> allChallengesProvider')
final challengesBoxProvider =
    Provider<Box<Challenge>>((ref) => Hive.box<Challenge>('challenges'));
@Deprecated('Use mood_provider.dart providers instead')
final moodsBoxProvider =
    Provider<Box<MoodEntry>>((ref) => Hive.box<MoodEntry>('moods'));

@Deprecated('Replaced by ChallengesNotifier in challenge_provider.dart with server sync')
class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier(this._box) : super(_box.values.toList());
  final Box<Challenge> _box;
  void toggleDone(Challenge c) {
    final updatedChallenge = c.copyWith(isDone: !c.isDone);
    _box.put(updatedChallenge.id, updatedChallenge);
    state = _box.values.toList();
  }
  void add(Challenge c) {
    _box.put(c.id, c);
    state = _box.values.toList();
  }
}

@Deprecated('Use allChallengesProvider instead')
final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengesBoxProvider);
  return ChallengesNotifier(box);
});

@Deprecated('Replaced by MoodsNotifier in mood_provider.dart with server sync')
class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier(this._box) : super(_box.values.toList());
  final Box<MoodEntry> _box;
  void add(MoodEntry m) {
    _box.add(m);
    state = _box.values.toList();
  }
}

@Deprecated('Use moodsProvider in mood_provider.dart')
final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<MoodEntry>>((ref) {
  final box = ref.watch(moodsBoxProvider);
  return MoodsNotifier(box);
});

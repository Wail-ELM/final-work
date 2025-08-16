import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/models/challenge.dart';
import '../models/mood_entry.dart';

// Box Providers
final challengesBoxProvider =
    Provider<Box<Challenge>>((ref) => Hive.box<Challenge>('challenges'));

final moodsBoxProvider =
    Provider<Box<MoodEntry>>((ref) => Hive.box<MoodEntry>('moods'));

// State Notifier pour la liste de challenges
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

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengesBoxProvider);
  return ChallengesNotifier(box);
});

// State Notifier pour les mood entries
class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier(this._box) : super(_box.values.toList());
  final Box<MoodEntry> _box;

  void add(MoodEntry m) {
    _box.add(m);
    state = _box.values.toList();
  }
}

final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<MoodEntry>>((ref) {
  final box = ref.watch(moodsBoxProvider);
  return MoodsNotifier(box);
});

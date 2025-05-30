import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/challenge.dart';

final challengesBoxProvider =
    Provider<Box<Challenge>>((ref) => Hive.box<Challenge>('challenges'));

final allChallengesProvider =
    StateNotifierProvider<ChallengesListNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengesBoxProvider);
  return ChallengesListNotifier(box);
});

class ChallengesListNotifier extends StateNotifier<List<Challenge>> {
  ChallengesListNotifier(this._box) : super(_box.values.toList()) {
    _box.watch().listen((_) => state = _box.values.toList());
  }
  final Box<Challenge> _box;

  Future<void> add(Challenge c) async {
    await _box.put(c.id, c);
    state = _box.values.toList();
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }
}

final challengeProvider =
    StateNotifierProvider.family<ChallengeNotifier, Challenge, String>(
        (ref, id) {
  final box = ref.watch(challengesBoxProvider);
  return ChallengeNotifier(box, id);
});

class ChallengeNotifier extends StateNotifier<Challenge> {
  ChallengeNotifier(this._box, String id) : super(_box.get(id)!);
  final Box<Challenge> _box;

  Future<void> toggleDone() async {
    final updatedChallenge = state.copyWith(isDone: !state.isDone);
    await _box.put(updatedChallenge.id, updatedChallenge);
    state = updatedChallenge;
  }

  Future<void> markDone() async {
    if (!state.isDone) {
      final updatedChallenge = state.copyWith(isDone: true);
      await _box.put(updatedChallenge.id, updatedChallenge);
      state = updatedChallenge;
    }
  }
}

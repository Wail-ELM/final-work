import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/challenge.dart';
import '../services/auth_service.dart';
import '../services/demo_data_service.dart';

final challengeBoxProvider = Provider<Box<Challenge>>((ref) {
  return Hive.box<Challenge>('challenges');
});

// Provider pour tous les challenges de l'utilisateur actuel
final allChallengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengeBoxProvider);
  final authService = ref.watch(authServiceProvider);
  return ChallengesNotifier(box, authService);
});

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier(this._box, this._authService) : super([]) {
    _loadChallenges();
    _box.watch().listen((_) => _loadChallenges());
  }

  final Box<Challenge> _box;
  final AuthService _authService;

  void _loadChallenges() {
    final currentUser = _authService.currentUser;

    // Mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      final demoChallenges = DemoDataService.generateDemoChallenges();
      final List<Challenge> finalChallenges = [];
      for (final demoChallenge in demoChallenges) {
        final updatedChallenge = _box.get(demoChallenge.id);
        finalChallenges.add(updatedChallenge ?? demoChallenge);
      }
      state = finalChallenges;
      return;
    }

    final userChallenges = _box.values
        .where((challenge) => challenge.userId == currentUser.id)
        .toList();
    userChallenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = userChallenges;
  }

  Future<void> add(Challenge challenge) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }
    await _box.put(challenge.id, challenge);
    // _loadChallenges() is called by the watcher, no need to call it manually.
  }

  Future<void> remove(String id) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }
    await _box.delete(id);
  }

  Future<void> update(Challenge challenge) async {
    await _box.put(challenge.id, challenge);
  }

  Future<void> toggleDone(String challengeId) async {
    final challenge = state.firstWhere((c) => c.id == challengeId,
        orElse: () => _box.get(challengeId)!);

    final updatedChallenge = challenge.copyWith(
      isDone: !challenge.isDone,
      updatedAt: DateTime.now(),
    );
    await update(updatedChallenge);
  }

  void refresh() {
    _loadChallenges();
  }
}

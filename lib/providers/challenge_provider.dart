import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/services/auth_service.dart';
import 'package:social_balans/services/user_data_service.dart';
import 'package:social_balans/services/demo_data_service.dart';
// Removed demo data injection: offline mode now uses only real local data

final challengeBoxProvider = Provider<Box<Challenge>>((ref) {
  return Hive.box<Challenge>('challenges');
});

// Provider pour tous les challenges de l'utilisateur actuel
final allChallengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengeBoxProvider);
  final authService = ref.watch(authServiceProvider);
  final userData = ref.watch(userDataServiceProvider);
  return ChallengesNotifier(box, authService, userData);
});

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier(this._box, this._authService, this._userData) : super([]) {
    _init();
    _watchSub = _box.watch().listen((_) => _loadLocal());
  }

  final Box<Challenge> _box;
  final AuthService _authService;
  final UserDataService _userData;
  late final StreamSubscription _watchSub;

  @override
  void dispose() {
    _watchSub.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await _syncFromRemote();
    _loadLocal();
  }

  void _loadLocal() {
    final currentUser = _authService.currentUser;
    final String effectiveUserId =
        currentUser?.id ?? DemoDataService.demoUserId;

    final userChallenges = _box.values
        .where((challenge) => challenge.userId == effectiveUserId)
        .toList();
    userChallenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = userChallenges;
  }

  Future<void> _syncFromRemote() async {
    final user = _authService.currentUser;
    if (user == null) return; // offline: keep local
    try {
      final remote = await _userData.getChallenges(userId: user.id);
      // Replace local cache for this user
      // Option: only upsert current user's entries
      final keysToDelete = _box.values
          .where((c) => c.userId == user.id)
          .map((c) => c.key)
          .toList();
      await _box.deleteAll(keysToDelete);
      for (final c in remote) {
        await _box.put(c.id, c);
      }
    } catch (e) {
      // keep local if remote fails
    }
  }

  Future<void> add(Challenge challenge) async {
    await _box.put(challenge.id, challenge);
    // Sync to remote if logged in
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _userData.addChallenge(
          userId: challenge.userId,
          id: challenge.id,
          title: challenge.title,
          description: challenge.description ?? '',
          category: challenge.category.toString().split('.').last,
          startDate: challenge.startDate,
          endDate: challenge.endDate,
          isDone: challenge.isDone,
          createdAt: challenge.createdAt,
          updatedAt: challenge.updatedAt,
        );
      } catch (_) {}
    }
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _userData.deleteChallenge(challengeId: id);
      } catch (_) {}
    }
  }

  Future<void> update(Challenge challenge) async {
    await _box.put(challenge.id, challenge);
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _userData.updateChallenge(
          challengeId: challenge.id,
          title: challenge.title,
          description: challenge.description,
          category: challenge.category.toString().split('.').last,
          endDate: challenge.endDate,
          isDone: challenge.isDone,
        );
      } catch (_) {}
    }
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
    _loadLocal();
    _syncFromRemote();
  }
}

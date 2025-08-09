import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/models/challenge.dart';
import '../services/demo_data_service.dart';
import './auth_provider.dart';
import '../services/auth_service.dart';
import '../services/user_data_service.dart';

final challengeBoxProvider = Provider<Box<Challenge>>((ref) {
  // Try test box first if exists
  if (Hive.isBoxOpen('challenges_test')) {
    return Hive.box<Challenge>('challenges_test');
  }
  return Hive.box<Challenge>('challenges');
});

// Provider pour tous les challenges de l'utilisateur actuel
final allChallengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  final box = ref.watch(challengeBoxProvider);
  final authService = ref.watch(authServiceProvider);
  final userDataService = ref.watch(userDataServiceProvider);
  final enableInitialSync = ref.watch(enableChallengesInitialSyncProvider);
  return ChallengesNotifier(ref, box, authService, userDataService,
      enableInitialSync: enableInitialSync);
});

final challengeErrorProvider = StateProvider<String?>((ref) => null);
final enableChallengesInitialSyncProvider = Provider<bool>((_) => true);

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier(
      this._ref, this._box, this._authService, this._userDataService,
      {bool enableInitialSync = true})
      : _enableInitialSync = enableInitialSync,
        super([]) {
    _loadChallenges();
    _box.watch().listen((_) => _loadChallenges());
    if (_enableInitialSync) {
      _loadFromSupabase();
    }
  }

  final Ref _ref;
  final Box<Challenge> _box;
  final AuthService _authService;
  final UserDataService _userDataService;
  final bool _enableInitialSync;

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

  void _setError(String message) {
    _ref.read(challengeErrorProvider.notifier).state = message;
  }

  Future<void> _loadFromSupabase() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }
    try {
      final remote =
          await _userDataService.getChallenges(userId: currentUser.id);

      // Replace only current user's challenges in Hive by remote truth
      final idsToDelete = _box.values
          .where((c) => c.userId == currentUser.id)
          .map((c) => c.id)
          .toList();
      for (final id in idsToDelete) {
        await _box.delete(id);
      }
      for (final ch in remote) {
        await _box.put(ch.id, ch);
      }

      _loadChallenges();
    } catch (e) {
      _setError('Synchronisatie mislukt (server laden)');
    }
  }

  Future<void> add(Challenge challenge) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }
    await _box.put(challenge.id, challenge);
    // Debug print for tests
    // ignore: avoid_print
    print(
        'Challenge added locally: id=${challenge.id} keys=${_box.keys.toList()}');
    try {
      await _userDataService.addChallenge(
        id: challenge.id,
        userId: challenge.userId,
        title: challenge.title,
        description: challenge.description ?? '',
        category: challenge.category.toString().split('.').last,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
        isDone: challenge.isDone,
        createdAt: challenge.createdAt,
        updatedAt: challenge.updatedAt,
      );
    } catch (e) {
      _setError('Uitdaging lokaal opgeslagen, sync mislukt');
    }
  }

  Future<void> remove(String id) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    // Remote delete first
    try {
      await _userDataService.deleteChallenge(id: id);
    } catch (e) {
      _setError('Verwijderen mislukt op server');
    }

    await _box.delete(id);
  }

  Future<void> update(Challenge challenge) async {
    // Local update
    await _box.put(challenge.id, challenge);

    // Remote update if applicable
    final currentUser = _authService.currentUser;
    if (currentUser != null && !DemoDataService.isDemoMode(currentUser.id)) {
      try {
        await _userDataService.updateChallenge(
          challengeId: challenge.id,
          title: challenge.title,
          description: challenge.description,
          category: challenge.category.toString().split('.').last,
          endDate: challenge.endDate,
          isDone: challenge.isDone,
        );
      } catch (e) {
        _setError('Bijwerken mislukt (server)');
      }
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
    _loadChallenges();
    _loadFromSupabase();
  }
}

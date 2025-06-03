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
      state = DemoDataService.generateDemoChallenges();
      return;
    }

    // Filtrer les challenges pour l'utilisateur actuel
    final userChallenges = _box.values
        .where((challenge) => challenge.userId == currentUser.id)
        .toList();

    // Trier par date de création (plus récent en premier)
    userChallenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = userChallenges;
  }

  Future<void> add(Challenge challenge) async {
    final currentUser = _authService.currentUser;

    // Pas d'ajout en mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    await _box.put(challenge.id, challenge);
    _loadChallenges();
  }

  Future<void> remove(String id) async {
    final currentUser = _authService.currentUser;

    // Pas de suppression en mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    await _box.delete(id);
    _loadChallenges();
  }

  Future<void> update(Challenge challenge) async {
    final currentUser = _authService.currentUser;

    // Pas de modification en mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    await _box.put(challenge.id, challenge);
    _loadChallenges();
  }

  void refresh() {
    _loadChallenges();
  }
}

// Provider pour un challenge spécifique
final challengeProvider =
    StateNotifierProvider.family<ChallengeNotifier, Challenge?, String>(
        (ref, id) {
  final challenges = ref.watch(allChallengesProvider);
  final challenge = challenges.where((c) => c.id == id).firstOrNull;
  final authService = ref.watch(authServiceProvider);
  return ChallengeNotifier(challenge, authService, ref);
});

class ChallengeNotifier extends StateNotifier<Challenge?> {
  ChallengeNotifier(this._challenge, this._authService, this._ref)
      : super(_challenge);

  final Challenge? _challenge;
  final AuthService _authService;
  final Ref _ref;

  Future<void> toggleDone() async {
    if (state == null) return;

    final currentUser = _authService.currentUser;

    // Pas de modification en mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    final updatedChallenge = Challenge(
      id: state!.id,
      userId: state!.userId,
      title: state!.title,
      description: state!.description,
      category: state!.category,
      startDate: state!.startDate,
      endDate: state!.endDate,
      createdAt: state!.createdAt,
      updatedAt: DateTime.now(),
      isDone: !state!.isDone,
    );

    state = updatedChallenge;

    // Mettre à jour dans Hive
    final box = Hive.box<Challenge>('challenges');
    await box.put(updatedChallenge.id, updatedChallenge);

    // Rafraîchir la liste globale
    _ref.read(allChallengesProvider.notifier).refresh();
  }

  Future<void> updateChallenge(Challenge newChallenge) async {
    final currentUser = _authService.currentUser;

    // Pas de modification en mode démo
    if (currentUser == null || DemoDataService.isDemoMode(currentUser.id)) {
      return;
    }

    state = newChallenge;

    final box = Hive.box<Challenge>('challenges');
    await box.put(newChallenge.id, newChallenge);

    _ref.read(allChallengesProvider.notifier).refresh();
  }
}

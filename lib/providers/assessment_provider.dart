import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:social_balans/services/auth_service.dart'
    hide authServiceProvider;
import '../models/assessment_model.dart';
import './auth_provider.dart';
import '../services/user_data_service.dart';
import '../services/demo_data_service.dart';

class AssessmentNotifier extends StateNotifier<List<UserAssessment>> {
  final AuthService _authService;
  final Box<UserAssessment> _box;

  AssessmentNotifier(
      this._authService, UserDataService userDataService, this._box)
      : super([]) {
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      state = [];
      return;
    }

    // Si en mode démo, générer des données de démo
    if (DemoDataService.isDemoMode(currentUser.id)) {
      state = DemoDataService.generateDemoAssessments();
      return;
    }

    // Essayer de charger depuis Hive d'abord
    try {
      final assessments = _box.values
          .where((assessment) => assessment.userId == currentUser.id)
          .toList();
      state = assessments;
    } catch (e) {
      print('Erreur lors du chargement des évaluations: $e');
      state = [];
    }
  }

  Future<void> _syncFromServer() async {
    // final currentUser = _authService.currentUser;
    // if (currentUser == null) return;

    // try {
    //   final assessments =
    //       await _userDataService.getUserAssessments(currentUser.id);

    //   // Sauvegarder dans Hive
    //   for (final assessment in assessments) {
    //     await _box.put(assessment.id, assessment);
    //   }

    //   state = assessments;
    // } catch (e) {
    //   print('Erreur lors de la synchronisation avec le serveur: $e');
    // }
  }

  Future<void> saveAssessment(UserAssessment assessment) async {
    try {
      // Sauvegarder localement
      await _box.put(assessment.id, assessment);

      // Mettre à jour l'état
      state = [...state, assessment];

      // Synchroniser avec le serveur si connecté
      // final currentUser = _authService.currentUser;
      // if (currentUser != null && !DemoDataService.isDemoMode(currentUser.id)) {
      //   await _userDataService.saveUserAssessment(assessment);
      // }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'évaluation: $e');
      rethrow;
    }
  }

  Future<void> deleteAssessment(String id) async {
    try {
      // Supprimer localement
      await _box.delete(id);

      // Mettre à jour l'état
      state = state.where((assessment) => assessment.id != id).toList();

      // Synchroniser avec le serveur si connecté
      // final currentUser = _authService.currentUser;
      // if (currentUser != null && !DemoDataService.isDemoMode(currentUser.id)) {
      //   await _userDataService.deleteUserAssessment(id);
      // }
    } catch (e) {
      print('Erreur lors de la suppression de l\'évaluation: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _syncFromServer();
  }

  UserAssessment? getLatestAssessment() {
    if (state.isEmpty) return null;

    // Trier par date de création (plus récent en premier)
    final sortedAssessments = List<UserAssessment>.from(state)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedAssessments.first;
  }

  Map<String, dynamic>? getProgressSince(DateTime since) {
    if (state.isEmpty) return null;

    // Trouver l'évaluation la plus récente
    final latest = getLatestAssessment();
    if (latest == null) return null;

    // Trouver l'évaluation la plus proche de la date spécifiée
    UserAssessment? baseline;
    for (final assessment in state) {
      if (assessment.createdAt.isBefore(since) ||
          assessment.createdAt.isAtSameMomentAs(since)) {
        if (baseline == null ||
            assessment.createdAt.isAfter(baseline.createdAt)) {
          baseline = assessment;
        }
      }
    }

    if (baseline == null) return null;

    // Calculer la progression
    return latest.calculateProgressionSince(baseline);
  }
}

// Provider pour la boîte Hive
final assessmentBoxProvider = Provider<Box<UserAssessment>>((ref) {
  return Hive.box<UserAssessment>('assessments');
});

// Provider pour les évaluations
final assessmentProvider =
    StateNotifierProvider<AssessmentNotifier, List<UserAssessment>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userDataService = ref.watch(userDataServiceProvider);
  final box = ref.watch(assessmentBoxProvider);

  return AssessmentNotifier(authService, userDataService, box);
});

// Provider pour l'évaluation la plus récente
final latestAssessmentProvider = Provider<UserAssessment?>((ref) {
  final assessments = ref.watch(assessmentProvider);

  if (assessments.isEmpty) return null;

  // Trier par date de création (plus récent en premier)
  final sortedAssessments = List<UserAssessment>.from(assessments)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return sortedAssessments.first;
});

// Provider pour le progrès de l'utilisateur (30 derniers jours)
final userProgressProvider = Provider<Map<String, dynamic>?>((ref) {
  final assessmentNotifier = ref.watch(assessmentProvider.notifier);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  return assessmentNotifier.getProgressSince(thirtyDaysAgo);
});

// Provider pour le progrès global (depuis la première évaluation)
final overallProgressProvider = Provider<Map<String, dynamic>?>((ref) {
  final assessments = ref.watch(assessmentProvider);
  final assessmentNotifier = ref.watch(assessmentProvider.notifier);

  if (assessments.isEmpty) return null;

  // Trouver la première évaluation
  final firstAssessment =
      assessments.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

  return assessmentNotifier.getProgressSince(firstAssessment.createdAt);
});

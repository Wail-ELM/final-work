import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_objective_provider.dart';
import '../data/challenge_templates.dart';

// Filter suggesties volgens gekozen doel
final suggestedTemplatesProvider =
    Provider<List<ChallengeTemplate>>((ref) {
  final obj = ref.watch(userObjectiveProvider);
  if (obj == null) return [];
  return challengeTemplates
      .where((t) => t.category == obj)
      .toList();
});

// lib/screens/suggestions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/core/design_system.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
import 'package:social_balans/providers/auth_provider.dart';
import 'package:social_balans/providers/challenge_provider.dart';
import 'package:social_balans/services/challenge_suggestion_service.dart';

// Enum for the selected filter type
enum SuggestionFilter { all, category, difficulty }

// State provider for the currently selected filter chip
final suggestionFilterProvider =
    StateProvider<SuggestionFilter>((ref) => SuggestionFilter.all);

// State provider for the selected category (when filter is by category)
final selectedCategoryProvider =
    StateProvider<ChallengeCategory?>((ref) => null);

// State provider for the selected difficulty (when filter is by difficulty)
final selectedDifficultyProvider = StateProvider<String?>((ref) => null);

// Provider that filters the suggestions based on the selected filters
final filteredSuggestionsProvider = Provider<List<ChallengeSuggestion>>((ref) {
  final filter = ref.watch(suggestionFilterProvider);
  final allSuggestions = ref
      .watch(challengeSuggestionServiceProvider)
      .getAllPredefinedChallenges();

  switch (filter) {
    case SuggestionFilter.category:
      final category = ref.watch(selectedCategoryProvider);
      return category == null
          ? allSuggestions
          : allSuggestions.where((s) => s.category == category).toList();
    case SuggestionFilter.difficulty:
      final difficulty = ref.watch(selectedDifficultyProvider);
      return difficulty == null
          ? allSuggestions
          : allSuggestions.where((s) => s.difficulty == difficulty).toList();
    case SuggestionFilter.all:
      return allSuggestions;
  }
});

/// Scherm waarin de gebruiker eerst een doel kiest,
/// en vervolgens passende challenges kan toevoegen.
class SuggestionsScreen extends ConsumerWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(filteredSuggestionsProvider);
    final userId = ref.watch(authServiceProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uitdaging Suggesties'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: _FilterHeaderDelegate(),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDesignSystem.space16),
            sliver: suggestions.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final suggestion = suggestions[index];
                        return _SuggestionCard(
                          suggestion: suggestion,
                          onAccepted: () {
                            if (userId != null) {
                              final newChallenge =
                                  suggestion.toChallenge(userId);
                              ref
                                  .read(allChallengesProvider.notifier)
                                  .add(newChallenge);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Nieuwe uitdaging geaccepteerd!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        );
                      },
                      childCount: suggestions.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDesignSystem.space12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const _FilterChips(),
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(suggestionFilterProvider);

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.space16),
      children: [
        FilterChip(
          label: const Text('Allemaal'),
          selected: activeFilter == SuggestionFilter.all,
          onSelected: (selected) {
            if (selected) {
              ref.read(suggestionFilterProvider.notifier).state =
                  SuggestionFilter.all;
            }
          },
        ),
        const SizedBox(width: AppDesignSystem.space8),
        FilterChip(
          label: const Text('Categorie'),
          selected: activeFilter == SuggestionFilter.category,
          onSelected: (selected) {
            if (selected) {
              ref.read(suggestionFilterProvider.notifier).state =
                  SuggestionFilter.category;
              _showCategoryPicker(context, ref);
            }
          },
        ),
        const SizedBox(width: AppDesignSystem.space8),
        FilterChip(
          label: const Text('Moeilijkheid'),
          selected: activeFilter == SuggestionFilter.difficulty,
          onSelected: (selected) {
            if (selected) {
              ref.read(suggestionFilterProvider.notifier).state =
                  SuggestionFilter.difficulty;
              _showDifficultyPicker(context, ref);
            }
          },
        ),
      ],
    );
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ChallengeCategory.values
            .map((cat) => ListTile(
                  title: Text(cat.displayName),
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = cat;
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context, WidgetRef ref) {
    final difficulties = ['makkelijk', 'gemiddeld', 'moeilijk'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: difficulties
            .map((diff) => ListTile(
                  title: Text(diff[0].toUpperCase() + diff.substring(1)),
                  onTap: () {
                    ref.read(selectedDifficultyProvider.notifier).state = diff;
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final ChallengeSuggestion suggestion;
  final VoidCallback onAccepted;

  const _SuggestionCard({required this.suggestion, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.space16),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(suggestion: suggestion),
            const SizedBox(height: AppDesignSystem.space12),
            Text(suggestion.description, style: textTheme.bodyMedium),
            const SizedBox(height: AppDesignSystem.space12),
            if (suggestion.reason.isNotEmpty)
              _InfoChip(
                icon: Icons.lightbulb_outline,
                label: suggestion.reason,
                color: Colors.amber.shade700,
              ),
            const SizedBox(height: AppDesignSystem.space16),
            const Divider(),
            const SizedBox(height: AppDesignSystem.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duur: ${suggestion.estimatedDays} dagen',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                ElevatedButton.icon(
                  onPressed: onAccepted,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Accepteren'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final ChallengeSuggestion suggestion;
  const _CardHeader({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(suggestion.category.icon, color: colorScheme.primary, size: 32),
        const SizedBox(width: AppDesignSystem.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(suggestion.title,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '${suggestion.category.displayName} • ${suggestion.difficulty}',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space12,
          vertical: AppDesignSystem.space8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppDesignSystem.space8),
          Flexible(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignSystem.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: AppDesignSystem.space16),
            Text('Geen Suggesties',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppDesignSystem.space8),
            const Text(
              'Er zijn geen suggesties die overeenkomen met de geselecteerde filters.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

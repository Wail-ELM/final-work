import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/core/design_system.dart';
import 'package:social_balans/providers/challenge_provider.dart';
import 'package:social_balans/screens/suggestions.dart';
import 'package:social_balans/widgets/challenge_card.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUserChallenges = ref.watch(allChallengesProvider);
    final errorMsg = ref.watch(challengeErrorProvider);
    final activeChallenges = allUserChallenges.where((c) => !c.isDone).toList();
    final completedChallenges =
        allUserChallenges.where((c) => c.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Uitdagingen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Ontdek nieuwe uitdagingen',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SuggestionsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (errorMsg != null)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).colorScheme.error,
              actions: [
                TextButton(
                  onPressed: () =>
                      ref.read(challengeErrorProvider.notifier).state = null,
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ChallengesList(
                  challenges: allUserChallenges,
                  emptyState: _EmptyState(
                    title: 'Geen Uitdagingen',
                    message:
                        'Je hebt nog geen uitdagingen. Ontdek suggesties om te beginnen!',
                    onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SuggestionsScreen())),
                    actionLabel: 'Ontdek Suggesties',
                  ),
                ),
                _ChallengesList(
                  challenges: activeChallenges,
                  emptyState: _EmptyState(
                    title: 'Geen Actieve Uitdagingen',
                    message:
                        'Accepteer een nieuwe uitdaging om hier te verschijnen.',
                    onAction: () => _tabController.animateTo(0),
                    actionLabel: 'Bekijk Alle',
                  ),
                ),
                _ChallengesList(
                  challenges: completedChallenges,
                  emptyState: _EmptyState(
                    title: 'Nog Niets Voltooid',
                    message:
                        'Voltooi een actieve uitdaging om je prestaties hier te zien.',
                    onAction: () => _tabController.animateTo(1),
                    actionLabel: 'Bekijk Actieve',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: Container(
        padding: const EdgeInsets.all(AppDesignSystem.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSmall),
            color: Theme.of(context).indicatorColor,
          ),
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Alle'),
            Tab(text: 'Actief'),
            Tab(text: 'Voltooid'),
          ],
        ),
      ),
    );
  }
}

class _ChallengesList extends ConsumerWidget {
  final List<Challenge> challenges;
  final Widget emptyState;

  const _ChallengesList({required this.challenges, required this.emptyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (challenges.isEmpty) {
      return Center(child: emptyState);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      itemCount: challenges.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDesignSystem.space12),
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeCard(
          challenge: challenge,
          onToggle: () =>
              ref.read(allChallengesProvider.notifier).toggleDone(challenge.id),
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Uitdaging verwijderen'),
                content: const Text(
                    'Weet je zeker dat je deze uitdaging wilt verwijderen?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Annuleren'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Verwijderen'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(allChallengesProvider.notifier).remove(challenge.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uitdaging verwijderd')),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.playlist_add_check_circle_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: AppDesignSystem.space24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignSystem.space16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignSystem.space32),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

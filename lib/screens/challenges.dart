import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import 'challenge_suggestions_screen.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with TickerProviderStateMixin {
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
    final challenges = ref.watch(allChallengesProvider);
    final activeChallenges = challenges.where((c) => !c.isDone).toList();
    final completedChallenges = challenges.where((c) => c.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Uitdagingen',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).primaryColor,
            ),
            tooltip: 'Ontdek nieuwe uitdagingen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeSuggestionsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: 'Alle', height: 36),
                Tab(text: 'Actief', height: 36),
                Tab(text: 'Voltooid', height: 36),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChallengesList(challenges, "alle"),
                _buildChallengesList(activeChallenges, "actief"),
                _buildChallengesList(completedChallenges, "voltooid"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: challenges.isEmpty ? _buildDiscoverFAB() : null,
    );
  }

  Widget _buildChallengesList(List<Challenge> challenges, String type) {
    if (challenges.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChallengeCard(challenge),
        );
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final progress = _calculateProgress(challenge);
    final categoryIcon = _getCategoryIcon(challenge.category);
    final categoryColor = _getCategoryColor(challenge.category);
    final timeLeft = _getTimeLeft(challenge);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            if (!challenge.isDone && progress > 0)
              LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    Theme.of(context).dividerColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                minHeight: 3,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            categoryIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (challenge.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(
                                challenge.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (challenge.isDone)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Voltooid',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (timeLeft.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                timeLeft,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          IconButton(
                            icon: Icon(
                              challenge.isDone
                                  ? Icons.restart_alt
                                  : Icons.check_circle_outline,
                              color: challenge.isDone
                                  ? Colors.orange
                                  : Colors.green,
                              size: 20,
                            ),
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              if (mounted) {
                                ref
                                    .read(challengeProvider(challenge.id)
                                        .notifier)
                                    .toggleDone();
                              }
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!challenge.isDone) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voortgang: ${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getCategoryLabel(challenge.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    String suggestion;
    IconData icon;

    switch (type) {
      case "actief":
        message = "Geen actieve uitdagingen";
        suggestion =
            "Ontdek nieuwe uitdagingen om je digitale balans te verbeteren";
        icon = Icons.flag_outlined;
        break;
      case "voltooid":
        message = "Nog geen voltooide uitdagingen";
        suggestion = "Voltooi je eerste uitdaging om je voortgang te zien";
        icon = Icons.emoji_events_outlined;
        break;
      default:
        message = "Geen uitdagingen gevonden";
        suggestion =
            "Ontdek uitdagingen die je helpen je digitale welzijn te verbeteren";
        icon = Icons.auto_awesome;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (type == "alle") ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ChallengeSuggestionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Ontdek uitdagingen'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeSuggestionsScreen(),
          ),
        );
      },
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Ontdek uitdagingen'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  double _calculateProgress(Challenge challenge) {
    if (challenge.isDone) return 1.0;
    if (challenge.endDate == null) return 0.0;

    final total = challenge.endDate!.difference(challenge.startDate).inDays;
    final elapsed = DateTime.now().difference(challenge.startDate).inDays;

    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _getTimeLeft(Challenge challenge) {
    if (challenge.isDone || challenge.endDate == null) return '';

    final now = DateTime.now();
    final remaining = challenge.endDate!.difference(now).inDays;

    if (remaining < 0) return 'Verlopen';
    if (remaining == 0) return 'Laatste dag';
    if (remaining == 1) return '1 dag';
    if (remaining < 7) return '$remaining dagen';

    final weeks = (remaining / 7).floor();
    if (weeks == 1) return '1 week';
    return '$weeks weken';
  }

  String _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return '📱';
      case ChallengeCategory.focus:
        return '🎯';
      case ChallengeCategory.notifications:
        return '🔔';
      default:
        return '📱';
    }
  }

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return Colors.blue;
      case ChallengeCategory.focus:
        return Colors.orange;
      case ChallengeCategory.notifications:
        return Colors.purple;
    }
  }

  String _getCategoryLabel(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return 'Schermtijd';
      case ChallengeCategory.focus:
        return 'Concentratie';
      case ChallengeCategory.notifications:
        return 'Notificaties';
    }
  }
}

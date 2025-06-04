import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/challenge_card.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import 'challenge_creation_screen.dart';
import 'challenge_suggestions_screen.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allChallengesProvider);

    // Calculer les listes filtrées de manière optimisée
    final activeChallenges = <Challenge>[];
    final completedChallenges = <Challenge>[];

    for (final challenge in all) {
      if (challenge.isDone) {
        completedChallenges.add(challenge);
      } else {
        activeChallenges.add(challenge);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Uitdagingen'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Suggesties bekijken',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeSuggestionsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nieuwe uitdaging',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeCreationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildModernStats(all, activeChallenges, completedChallenges),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChallengesList(all, "tous"),
                  _buildChallengesList(activeChallenges, "actifs"),
                  _buildChallengesList(completedChallenges, "terminés"),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          all.isEmpty ? _buildGetStartedFAB() : _buildSimpleFAB(),
    );
  }

  Widget _buildModernStats(
      List<Challenge> all, List<Challenge> active, List<Challenge> completed) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overzicht',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (all.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Begin hier!',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (all.isEmpty)
              _buildWelcomeSection()
            else
              _buildStatsGrid(all, active, completed),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.rocket_launch,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                'Welkom bij je uitdagingen!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Begin je reis naar een gezondere digitale balans',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
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
                      label: const Text('Suggesties'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ChallengeCreationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Zelf maken'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      List<Challenge> all, List<Challenge> active, List<Challenge> completed) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            Icons.flag,
            all.length.toString(),
            'Totaal',
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Icons.play_circle,
            active.length.toString(),
            'Actief',
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Icons.check_circle,
            completed.length.toString(),
            'Voltooid',
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Icons.percent,
            all.isEmpty
                ? '0%'
                : '${(completed.length / all.length * 100).round()}%',
            'Succes',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeCreationScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Eerste uitdaging'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSimpleFAB() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeCreationScreen(),
          ),
        );
      },
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
            text: 'Tous',
            height: 32,
          ),
          Tab(
            text: 'Actifs',
            height: 32,
          ),
          Tab(
            text: 'Terminés',
            height: 32,
          ),
        ],
      ),
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
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEnhancedChallengeCard(challenge),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedChallengeCard(Challenge challenge) {
    final progress = _calculateProgress(challenge);
    final categoryIcon = _getCategoryIcon(challenge.category);
    final categoryColor = _getCategoryColor(challenge.category);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to challenge details
        },
        child: Padding(
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
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 24),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (challenge.isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voltooid',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            challenge.isDone ? Colors.green : categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      challenge.isDone
                          ? Icons.restart_alt
                          : Icons.check_circle_outline,
                      color: challenge.isDone ? Colors.orange : Colors.green,
                    ),
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      if (mounted) {
                        ref
                            .read(challengeProvider(challenge.id).notifier)
                            .toggleDone();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(challenge),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryLabel(challenge.category),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    String suggestion;
    IconData icon;

    switch (type) {
      case "actifs":
        message = "Geen actieve uitdagingen";
        suggestion = "Je actieve uitdagingen verschijnen hier";
        icon = Icons.flag_outlined;
        break;
      case "terminés":
        message = "Geen voltooide uitdagingen";
        suggestion = "Voltooi uitdagingen om ze hier te zien";
        icon = Icons.emoji_events_outlined;
        break;
      default:
        message = "Geen uitdagingen gevonden";
        suggestion = "Gebruik de knoppen hierboven om te beginnen";
        icon = Icons.search_off;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress(Challenge challenge) {
    if (challenge.isDone) return 1.0;
    if (challenge.endDate == null) return 0.0;

    final total = challenge.endDate!.difference(challenge.startDate).inDays;
    final elapsed = DateTime.now().difference(challenge.startDate).inDays;

    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _formatDuration(Challenge challenge) {
    if (challenge.endDate == null) return 'Onbepaald';

    final duration = challenge.endDate!.difference(challenge.startDate).inDays;
    final remaining = challenge.endDate!.difference(DateTime.now()).inDays;

    if (challenge.isDone) {
      return '$duration dagen (voltooid)';
    } else if (remaining > 0) {
      return '$remaining dagen resterend';
    } else {
      return 'Verlopen';
    }
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

  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

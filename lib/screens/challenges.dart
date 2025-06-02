import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/challenge_card.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../models/challenge_category_adapter.dart';
import 'challenge_creation_screen.dart';

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
    final activeChallenges = all.where((c) => !c.isDone).toList();
    final completedChallenges = all.where((c) => c.isDone).toList();

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStats(all, activeChallenges, completedChallenges),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChallengeCreationScreen(),
            ),
          );
          if (result == true) {
            ref.refresh(allChallengesProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau défi'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStats(
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Aperçu de vos défis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  Icons.flag,
                  all.length.toString(),
                  'Total',
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  Icons.play_circle,
                  active.length.toString(),
                  'Actifs',
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  Icons.check_circle,
                  completed.length.toString(),
                  'Terminés',
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  Icons.percent,
                  all.isEmpty
                      ? '0%'
                      : '${(completed.length / all.length * 100).round()}%',
                  'Succès',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Tous'),
          Tab(text: 'Actifs'),
          Tab(text: 'Terminés'),
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
                            'Terminé',
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
                    onPressed: () {
                      ref
                          .read(challengeProvider(challenge.id).notifier)
                          .toggleDone();
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
        message = "Aucun défi actif";
        suggestion = "Créez un nouveau défi pour commencer !";
        icon = Icons.flag_outlined;
        break;
      case "terminés":
        message = "Aucun défi terminé";
        suggestion = "Complétez vos défis actifs pour les voir ici";
        icon = Icons.emoji_events_outlined;
        break;
      default:
        message = "Aucun défi créé";
        suggestion = "Commencez votre parcours en créant un premier défi";
        icon = Icons.add_task;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (type != "terminés") ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengeCreationScreen(),
                  ),
                );
                if (result == true) {
                  ref.refresh(allChallengesProvider);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un défi'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
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
    if (challenge.endDate == null) return 'Indéfini';

    final duration = challenge.endDate!.difference(challenge.startDate).inDays;
    final remaining = challenge.endDate!.difference(DateTime.now()).inDays;

    if (challenge.isDone) {
      return '$duration jours (terminé)';
    } else if (remaining > 0) {
      return '$remaining jours restants';
    } else {
      return 'Expiré';
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
        return 'Temps d\'écran';
      case ChallengeCategory.focus:
        return 'Concentration';
      case ChallengeCategory.notifications:
        return 'Notifications';
    }
  }
}

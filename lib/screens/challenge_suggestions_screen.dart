import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/challenge_suggestion_service.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge_category_adapter.dart';

class ChallengeSuggestionsScreen extends ConsumerStatefulWidget {
  const ChallengeSuggestionsScreen({super.key});

  @override
  ConsumerState<ChallengeSuggestionsScreen> createState() =>
      _ChallengeSuggestionsScreenState();
}

class _ChallengeSuggestionsScreenState
    extends ConsumerState<ChallengeSuggestionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voorgestelde Uitdagingen'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Voor Jou'),
            Tab(text: 'Schermtijd'),
            Tab(text: 'Focus'),
            Tab(text: 'Notificaties'),
          ],
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalizedTab(),
          _buildCategoryTab(ChallengeCategory.screenTime),
          _buildCategoryTab(ChallengeCategory.focus),
          _buildCategoryTab(ChallengeCategory.notifications),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTab() {
    final suggestionsAsync = ref.watch(personalizedSuggestionsProvider);

    return suggestionsAsync.when(
      data: (suggestions) => _buildSuggestionsList(
        suggestions,
        'Gepersonaliseerde uitdagingen voor jou',
        'Deze uitdagingen zijn aanbevolen op basis van je gewoonten en stemming.',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Fout bij het laden van suggesties',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Controleer je verbinding en probeer opnieuw',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(ChallengeCategory category) {
    final service = ref.watch(challengeSuggestionServiceProvider);
    final suggestions = service.getChallengesByCategory(category);

    return _buildSuggestionsList(
      suggestions,
      _getCategoryTitle(category),
      _getCategoryDescription(category),
    );
  }

  Widget _buildSuggestionsList(
      List<ChallengeSuggestion> suggestions, String title, String description) {
    if (suggestions.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(title, description),
          const SizedBox(height: 24),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 150)),
              curve: Curves.easeOutBack,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSuggestionCard(suggestion),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(ChallengeSuggestion suggestion) {
    final categoryIcon = _getCategoryIcon(suggestion.category);
    final categoryColor = _getCategoryColor(suggestion.category);
    final difficultyColor = _getDifficultyColor(suggestion.difficulty);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSuggestionDetails(context, suggestion),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            suggestion.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: difficultyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                suggestion.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion.reason,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${suggestion.estimatedDays} dagen',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _acceptChallenge(suggestion),
                    icon: const Icon(Icons.add_task, size: 18),
                    label: const Text('Accepteren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Geen suggesties beschikbaar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kom later terug voor nieuwe suggesties',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSuggestionDetails(
      BuildContext context, ChallengeSuggestion suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text(suggestion.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(suggestion.description,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text("Waarom deze suggestie?",
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(suggestion.reason),
                    const SizedBox(height: 16),
                    Text("Tips:",
                        style: Theme.of(context).textTheme.titleMedium),
                    ...suggestion.tips.map((tip) => ListTile(
                        leading: Icon(Icons.check_circle_outline),
                        title: Text(tip))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Uitdaging accepteren'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    final userId =
                        ref.read(authServiceProvider).currentUser?.id;
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Je moet ingelogd zijn om een uitdaging te accepteren.')),
                      );
                      return;
                    }

                    final newChallenge = suggestion.toChallenge(userId);
                    ref.read(allChallengesProvider.notifier).add(newChallenge);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Uitdaging toegevoegd!'),
                        action: SnackBarAction(
                          label: 'Bekijk',
                          onPressed: () {
                            // This assumes you have a way to navigate to the challenges screen
                            // Maybe by using the main navigator if you have a key, or by using a tab controller.
                            // For now, this is a placeholder. A better implementation might use the navigatorKey.
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptChallenge(ChallengeSuggestion suggestion) async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Je moet ingelogd zijn om een uitdaging te accepteren'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final challenge = suggestion.toChallenge(currentUser.id);
      await ref.read(allChallengesProvider.notifier).add(challenge);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Uitdaging "${suggestion.title}" succesvol geaccepteerd!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Bekijken',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

      // Optioneel: navigeren naar het uitdagingen scherm
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij het maken van de uitdaging: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getCategoryTitle(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return 'Schermtijd Uitdagingen';
      case ChallengeCategory.focus:
        return 'Focus Uitdagingen';
      case ChallengeCategory.notifications:
        return 'Notificatie Uitdagingen';
    }
  }

  String _getCategoryDescription(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return 'Verminder je schermtijd en neem de controle terug over je digitale leven.';
      case ChallengeCategory.focus:
        return 'Verbeter je concentratie en productiviteit in het dagelijks leven.';
      case ChallengeCategory.notifications:
        return 'Beheer je notificaties om gemoedsrust terug te vinden.';
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
    }
  }

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.screenTime:
        return Colors.blue;
      case ChallengeCategory.focus:
        return Colors.green;
      case ChallengeCategory.notifications:
        return Colors.orange;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'makkelijk':
        return Colors.green;
      case 'gemiddeld':
        return Colors.orange;
      case 'moeilijk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

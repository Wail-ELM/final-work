import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';
import '../providers/user_objective_provider.dart';
import '../widgets/weekly_insights_chart.dart';
import '../widgets/mood_distribution_chart.dart';
import '../widgets/mood_trends_chart.dart';
import '../widgets/app_usage_chart.dart';
import '../services/app_usage_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(moodStatsProvider);
    final screenTime = ref.watch(screenTimeProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text('Statistieken'),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 16),
                        _buildPeriodSelector(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overzicht'),
                  Tab(text: 'Stemming'),
                  Tab(text: 'Schermtijd'),
                ],
              ),
            ),
          ];
        },
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => _tabController.animateTo(index),
          children: [
            screenTime.when(
              data: (duration) => _buildOverviewTab(stats, duration),
              loading: () => _buildOverviewTab(
                  stats, const Duration(hours: 2, minutes: 30)),
              error: (_, __) => _buildOverviewTab(stats, Duration.zero),
            ),
            _buildMoodTab(stats),
            screenTime.when(
              data: (duration) => _buildScreenTimeTab(duration),
              loading: () =>
                  _buildScreenTimeTab(const Duration(hours: 2, minutes: 30)),
              error: (_, __) => _buildScreenTimeTab(Duration.zero),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('week', 'Week'),
          _buildPeriodButton('month', 'Maand'),
          _buildPeriodButton('year', 'Jaar'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(MoodStats stats, Duration screenTime) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Gemiddelde stemming',
            '${(stats.averageMood / 5.0 * 100).round()}%',
            Icons.mood,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Schermtijd vandaag',
            '${screenTime.inHours}u ${screenTime.inMinutes % 60}m',
            Icons.timer,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Wekelijkse inzichten',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          WeeklyInsightsChart(
            entries: stats.recentEntries,
            screenTime: screenTime,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTab(MoodStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoodDistributionChart(entries: stats.recentEntries),
          const SizedBox(height: 24),
          MoodTrendsChart(
            entries: stats.recentEntries,
            period: _selectedPeriod == 'week'
                ? 'week'
                : _selectedPeriod == 'month'
                    ? 'month'
                    : 'year',
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeTab(Duration screenTime) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Gebruik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppUsageChart(date: DateTime.now()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dagelijkse Samenvatting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Duration>(
                    future: AppUsageService()
                        .getTotalScreenTimeForDate(DateTime.now()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final totalTime = snapshot.data ?? Duration.zero;
                      final hours = totalTime.inHours;
                      final minutes = totalTime.inMinutes % 60;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            Icons.timer,
                            '${hours}u ${minutes}m',
                            'Totaal',
                          ),
                          _buildStatItem(
                            context,
                            Icons.phone_android,
                            '${(totalTime.inMinutes / 60).toStringAsFixed(1)}u',
                            'Gemiddeld',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Hero(
      tag: 'stat_$title',
      child: Card(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showStatDetails(context, title, value, icon, color),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStatDetails(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'stat_$title',
                      child: Icon(
                        icon,
                        size: 64,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

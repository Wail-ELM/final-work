import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/mood_provider.dart';
import '../providers/user_objective_provider.dart';
import '../widgets/weekly_insights_chart.dart';
import '../widgets/mood_history_chart.dart';
import '../widgets/mood_trends_chart.dart';
import '../widgets/app_usage_chart.dart';
import '../widgets/total_screen_time_trend_chart.dart';
import '../models/mood_entry.dart';
import '../core/design_system.dart';
import '../widgets/empty_state_widget.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('Statistieken', style: AppDesignSystem.heading2),
              bottom: TabBar(
                controller: _tabController,
                labelStyle:
                    AppDesignSystem.body1.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppDesignSystem.body1,
                tabs: const [
                  Tab(text: 'Overzicht'),
                  Tab(text: 'Stemming'),
                  Tab(text: 'Schermtijd'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildMoodTab(),
            _buildScreenTimeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDesignSystem.space16),
      padding: const EdgeInsets.all(AppDesignSystem.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: AppDesignSystem.borderRadiusMedium,
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
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDesignSystem.space8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: AppDesignSystem.borderRadiusSmall,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppDesignSystem.body2.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.textTheme.bodyLarge!.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<MoodEntry> _filterEntriesByPeriod(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];
    final now = DateTime.now();
    DateTime from;
    if (_selectedPeriod == 'week') {
      from = now.subtract(const Duration(days: 7));
    } else if (_selectedPeriod == 'month') {
      from = DateTime(now.year, now.month - 1, now.day);
    } else {
      // year
      from = DateTime(now.year - 1, now.month, now.day);
    }
    return entries.where((e) => e.createdAt.isAfter(from)).toList();
  }

  Widget _buildOverviewTab() {
    final stats = ref.watch(moodStatsProvider);
    final screenTimeAsync = ref.watch(screenTimeProvider);
    final filteredEntries = _filterEntriesByPeriod(stats.recentEntries);
    final noMoodData = filteredEntries.isEmpty;

    return screenTimeAsync.when(
      data: (screenTimeValue) {
        if (noMoodData && screenTimeValue == null) {
          return const EmptyStateWidget(
            icon: Icons.analytics_outlined,
            title: 'Statistieken worden verzameld',
            message:
                'Gebruik de app een paar dagen om je eerste inzichten en trends te ontdekken.',
          );
        }

        double avgMood = 0;
        if (!noMoodData) {
          avgMood =
              filteredEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
                  filteredEntries.length;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesignSystem.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: AppDesignSystem.space24),
              Text("Humeur Samenvatting", style: AppDesignSystem.heading3),
              const SizedBox(height: AppDesignSystem.space16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppDesignSystem.space16,
                mainAxisSpacing: AppDesignSystem.space16,
                childAspectRatio: 1.8,
                children: [
                  _buildStatCard(
                      'Gem. Stemming',
                      noMoodData ? 'N/A' : '${avgMood.toStringAsFixed(1)} / 5',
                      Icons.sentiment_satisfied_alt_outlined,
                      AppDesignSystem.secondaryBlue),
                  _buildStatCard(
                      'Ingevoerd',
                      noMoodData ? '0' : '${filteredEntries.length}',
                      Icons.edit_note_rounded,
                      AppDesignSystem.info),
                ],
              ),
              const SizedBox(height: AppDesignSystem.space24),
              Text("Schermtijd Samenvatting", style: AppDesignSystem.heading3),
              const SizedBox(height: AppDesignSystem.space16),
              _buildStatCard(
                  'Tijd Vandaag',
                  screenTimeValue != null
                      ? '${screenTimeValue.inHours}u ${screenTimeValue.inMinutes % 60}m'
                      : 'N/A',
                  Icons.timer_outlined,
                  AppDesignSystem.success,
                  isFullWidth: true),
              const SizedBox(height: AppDesignSystem.space24),
              Text("Trends", style: AppDesignSystem.heading3),
              const SizedBox(height: AppDesignSystem.space16),
              ModernCard(
                child: noMoodData
                    ? const Center(child: Text("Geen data voor trendanalyse"))
                    : WeeklyInsightsChart(entries: filteredEntries),
              ),
            ],
          ),
        );
      },
      loading: () => const _LoadingSkeleton(),
      error: (err, stack) => const EmptyStateWidget(
          title: 'Fout opgetreden',
          message: 'Kon de data niet laden.',
          icon: Icons.error_outline),
    );
  }

  Widget _buildMoodTab() {
    final stats = ref.watch(moodStatsProvider);
    final filteredEntries = _filterEntriesByPeriod(stats.recentEntries);

    if (stats.recentEntries.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.mood_outlined,
        title: 'Geen stemmingsdata',
        message:
            'Voer dagelijks je stemming in om hier je trends en verdelingen te zien.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: AppDesignSystem.space24),
          if (filteredEntries.isNotEmpty) ...[
            Text("Stemming Historiek", style: AppDesignSystem.heading3),
            const SizedBox(height: AppDesignSystem.space16),
            const ModernCard(child: MoodHistoryChart()),
            const SizedBox(height: AppDesignSystem.space24),
            Text("Stemming Trends", style: AppDesignSystem.heading3),
            const SizedBox(height: AppDesignSystem.space16),
            ModernCard(
                child: MoodTrendsChart(
                    entries: filteredEntries, period: _selectedPeriod)),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenTimeTab() {
    if (kIsWeb) {
      return const EmptyStateWidget(
        icon: Icons.web_asset_off_outlined,
        title: 'Functie niet beschikbaar',
        message:
            'Het meten van schermtijd wordt niet ondersteund in de webversie van de applicatie.',
      );
    }

    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    DateTime startDate;
    if (_selectedPeriod == 'week') {
      startDate = endDate.subtract(const Duration(days: 6));
    } else if (_selectedPeriod == 'month') {
      startDate = endDate.subtract(const Duration(days: 29));
    } else {
      // year
      startDate = endDate.subtract(const Duration(days: 364));
    }

    final aggregatedAppUsageAsync = ref.watch(
        aggregatedAppUsageProvider((startDate: startDate, endDate: endDate)));
    final periodicScreenTimeAsync = ref.watch(periodicScreenTimeDataProvider(
        (startDate: startDate, endDate: endDate)));

    return periodicScreenTimeAsync.when(
      loading: () => const _LoadingSkeleton(),
      error: (err, stack) => const EmptyStateWidget(
          title: 'Fout opgetreden',
          message: 'Kon schermtijd data niet laden.',
          icon: Icons.error_outline),
      data: (periodicData) {
        return aggregatedAppUsageAsync.when(
          loading: () => const _LoadingSkeleton(),
          error: (err, stack) => const EmptyStateWidget(
              title: 'Fout opgetreden',
              message: 'Kon app-gebruik data niet laden.',
              icon: Icons.error_outline),
          data: (appUsageData) {
            if (appUsageData.isEmpty && periodicData.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.hourglass_empty_outlined,
                title: 'Geen schermtijd data',
                message:
                    'We hebben nog geen schermtijdgegevens. Open de app een paar dagen om inzichten te zien.',
              );
            }

            final totalDuration = periodicData.values
                .fold<Duration>(Duration.zero, (prev, time) => prev + time);
            final avgDuration = periodicData.isEmpty
                ? Duration.zero
                : totalDuration ~/ periodicData.length;

            return ListView(
              padding: const EdgeInsets.all(AppDesignSystem.space16),
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: AppDesignSystem.space24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDesignSystem.space16,
                  mainAxisSpacing: AppDesignSystem.space16,
                  childAspectRatio: 1.8,
                  children: [
                    _buildStatCard(
                        'Totaal',
                        '${totalDuration.inHours}u ${totalDuration.inMinutes % 60}m',
                        Icons.hourglass_bottom_rounded,
                        AppDesignSystem.warning),
                    _buildStatCard(
                        'Gem. per Dag',
                        '${avgDuration.inHours}u ${avgDuration.inMinutes % 60}m',
                        Icons.av_timer_rounded,
                        AppDesignSystem.success),
                  ],
                ),
                if (appUsageData.isNotEmpty) ...[
                  const SizedBox(height: AppDesignSystem.space24),
                  Text("Top Apps", style: AppDesignSystem.heading3),
                  const SizedBox(height: AppDesignSystem.space16),
                  ModernCard(child: AppUsageChart(appUsageData: appUsageData)),
                ],
                if (periodicData.isNotEmpty) ...[
                  const SizedBox(height: AppDesignSystem.space24),
                  Text("Schermtijd Trend", style: AppDesignSystem.heading3),
                  const SizedBox(height: AppDesignSystem.space16),
                  ModernCard(
                      child: TotalScreenTimeTrendChart(
                          dailyScreenTimeData: periodicData,
                          periodType: _selectedPeriod)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {bool isFullWidth = false}) {
    return ModernCard(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppDesignSystem.body2
                    .copyWith(color: AppDesignSystem.neutral400),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style:
                AppDesignSystem.heading2.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector Skeleton
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: AppDesignSystem.borderRadiusMedium,
            ),
          ),
          const SizedBox(height: AppDesignSystem.space24),

          // Title Skeleton
          Container(
              height: 28,
              width: 200,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: AppDesignSystem.borderRadiusSmall)),
          const SizedBox(height: AppDesignSystem.space16),

          // Card Skeleton
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: AppDesignSystem.borderRadiusLarge,
            ),
          ),
          const SizedBox(height: AppDesignSystem.space24),

          // Title Skeleton
          Container(
              height: 28,
              width: 150,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: AppDesignSystem.borderRadiusSmall)),
          const SizedBox(height: AppDesignSystem.space16),

          // Card Skeleton
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: AppDesignSystem.borderRadiusLarge,
            ),
          ),
        ],
      ),
    );
  }
}

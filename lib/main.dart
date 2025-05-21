import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme.dart';
import 'screens/dashboard.dart';
import 'screens/challenges.dart';
import 'screens/stats.dart';
import 'screens/suggestions.dart';

// Hive-modellen
import 'models/challenge.dart';
import 'models/mood_entry.dart';
import 'models/challenge_category_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ChallengeAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(ChallengeCategoryAdapter());

  await Hive.openBox<Challenge>('challenges');
  await Hive.openBox<MoodEntry>('moods');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Balans',
      theme: AppTheme.lightTheme,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    ChallengesScreen(),
    StatsScreen(),
    SuggestionsScreen(),
  ];

  static const _labels = [
    'Dashboard',
    'Uitdagingen',
    'Statistieken',
    'Suggesties',
  ];

  static const _icons = [
    Icons.home,
    Icons.flag,
    Icons.pie_chart,
    Icons.lightbulb,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[_currentIndex]),
      ),
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}

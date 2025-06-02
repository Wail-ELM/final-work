import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard.dart';
import 'screens/challenges.dart';
import 'screens/stats.dart';
import 'screens/suggestions.dart';
import 'providers/auth_provider.dart';

// Hive-modellen
import 'models/challenge.dart';
import 'models/mood_entry.dart';
import 'models/challenge_category_adapter.dart';
import 'models/screen_time_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // En mode démo/développement, utiliser des valeurs par défaut
    if (kDebugMode) {
      debugPrint('Could not load .env file, using default values');
    }
  }

  try {
    // Initialiser Supabase avec les variables d'environnement
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://demo.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'demo-key',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: true,
    );
    if (kDebugMode) {
      debugPrint('Supabase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error initializing Supabase: $e');
    }
  }

  // Initialiser Hive
  await Hive.initFlutter();

  // Enregistrer les adaptateurs
  Hive.registerAdapter(ChallengeAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(ChallengeCategoryAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ScreenTimeEntryAdapter());

  // Ouvrir les boîtes
  await Hive.openBox<Challenge>('challenges');
  await Hive.openBox<MoodEntry>('moods');
  await Hive.openBox<ScreenTimeEntry>('screen_time');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Social Balans',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (session) {
          // Authentification normale : vérifier si l'utilisateur est connecté
          return session != null ? const Home() : const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, stack) => ErrorScreen(error: error.toString()),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const Home(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(size: 100),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Er is een fout opgetreden',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Recharger l'application
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Uitloggen'),
                  content: const Text(
                    'Weet je zeker dat je wilt uitloggen?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuleren'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Uitloggen'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await ref.read(authServiceProvider).signOut();
              }
            },
          ),
        ],
      ),
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: List.generate(
          _labels.length,
          (index) => NavigationDestination(
            icon: Icon(_icons[index]),
            label: _labels[index],
          ),
        ),
      ),
    );
  }
}

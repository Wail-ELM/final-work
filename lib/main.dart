import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

import 'screens/modern_dashboard.dart'; // Import du nouveau dashboard
import 'screens/challenges.dart';
import 'screens/stats.dart';
import 'screens/suggestions.dart';
import 'screens/onboarding_screen.dart';
import 'screens/mood_entry_screen.dart'; // Added import for MoodEntryScreen
import 'screens/profile_screen.dart'; // Import the profile screen
import 'screens/settings/notification_settings_screen.dart'; // Import notification settings screen
// Hide potentially conflicting names from the service file if they are also defined in provider files
import 'services/notification_service.dart'; // Import du service
import 'services/smart_challenge_tracker.dart'; // Importer le nouveau service

// Hive-modellen
import 'models/challenge.dart';
import 'models/mood_entry.dart';
import 'models/challenge_category_adapter.dart';
import 'models/screen_time_entry.dart';
import 'core/design_system.dart'; // Import du nouveau design system
import 'models/badge.dart';

// Import providers needed for AppUsageService start/stop
import 'providers/auth_provider.dart'; // Provides authStateProvider
import 'providers/user_objective_provider.dart'
    hide
        userPreferencesProvider,
        UserPreferences; // Provides appUsageServiceProvider
import 'providers/mood_provider.dart'; // Provides moodStatsProvider
import 'providers/badge_provider.dart'; // Import badge provider to activate the badge system
import 'providers/user_preferences_provider.dart'; // Import userPreferencesProvider

// Clé globale pour le Navigator (optionnel, mais utile pour les notifs)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Provider for App Info (version, etc.)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

// Provider for SharedPreferences
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

void main() async {
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
  Hive.registerAdapter(BadgeAdapter()); // Register the new adapter

  // Ouvrir les boîtes
  await Hive.openBox<Challenge>('challenges');
  await Hive.openBox<MoodEntry>('moods');
  await Hive.openBox<ScreenTimeEntry>('screen_time');
  await Hive.openBox<Badge>('badges'); // Open the new badges box

  // Create a ProviderContainer to initialize services before the app runs.
  final container = ProviderContainer();

  // Initialiser le service de notification via the provider
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  notificationService.setNavigatorKey(navigatorKey); // Set the navigator key

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RootDecider(),
    ),
  );
}

class RootDecider extends ConsumerStatefulWidget {
  const RootDecider({super.key});

  @override
  ConsumerState<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends ConsumerState<RootDecider> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Use a consistent key for checking onboarding status.
    if (!mounted) return;
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    });
  }

  void _handleOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same consistent key to set the onboarding status.
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    setState(() {
      _onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPreferencesProvider);

    // Show a splash screen while checking the onboarding status.
    if (_onboardingComplete == null) {
      return MaterialApp(
        theme: AppDesignSystem.lightTheme,
        darkTheme: AppDesignSystem.darkTheme,
        themeMode: userPrefs.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const ModernSplashScreen(),
      );
    }

    // If onboarding is complete, show the main app.
    if (_onboardingComplete!) {
      return const SocialBalansAppMain();
    }
    // Otherwise, show the onboarding screen.
    else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppDesignSystem.lightTheme,
        darkTheme: AppDesignSystem.darkTheme,
        themeMode: userPrefs.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: OnboardingScreen(onDone: _handleOnboardingDone),
      );
    }
  }
}

class SocialBalansAppMain extends ConsumerWidget {
  const SocialBalansAppMain({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userPrefs = ref.watch(userPreferencesProvider);

    // IMPORTANT: Activer les systèmes en arrière-plan
    ref.read(badgeControllerProvider);
    ref.read(smartChallengeTrackerProvider); // Activer le tracker de défis

    // Listen to authState changes (this logic is already present and correct)
    ref.listen<AsyncValue<Session?>>(authStateProvider, (previous, next) {
      final appUsageService = ref.read(appUsageServiceProvider);
      final bool wasLoggedIn =
          previous is AsyncData<Session?> && previous.value != null;
      final bool isLoggedIn = next is AsyncData<Session?> && next.value != null;
      if (!wasLoggedIn && isLoggedIn) {
        debugPrint("User logged in, starting AppUsageService tracking.");
        appUsageService.startTracking();
      } else if (wasLoggedIn && !isLoggedIn) {
        debugPrint("User logged out, stopping AppUsageService tracking.");
        appUsageService.stopTracking();
      }
    });

    // Listen for notification settings changes and update schedule
    ref.listen<UserPreferences>(userPreferencesProvider, (previous, next) {
      if (previous != next) {
        final notificationService = ref.read(notificationServiceProvider);
        notificationService.updateAllScheduledNotifications(next);
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Social Balans',
      debugShowCheckedModeBanner: false,
      theme: AppDesignSystem.lightTheme,
      darkTheme: AppDesignSystem.darkTheme,
      themeMode: userPrefs.darkMode
          ? ThemeMode.dark
          : ThemeMode.light, // Use themeMode from provider
      home: authState.when(
        data: (session) {
          return session != null ? const ModernHome() : const LoginScreen();
        },
        loading: () => const ModernSplashScreen(),
        error: (error, stack) => ErrorScreen(error: error.toString()),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const ModernHome(),
        '/mood-entry': (context) => const MoodEntryScreen(), // Added route
        '/challenges': (context) => const ChallengesScreen(), // Added route
        '/profile': (context) => const ProfileScreen(), // Added route
        '/notification-settings': (context) =>
            const NotificationSettingsScreen(),
      },
    );
  }
}

// 🎨 NOUVEAU SPLASH SCREEN MODERNE
class ModernSplashScreen extends StatelessWidget {
  const ModernSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesignSystem.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo moderne avec animation
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusXLarge),
                  boxShadow: AppDesignSystem.shadowLarge,
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDesignSystem.space32),
              Text(
                'Social Balans',
                style: AppDesignSystem.heading1.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDesignSystem.space8),
              Text(
                'Digitale balans voor een betere levenskwaliteit',
                style: AppDesignSystem.body1.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDesignSystem.space48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesignSystem.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space24),
            child: Center(
              child: ModernCard(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppDesignSystem.error,
                      size: 64,
                    ),
                    const SizedBox(height: AppDesignSystem.space24),
                    Text(
                      'Er is een fout opgetreden',
                      style: AppDesignSystem.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDesignSystem.space8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: AppDesignSystem.body2.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                    const SizedBox(height: AppDesignSystem.space32),
                    ModernButton(
                      text: 'Opnieuw proberen',
                      icon: Icons.refresh,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SocialBalansAppMain(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 NOUVEAU HOME MODERNE AVEC DESIGN PREMIUM
class ModernHome extends ConsumerStatefulWidget {
  const ModernHome({super.key});

  @override
  ConsumerState<ModernHome> createState() => _ModernHomeState();
}

class _ModernHomeState extends ConsumerState<ModernHome> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ModernDashboard(),
    ChallengesScreen(),
    StatsScreen(),
    SuggestionsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddMoodPressed() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MoodEntryScreen()),
    );
    // If a mood was successfully entered, refresh relevant providers
    if (result == true && mounted) {
      ref.refresh(moodStatsProvider);
      ref.refresh(userStreakProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddMoodPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_reaction_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              label: 'Uitdagingen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Statistieken',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Suggesties',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
        ),
      ),
    );
  }
}

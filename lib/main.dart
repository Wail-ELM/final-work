import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/profile_screen.dart';

import 'screens/modern_dashboard.dart'; // Import du nouveau dashboard
import 'screens/challenges.dart';
import 'screens/stats.dart';
import 'screens/suggestions.dart';
import 'screens/onboarding_screen.dart';
import 'screens/mood_entry_screen.dart'; // Added import for MoodEntryScreen
// Hide potentially conflicting names from the service file if they are also defined in provider files
import 'services/auth_service.dart' hide authServiceProvider, authStateProvider;
import 'services/notification_service.dart'; // Import du service

// Hive-modellen
import 'models/challenge.dart';
import 'models/mood_entry.dart';
import 'models/challenge_category_adapter.dart';
import 'models/screen_time_entry.dart';
import 'core/design_system.dart'; // Import du nouveau design system

// Import providers needed for AppUsageService start/stop
import 'providers/auth_provider.dart'; // Provides authStateProvider
import 'providers/user_objective_provider.dart'; // Provides appUsageServiceProvider
import 'providers/theme_provider.dart'; // Import the new themeModeProvider

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

  // Ouvrir les boîtes
  await Hive.openBox<Challenge>('challenges');
  await Hive.openBox<MoodEntry>('moods');
  await Hive.openBox<ScreenTimeEntry>('screen_time');

  // Initialiser le service de notification
  final notificationService = NotificationService();
  await notificationService.init();
  notificationService.setNavigatorKey(navigatorKey); // Set the navigator key

  runApp(const ProviderScope(child: RootDecider()));
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
    final themeMode = ref.watch(themeModeProvider);

    // Show a splash screen while checking the onboarding status.
    if (_onboardingComplete == null) {
      return MaterialApp(
        theme: AppDesignSystem.lightTheme,
        darkTheme: AppDesignSystem.darkTheme,
        themeMode: themeMode,
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
        themeMode: themeMode,
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
    final themeMode = ref.watch(themeModeProvider); // Get themeMode

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

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Social Balans',
      debugShowCheckedModeBanner: false,
      theme: AppDesignSystem.lightTheme,
      darkTheme: AppDesignSystem.darkTheme,
      themeMode: themeMode, // Use themeMode from provider
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
  int _currentIndex = 0;

  // 🚀 UTILISATION DU NOUVEAU DASHBOARD MODERNE !
  static const _screens = [
    ModernDashboard(), // ← NOUVEAU DASHBOARD PREMIUM !
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
    Icons.home_outlined,
    Icons.flag_outlined,
    Icons.bar_chart_outlined,
    Icons.lightbulb_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _labels[_currentIndex],
          style: AppDesignSystem.heading3,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Modern profile button
          Container(
            margin: const EdgeInsets.only(right: AppDesignSystem.space8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppDesignSystem.primaryBlue,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
          // Modern logout button
          Container(
            margin: const EdgeInsets.only(right: AppDesignSystem.space16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.error.withOpacity(0.1),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.logout,
                  color: AppDesignSystem.error,
                ),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDesignSystem.borderRadiusLarge,
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.logout, color: AppDesignSystem.error),
                        const SizedBox(width: AppDesignSystem.space12),
                        const Text('Uitloggen'),
                      ],
                    ),
                    content: const Text(
                      'Weet je zeker dat je wilt uitloggen?',
                    ),
                    actions: [
                      ModernButton(
                        text: 'Annuleren',
                        isPrimary: false,
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      const SizedBox(width: AppDesignSystem.space12),
                      ModernButton(
                        text: 'Uitloggen',
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  await ref.read(authServiceProvider).signOut();
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(child: _screens[_currentIndex]),
      // 🎨 NOUVELLE NAVIGATION BAR MODERNE
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDesignSystem.radiusLarge),
            topRight: Radius.circular(AppDesignSystem.radiusLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          destinations: List.generate(
            _labels.length,
            (index) => NavigationDestination(
              icon: Icon(_icons[index]),
              selectedIcon: Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  _icons[index],
                  color: AppDesignSystem.primaryBlue,
                ),
              ),
              label: _labels[index],
            ),
          ),
        ),
      ),
    );
  }
}

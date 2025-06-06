import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for url_launcher
// import 'package:shared_preferences/shared_preferences.dart'; // No longer directly needed here
import '../services/notification_service.dart';
import '../providers/user_objective_provider.dart'; // Provides userPreferencesProvider
import '../core/design_system.dart'; // For AppDesignSystem if used in dialogs, etc.
import 'profile_screen.dart'; // Import ProfileScreen
import '../main.dart'; // Import main to access packageInfoProvider

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local state for UI, initialized from provider
  // Let's remove local state for values that are now directly in the provider.
  // We will read them directly from the provider in the build method.
  // This simplifies state management significantly.
  // late bool _notificationsEnabled;
  // late Duration _dailyScreenTimeGoal;
  // late List<String> _focusAreas;
  // late bool _darkMode;

  // We only need a loading flag.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pre-loading can be tricky with providers.
    // The userPreferencesProvider now handles its own loading state,
    // so we can rely on ref.watch in the build method. Let's simplify.
    // Let's remove _loadSettingsFromProvider and manage loading in the build method.
    // _loadSettingsFromProvider();
  }

  // _loadSettingsFromProvider is no longer needed

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild when preferences change.
    // This is the single source of truth for the settings UI.
    final userPrefs = ref.watch(userPreferencesProvider);
    final packageInfoAsync =
        ref.watch(packageInfoProvider); // Watch the new provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Compte',
            [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Mijn Profiel'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'Notificaties',
            [
              SwitchListTile(
                title: const Text('Notificaties inschakelen'),
                subtitle: const Text(
                    'Ontvang herinneringen voor humeur, pauzes en doelen'),
                value: userPrefs
                    .notificationsEnabled, // Read directly from provider
                onChanged: (value) {
                  // No need for setState, provider update will rebuild the widget.
                  ref.read(userPreferencesProvider.notifier).updatePreferences(
                      userPrefs.copyWith(notificationsEnabled: value));
                  NotificationService().updateNotificationSettings(value);
                },
              ),
              if (userPrefs.notificationsEnabled) ...[
                // Read directly from provider
                const ListTile(
                  title: Text('Dagelijkse humeur herinnering'),
                  subtitle: Text('Elke dag om 20:00'),
                ),
                const ListTile(
                  title: Text('Pauze herinneringen'),
                  subtitle: Text('Elke 2 uur tussen 9:00 en 21:00'),
                ),
                const ListTile(
                  title: Text('Wekelijkse doelen'),
                  subtitle: Text('Elke maandag om 10:00'),
                ),
              ],
            ],
          ),
          _buildSection(
            'Schermtijd',
            [
              ListTile(
                enabled: userPrefs
                    .isScreenTimeLimitEnabled, // Enable/disable based on the switch
                title: const Text('Dagelijks doel'),
                subtitle: Text(
                    '${userPrefs.dailyScreenTimeGoal.inHours}u ${userPrefs.dailyScreenTimeGoal.inMinutes % 60}m'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  // onPressed can be null to disable the button
                  onPressed: userPrefs.isScreenTimeLimitEnabled
                      ? () async {
                          final newGoal = await _showScreenTimeGoalDialog(
                              userPrefs.dailyScreenTimeGoal);
                          if (newGoal != null) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .updatePreferences(userPrefs.copyWith(
                                    dailyScreenTimeGoal: newGoal));
                          }
                        }
                      : null,
                ),
              ),
              SwitchListTile(
                title: const Text('Schermtijd limiet'),
                subtitle: const Text(
                    'Krijg een melding wanneer je je dagelijkse doel bereikt'),
                value: userPrefs.isScreenTimeLimitEnabled, // Read from provider
                onChanged: (value) {
                  ref.read(userPreferencesProvider.notifier).updatePreferences(
                      userPrefs.copyWith(isScreenTimeLimitEnabled: value));
                  // The actual notification logic for this will be triggered elsewhere,
                  // based on this preference value.
                },
              ),
            ],
          ),
          _buildSection(
            'Focus gebieden',
            [
              ...userPrefs.focusAreas.map((area) => ListTile(
                    title: Text(area),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final updatedAreas =
                            List<String>.from(userPrefs.focusAreas)
                              ..remove(area);
                        ref
                            .read(userPreferencesProvider.notifier)
                            .updatePreferences(
                                userPrefs.copyWith(focusAreas: updatedAreas));
                      },
                    ),
                  )),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Nieuw focus gebied'),
                onTap: () async {
                  final newArea = await _showAddFocusAreaDialog();
                  if (newArea != null && newArea.isNotEmpty) {
                    final updatedAreas = List<String>.from(userPrefs.focusAreas)
                      ..add(newArea);
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updatePreferences(
                            userPrefs.copyWith(focusAreas: updatedAreas));
                  }
                },
              ),
            ],
          ),
          _buildSection(
            'Weergave',
            [
              SwitchListTile(
                title: const Text('Donker thema'),
                subtitle: const Text('Schakel tussen licht en donker thema'),
                value: userPrefs.darkMode,
                onChanged: (value) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updatePreferences(userPrefs.copyWith(darkMode: value));
                },
              ),
            ],
          ),
          _buildSection(
            'Over',
            [
              packageInfoAsync.when(
                data: (info) => ListTile(
                  title: const Text('Versie'),
                  subtitle: Text('${info.version} (build ${info.buildNumber})'),
                ),
                loading: () => const ListTile(
                  title: Text('Versie'),
                  subtitle: Text('Laden...'),
                ),
                error: (err, stack) => const ListTile(
                  title: Text('Versie'),
                  subtitle: Text('Niet beschikbaar'),
                ),
              ),
              ListTile(
                title: const Text('Privacybeleid'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://your-privacy-policy-url.com'); // Replace with your actual URL
                  if (!await launchUrl(url)) {
                    // Could show a snackbar if unable to launch
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Kon de URL niet openen: ${url.toString()}')),
                    );
                  }
                },
              ),
              ListTile(
                title: const Text('Voorwaarden'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://your-terms-of-service-url.com'); // Replace with your actual URL
                  if (!await launchUrl(url)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Kon de URL niet openen: ${url.toString()}')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Future<Duration?> _showScreenTimeGoalDialog(Duration initialGoal) async {
    // Pass initialGoal
    Duration tempGoal = initialGoal;
    // Use a StatefulWidget for the dialog content if live updates inside the dialog are needed
    // For simplicity, we'll update tempGoal and return it.
    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        // To make dropdowns reflect changes, dialog needs its own state or a more complex setup.
        // Or, update _dailyScreenTimeGoal directly in onChanged and rebuild the dialog (less ideal).
        // Let's try to manage tempGoal for the dialog.
        int currentHours = tempGoal.inHours;
        int currentMinutes = tempGoal.inMinutes % 60;

        return AlertDialog(
          title: const Text('Dagelijks schermtijd doel'),
          content: StatefulBuilder(
            // Use StatefulBuilder to update dialog content
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: currentHours,
                          decoration: const InputDecoration(labelText: 'Uren'),
                          items: List.generate(
                              24,
                              (index) => DropdownMenuItem(
                                  value: index, child: Text('$index'))),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                currentHours = value;
                                tempGoal = Duration(
                                    hours: currentHours,
                                    minutes: currentMinutes);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: currentMinutes,
                          decoration:
                              const InputDecoration(labelText: 'Minuten'),
                          items: List.generate(
                              60,
                              (index) => DropdownMenuItem(
                                  value: index, child: Text('$index'))),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                currentMinutes = value;
                                tempGoal = Duration(
                                    hours: currentHours,
                                    minutes: currentMinutes);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempGoal),
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showAddFocusAreaDialog() async {
    // ... (remains largely the same, ensure controller text is returned)
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nieuw focus gebied'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Naam',
            hintText: 'Voer een naam in',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }
}

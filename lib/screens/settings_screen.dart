import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for url_launcher
// import 'package:shared_preferences/shared_preferences.dart'; // No longer directly needed here
import '../services/notification_service.dart';
import '../providers/user_preferences_provider.dart';
import '../core/design_system.dart'; // For AppDesignSystem if used in dialogs, etc.
import 'profile_screen.dart'; // Import ProfileScreen
import '../main.dart'; // Import main to access packageInfoProvider

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final userPrefsNotifier = ref.read(userPreferencesProvider.notifier);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
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
            context,
            'Notificaties',
            [
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notificatie instellingen'),
                subtitle: const Text('Beheer herinneringen en meldingen'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/notification-settings');
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Schermtijd',
            [
              ListTile(
                enabled: userPrefs.isScreenTimeLimitEnabled,
                title: const Text('Dagelijks doel'),
                subtitle: Text(
                    '${userPrefs.dailyScreenTimeGoal.inHours}u ${userPrefs.dailyScreenTimeGoal.inMinutes % 60}m'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: userPrefs.isScreenTimeLimitEnabled
                      ? () async {
                          final newGoal = await _showScreenTimeGoalDialog(
                              context, userPrefs.dailyScreenTimeGoal);
                          if (newGoal != null) {
                            userPrefsNotifier.setDailyScreenTimeGoal(newGoal);
                          }
                        }
                      : null,
                ),
              ),
              SwitchListTile(
                title: const Text('Schermtijd limiet'),
                subtitle: const Text(
                    'Krijg een melding wanneer je je dagelijkse doel bereikt'),
                value: userPrefs.isScreenTimeLimitEnabled,
                onChanged: (value) {
                  userPrefsNotifier.setIsScreenTimeLimitEnabled(value);
                },
              ),
            ],
          ),
          _buildSection(
            context,
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
                        userPrefsNotifier.setFocusAreas(updatedAreas);
                      },
                    ),
                  )),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Nieuw focus gebied'),
                onTap: () async {
                  final newArea = await _showAddFocusAreaDialog(context);
                  if (newArea != null && newArea.isNotEmpty) {
                    final updatedAreas = List<String>.from(userPrefs.focusAreas)
                      ..add(newArea);
                    userPrefsNotifier.setFocusAreas(updatedAreas);
                  }
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Weergave',
            [
              SwitchListTile(
                title: const Text('Donker thema'),
                subtitle: const Text('Schakel tussen licht en donker thema'),
                value: userPrefs.darkMode,
                onChanged: (value) {
                  userPrefsNotifier.setDarkMode(value);
                },
              ),
            ],
          ),
          _buildSection(
            context,
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
                onTap: () =>
                    _launchURL('https://your-privacy-policy-url.com', context),
              ),
              ListTile(
                title: const Text('Voorwaarden'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchURL(
                    'https://your-terms-of-service-url.com', context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kon de URL niet openen: $url')),
      );
    }
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
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

  Future<Duration?> _showScreenTimeGoalDialog(
      BuildContext context, Duration initialGoal) async {
    Duration tempGoal = initialGoal;
    return await showDialog<Duration>(
      context: context,
      builder: (context) {
        int currentHours = tempGoal.inHours;
        int currentMinutes = tempGoal.inMinutes % 60;

        return AlertDialog(
          title: const Text('Dagelijks schermtijd doel'),
          content: StatefulBuilder(
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

  Future<String?> _showAddFocusAreaDialog(BuildContext context) async {
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

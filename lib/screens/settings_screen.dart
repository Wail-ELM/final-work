import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  Duration _dailyScreenTimeGoal = const Duration(hours: 4);
  List<String> _focusAreas = ['Focus', 'Ontspanning', 'Sociale contacten'];
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _dailyScreenTimeGoal = Duration(
        hours: prefs.getInt('screen_time_goal_hours') ?? 4,
        minutes: prefs.getInt('screen_time_goal_minutes') ?? 0,
      );
      _focusAreas = prefs.getStringList('focus_areas') ??
          ['Focus', 'Ontspanning', 'Sociale contacten'];
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('screen_time_goal_hours', _dailyScreenTimeGoal.inHours);
    await prefs.setInt(
        'screen_time_goal_minutes', _dailyScreenTimeGoal.inMinutes % 60);
    await prefs.setStringList('focus_areas', _focusAreas);
    await prefs.setBool('dark_mode', _darkMode);

    // Mettre à jour les notifications
    await NotificationService()
        .updateNotificationSettings(_notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Instellingen opslaan',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            'Notificaties',
            [
              SwitchListTile(
                title: const Text('Notificaties inschakelen'),
                subtitle: const Text(
                    'Ontvang herinneringen voor humeur, pauzes en doelen'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              if (_notificationsEnabled) ...[
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
                title: const Text('Dagelijks doel'),
                subtitle: Text(
                    '${_dailyScreenTimeGoal.inHours}u ${_dailyScreenTimeGoal.inMinutes % 60}m'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showScreenTimeGoalDialog,
                ),
              ),
              SwitchListTile(
                title: const Text('Schermtijd limiet'),
                subtitle: const Text(
                    'Krijg een melding wanneer je je dagelijkse doel bereikt'),
                value: true,
                onChanged: (value) {
                  // TODO: Implémenter la logique de limite
                },
              ),
            ],
          ),
          _buildSection(
            'Focus gebieden',
            [
              ..._focusAreas.map((area) => ListTile(
                    title: Text(area),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _focusAreas.remove(area));
                      },
                    ),
                  )),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Nieuw focus gebied'),
                onTap: _showAddFocusAreaDialog,
              ),
            ],
          ),
          _buildSection(
            'Weergave',
            [
              SwitchListTile(
                title: const Text('Donker thema'),
                subtitle: const Text('Schakel tussen licht en donker thema'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                },
              ),
            ],
          ),
          _buildSection(
            'Over',
            [
              const ListTile(
                title: Text('Versie'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Privacybeleid'),
                onTap: () {
                  // TODO: Naviguer vers la politique de confidentialité
                },
              ),
              ListTile(
                title: const Text('Voorwaarden'),
                onTap: () {
                  // TODO: Naviguer vers les conditions d'utilisation
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

  Future<void> _showScreenTimeGoalDialog() async {
    final hours = _dailyScreenTimeGoal.inHours;
    final minutes = _dailyScreenTimeGoal.inMinutes % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dagelijks schermtijd doel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: hours,
                    decoration: const InputDecoration(
                      labelText: 'Uren',
                    ),
                    items: List.generate(24, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _dailyScreenTimeGoal = Duration(
                            hours: value,
                            minutes: minutes,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: minutes,
                    decoration: const InputDecoration(
                      labelText: 'Minuten',
                    ),
                    items: List.generate(60, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _dailyScreenTimeGoal = Duration(
                            hours: hours,
                            minutes: value,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _dailyScreenTimeGoal),
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _dailyScreenTimeGoal = result);
    }
  }

  Future<void> _showAddFocusAreaDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
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

    if (result != null) {
      setState(() => _focusAreas.add(result));
    }
  }
}

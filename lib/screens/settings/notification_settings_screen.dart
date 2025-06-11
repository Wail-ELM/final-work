import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificatie instellingen'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Algemeen'),
          SwitchListTile.adaptive(
            title: const Text('Alle notificaties'),
            subtitle: const Text('Hoofdschakelaar voor alle app-notificaties'),
            value: prefs.notificationsEnabled,
            onChanged: (value) {
              prefsNotifier.setNotificationsEnabled(value);
            },
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
          const Divider(height: 1),
          _buildSectionHeader(context, 'Herinneringen'),
          SwitchListTile.adaptive(
            title: const Text('Dagelijkse herinnering'),
            subtitle: const Text('Herinnering om je stemming te registreren'),
            value: prefs.dailyReminderEnabled,
            onChanged: prefs.notificationsEnabled
                ? (value) {
                    prefsNotifier.setDailyReminderEnabled(value);
                  }
                : null,
            secondary: const Icon(Icons.wb_sunny_outlined),
          ),
          ListTile(
            title: const Text('Tijdstip dagelijkse herinnering'),
            trailing: Text(prefs.dailyReminderTime.format(context)),
            onTap: prefs.notificationsEnabled && prefs.dailyReminderEnabled
                ? () async {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: prefs.dailyReminderTime,
                    );
                    if (newTime != null) {
                      prefsNotifier.setDailyReminderTime(newTime);
                    }
                  }
                : null,
            leading: const Icon(Icons.access_time_outlined),
          ),
          const Divider(height: 1),
          _buildSectionHeader(context, 'Uitdagingen'),
          SwitchListTile.adaptive(
            title: const Text('Updates over uitdagingen'),
            subtitle: const Text('Voortgang, voltooiing en nieuwe uitdagingen'),
            value: prefs.challengeUpdatesEnabled,
            onChanged: prefs.notificationsEnabled
                ? (value) {
                    prefsNotifier.setChallengeUpdatesEnabled(value);
                  }
                : null,
            secondary: const Icon(Icons.flag_outlined),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.notification_important_outlined),
              label: const Text('Test Notificatie'),
              onPressed: () {
                ref.read(notificationServiceProvider).showTestNotification();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppDesignSystem.primaryGreen,
                backgroundColor: AppDesignSystem.primaryGreen.withOpacity(0.1),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppDesignSystem.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

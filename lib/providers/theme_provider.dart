import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_objective_provider.dart'; // To access userPreferencesProvider

final themeModeProvider = Provider<ThemeMode>((ref) {
  final darkModeEnabled =
      ref.watch(userPreferencesProvider.select((prefs) => prefs.darkMode));
  return darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
});

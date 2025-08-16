import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
import 'package:social_balans/providers/challenge_provider.dart';
import 'package:social_balans/screens/challenges.dart';
import 'package:social_balans/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show User; // alleen User type

class _FakeUser extends User {
  _FakeUser(String id)
      : super(
          id: id,
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
}

class StubAuthService extends AuthService {
  final User? _user = _FakeUser('user_widget');
  @override
  User? get currentUser => _user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<Challenge> box;

  Challenge c(String id, {bool done = false}) => Challenge(
        id: id,
        userId: 'user_widget',
        title: 'Titel$id',
        description: 'Beschrijving$id',
        category: ChallengeCategory.focus,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 8),
        isDone: done,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_widget');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChallengeAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(ChallengeCategoryAdapter());
    box = await Hive.openBox<Challenge>('challenges'); // open één keer
  });

  setUp(() async {
    await box.clear();
    await box.put('c1', c('c1'));
    await box.put('c2', c('c2', done: true));
  });

  tearDown(() async {
    // Alleen clear voor isolatie; niet sluiten om init overhead te vermijden
    await box.clear();
  });

  Widget _buildTestApp() {
    return ProviderScope(
      overrides: [
        challengeBoxProvider.overrideWithValue(box),
        authServiceProvider.overrideWithValue(StubAuthService()),
      ],
      child: const MaterialApp(home: ChallengesScreen()),
    );
  }

  testWidgets('lijst tonen, toggelen en tab wissel snel', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text('Titelc1'), findsOneWidget);

      final button = find.widgetWithText(ElevatedButton, 'Voltooien').first;
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.widgetWithText(ElevatedButton, 'Herstarten'), findsWidgets);

      // Kies specifiek de Tab met label 'Voltooid' (eerste match) om ambiguïteit te vermijden
      await tester.tap(find.text('Voltooid').first);
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('Titelc2'), findsOneWidget);
    });
  });
}

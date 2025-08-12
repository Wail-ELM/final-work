import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';
import 'package:social_balans/providers/challenge_provider.dart';
import 'package:social_balans/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User; // alleen voor User type

class FakeUser extends User {
  FakeUser(String id)
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
  final User? _user = FakeUser('user1');
  @override
  User? get currentUser => _user; // geen Supabase.instance toegang
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Challenge> box;
  late ProviderContainer container;

  final now = DateTime.now();
  Challenge newChallenge(String id, {bool done=false}) => Challenge(
    id: id,
    userId: 'user1',
    title: 'T$id',
    description: 'D$id',
    category: ChallengeCategory.focus,
    startDate: DateTime(now.year, now.month, now.day),
    endDate: DateTime(now.year, now.month, now.day + 7),
    isDone: done,
    createdAt: now,
    updatedAt: now,
  );

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_challenges_min');
    Hive.init(tempDir.path);
    if(!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChallengeAdapter());
    if(!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ChallengeCategoryAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<Challenge>('challenges_test');
    await box.clear();
    container = ProviderContainer(overrides: [
      challengeBoxProvider.overrideWithValue(box),
      authServiceProvider.overrideWithValue(StubAuthService()),
    ]);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('challenges_test');
    container.dispose();
  });

  test('add() bewaart challenge', () async {
    final c = newChallenge('c1');
    await container.read(allChallengesProvider.notifier).add(c);
    expect(box.get('c1')?.id, c.id);
  });

  test('toggleDone() wisselt status', () async {
    final c = newChallenge('c2');
    await box.put(c.id, c);
    await container.read(allChallengesProvider.notifier).toggleDone(c.id);
    expect(box.get(c.id)?.isDone, true);
  });

  test('update() wijzigt titel', () async {
    final c = newChallenge('c3');
    await box.put(c.id, c);
    final updated = c.copyWith(title: 'Nieuw');
    await container.read(allChallengesProvider.notifier).update(updated);
    expect(box.get(c.id)?.title, 'Nieuw');
  });

  test('remove() verwijdert item', () async {
    final c = newChallenge('c4');
    await box.put(c.id, c);
    await container.read(allChallengesProvider.notifier).remove(c.id);
    expect(box.get(c.id), isNull);
  });
}

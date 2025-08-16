import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:social_balans/models/mood_entry.dart';
import 'package:social_balans/providers/mood_provider.dart';
import 'package:social_balans/services/auth_service.dart';
import 'package:social_balans/services/user_data_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User; // alleen User

// Fake User voor auth
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
  User? get currentUser => _user;
}

// Fake UserDataService als subclass voor correcte type matching
class StubUserDataService extends UserDataService {
  final List<MoodEntry> remoteEntries;
  bool addCalled = false;
  StubUserDataService(this.remoteEntries);

  @override
  Future<List<MoodEntry>> getMoodEntries({required String userId, DateTime? startDate, DateTime? endDate}) async {
    return remoteEntries;
  }

  @override
  Future<void> addMoodEntry({required String userId, required int moodValue, String? note, String? id, DateTime? createdAt}) async {
    addCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<MoodEntry> box;
  late ProviderContainer container;
  late StubUserDataService fakeService;

  final now = DateTime.now();
  MoodEntry entry(String id, int mood, DateTime ts) => MoodEntry(
        id: id,
        userId: 'user1',
        moodValue: mood,
        note: 'n$id',
        createdAt: ts,
      );

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_moods');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MoodEntryAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<MoodEntry>('moods');
    await box.clear();
    final today = DateTime(now.year, now.month, now.day, 10);
    final yesterday = today.subtract(const Duration(days: 1));
    fakeService = StubUserDataService([
      entry('r1', 4, today),
      entry('r2', 2, yesterday),
    ]);

    container = ProviderContainer(overrides: [
      moodsBoxProvider.overrideWithValue(box),
      authServiceProvider.overrideWithValue(StubAuthService()),
      userDataServiceProvider.overrideWithValue(fakeService),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await box.close();
    await Hive.deleteBoxFromDisk('moods');
  });

  test('initiale load haalt remote entries op', () async {
    // Wacht totdat state gevuld is (poll tot 500ms)
    final start = DateTime.now();
    while (container.read(moodsProvider).isEmpty && DateTime.now().difference(start).inMilliseconds < 500) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    final list = container.read(moodsProvider);
    expect(list.length, 2);
    expect(list.first.userId, 'user1');
  });

  test('add() voegt lokaal toe en probeert remote sync', () async {
    final notifier = container.read(moodsProvider.notifier);
    final newE = entry('loc1', 5, now.add(const Duration(minutes: 5)));
    await notifier.add(newE);
    expect(box.get('loc1')?.moodValue, 5);
  });

  test('moodStatsProvider berekent statistieken', () {
    // Vul box handmatig
    final today = DateTime(now.year, now.month, now.day, 9);
    final twoHoursLater = today.add(const Duration(hours: 2));
    box.put('a1', entry('a1', 4, today));
    box.put('a2', entry('a2', 2, twoHoursLater));

    final stats = container.read(moodStatsProvider);
    expect(stats.count >= 2, true);
    expect(stats.averageMood > 0, true);
  });
}

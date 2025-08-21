import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/services/user_data_service.dart';
import 'package:social_balans/models/screen_time_entry.dart';

class FakeSupabaseClient {
  List<Map<String, dynamic>> fakeEntries = [];
  dynamic from(String table) => this;
  dynamic select() => this;
  dynamic eq(String key, dynamic value) => this;
  dynamic order(String key, {bool ascending = false}) => fakeEntries;
  Future<dynamic> insert(Map<String, dynamic> payload) async {
    fakeEntries.add(payload);
    return [{}];
  }
}

void main() {
  group('UserDataService schermtijd', () {
    test('addScreenTimeEntry voegt een item toe', () async {
      final fake = FakeSupabaseClient();
      final service = UserDataService(clientOverride: fake);
      await service.addScreenTimeEntry(
        userId: 'u1',
        appName: 'App1',
        duration: const Duration(minutes: 90),
        date: DateTime(2025, 1, 1),
      );
      expect(fake.fakeEntries.length, 1);
      expect(fake.fakeEntries.first['app_name'], 'App1');
    });
    test('getScreenTimeEntries geeft de items terug', () async {
      final fake = FakeSupabaseClient();
      fake.fakeEntries = [
        {
          'user_id': 'u1',
          'app_name': 'App1',
          'duration': 5400,
          'date': '2025-01-01',
          'created_at': '2025-01-01T10:00:00Z',
        }
      ];
      final service = UserDataService(clientOverride: fake);
      final res = await service.getScreenTimeEntries(
          userId: 'u1', date: DateTime(2025, 1, 1));
      expect(res.length, 1);
      expect(res.first.appName, 'App1');
      expect(res.first.duration, const Duration(seconds: 5400));
    });
  });
}

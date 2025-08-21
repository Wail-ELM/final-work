import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/services/user_data_service.dart';
import 'package:social_balans/models/mood_entry.dart';

class FailingSupabaseClient {
  String failOn;
  FailingSupabaseClient(this.failOn);
  dynamic from(String table) => this;
  dynamic select() => this;
  dynamic eq(String key, dynamic value) => this;
  dynamic order(String key, {bool ascending = false}) =>
      throw Exception('fail');
  Future<dynamic> insert(Map<String, dynamic> payload) async =>
      throw Exception('fail');
}

void main() {
  group('UserDataService stemming robuustheid', () {
    test('getMoodEntries behandelt een netwerkfout', () async {
      final service =
          UserDataService(clientOverride: FailingSupabaseClient('get'));
      try {
        await service.getMoodEntries(userId: 'u1');
  fail('Had een exceptie moeten gooien');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  test('addMoodEntry behandelt een netwerkfout', () async {
      final service =
          UserDataService(clientOverride: FailingSupabaseClient('add'));
      try {
        await service.addMoodEntry(userId: 'u1', moodValue: 3);
  fail('Had een exceptie moeten gooien');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}

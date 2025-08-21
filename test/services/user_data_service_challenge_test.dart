import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/services/user_data_service.dart';
import 'package:social_balans/models/challenge.dart';

class FakeSupabaseClient {
  final List<String> called = [];
  Map<String, dynamic>? lastParams;
  List<Map<String, dynamic>> fakeChallenges = [];
  dynamic lastPayload;

  dynamic from(String table) {
    called.add('from:$table');
    return this;
  }

  dynamic select() {
    called.add('select');
    return this;
  }

  dynamic eq(String key, dynamic value) {
    called.add('eq:$key=$value');
    return this;
  }

  dynamic order(String key, {bool ascending = false}) {
    called.add('order:$key');
    // Return fakeChallenges for challenge view, else empty list
    return fakeChallenges;
  }

  Future<dynamic> insert(Map<String, dynamic> payload) async {
    lastPayload = payload;
    called.add('insert');
    return [{}];
  }

  Future<dynamic> update(Map<String, dynamic> payload) async {
    lastPayload = payload;
    called.add('update');
    return [{}];
  }

  Future<dynamic> delete() async {
    called.add('delete');
    return [{}];
  }

  Future<dynamic> rpc(String fn, {Map<String, dynamic>? params}) async {
    called.add('rpc:$fn');
    lastParams = params;
    return 1; // Simulate success
  }
}

void main() {
  group('UserDataService challenge (hybride)', () {
    late UserDataService service;
    late FakeSupabaseClient fake;

    setUp(() {
      fake = FakeSupabaseClient();
      service = UserDataService(clientOverride: fake);
    });

  test('addChallenge roept de juiste RPC aan met correcte parameters', () async {
      await service.addChallenge(
        userId: 'u1',
        id: 'c1',
        title: 'Test',
        description: 'Desc',
        category: 'focus',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 7),
        isDone: false,
      );
      expect(fake.called.contains('rpc:ensure_template_and_add_user_challenge'),
          true);
      expect(fake.lastParams?['p_user_id'], 'u1');
      expect(fake.lastParams?['p_title'], 'Test');
    });

  test('updateChallenge roept de juiste RPC aan', () async {
      await service.updateChallenge(
        challengeId: 'c1',
        title: 'Nouveau',
        isDone: true,
      );
      expect(fake.called.contains('rpc:update_user_challenge'), true);
      expect(fake.lastParams?['p_id'], 'c1');
      expect(fake.lastParams?['p_title'], 'Nouveau');
      expect(fake.lastParams?['p_is_done'], true);
    });

  test('deleteChallenge roept de juiste RPC aan', () async {
      await service.deleteChallenge(challengeId: 'c1');
      expect(fake.called.contains('rpc:delete_user_challenge'), true);
      expect(fake.lastParams?['p_id'], 'c1');
    });

  test('getChallenges gebruikt de juiste view en filtert isDone', () async {
      fake.fakeChallenges = [
        {
          'id': 'c1',
          'user_id': 'u1',
          'title': 'Test',
          'category': 'focus',
          'is_done': false,
          'start_date': '2025-01-01',
          'end_date': '2025-01-07',
          'created_at': '2025-01-01T00:00:00Z',
          'updated_at': '2025-01-01T00:00:00Z',
        }
      ];
      final res = await service.getChallenges(userId: 'u1', isDone: false);
      expect(fake.called.contains('from:challenges_view'), true);
      expect(fake.called.contains('eq:user_id=u1'), true);
      expect(fake.called.contains('eq:is_done=false'), true);
      expect(res.first.title, 'Test');
    });
  });
}

// plus besoin d'extension, injection par constructeur

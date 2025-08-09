import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/models/challenge.dart';
import 'package:social_balans/models/challenge_category_adapter.dart';

void main() {
  group('Challenge model', () {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 7));
    final challenge = Challenge(
      id: 'c1',
      userId: 'u1',
      title: 'Test',
      description: 'Desc',
      category: ChallengeCategory.focus,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );

    test('copyWith werkt velden bij', () {
      final copy = challenge.copyWith(title: 'Nieuw');
      expect(copy.title, 'Nieuw');
      expect(copy.id, challenge.id);
    });

    test('toJson / fromJson rondje (alleen-datum velden)', () {
      final json = challenge.toJson();
      final from = Challenge.fromJson({
        ...json,
        'user_id': json['user_id'],
        'start_date': json['start_date'],
        'end_date': json['end_date'],
        'is_done': json['is_done'],
      });
      // Vergelijk alleen-datum velden apart
      expect(from.startDate, equals(challenge.startDate));
      expect(from.endDate, equals(challenge.endDate));
      expect(from.id, challenge.id);
      expect(from.userId, challenge.userId);
      expect(from.title, challenge.title);
      expect(from.description, challenge.description);
      expect(from.category, challenge.category);
      expect(from.isDone, challenge.isDone);
    });

    test('toJson/fromJson isDone waar', () {
      final now2 = DateTime.now();
      final challengeDone = challenge.copyWith(isDone: true, updatedAt: now2);
      final json = challengeDone.toJson();
      final from = Challenge.fromJson({
        ...json,
        'user_id': json['user_id'],
        'start_date': json['start_date'],
        'end_date': json['end_date'],
        'is_done': json['is_done'],
      });
      expect(from.isDone, true);
    });

    test('gelijkheid onderscheidt verschillende instanties', () {
      final other = challenge.copyWith(id: 'c2');
      expect(other == challenge, false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/main.dart';

void main() {
  testWidgets('SocialBalansApp se lance', (WidgetTester tester) async {
    // Ce test basique vérifie que l'app peut se lancer
    await tester.pumpWidget(const ProviderScope(child: SocialBalansAppMain()));

    // On vérifie juste que l'app se charge sans erreur
    expect(find.byType(SocialBalansAppMain), findsOneWidget);
  });
}

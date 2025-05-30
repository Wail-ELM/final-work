import 'package:flutter_test/flutter_test.dart';
import 'package:social_balans/main.dart';

void main() {
  testWidgets('MyApp se lance', (WidgetTester tester) async {
    // Ce test basique vérifie que l'app peut se lancer
    await tester.pumpWidget(const MyApp());

    // On vérifie juste que l'app se charge sans erreur
    expect(find.byType(MyApp), findsOneWidget);
  });
}

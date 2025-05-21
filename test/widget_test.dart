import 'package:flutter_test/flutter_test.dart';
// Ajuste ce package si le `name:` dans ton pubspec.yaml n’est pas 'final_work'
import 'package:final_work/main.dart';

void main() {
  testWidgets('MyApp se lance et affiche le titre', (WidgetTester tester) async {
    // Lance l’app
    await tester.pumpWidget(const MyApp());

    // Vérifie que l’AppBar affiche bien "Social Balans"
    expect(find.text('Social Balans'), findsOneWidget);
  });
}

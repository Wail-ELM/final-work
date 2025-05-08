import 'package:flutter_test/flutter_test.dart';
// Vérifie dans ton pubspec.yaml que le "name:" du package est bien 'final_work'.
// Si ce n’est pas le cas, ajuste ci-dessous l’import de main.dart :
import 'package:final_work/main.dart';

void main() {
  testWidgets('SocialBalansApp se lance et affiche le titre', (WidgetTester tester) async {
    // Monte le widget racine de l’app
    await tester.pumpWidget(const SocialBalansApp());

    // Vérifie que l’AppBar affiche bien "Social Balans"
    expect(find.text('Social Balans'), findsOneWidget);
  });
}

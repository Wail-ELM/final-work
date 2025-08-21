import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_balans/main.dart';

void main() {
  testWidgets('SocialBalansApp start', (WidgetTester tester) async {
    // Deze eenvoudige test controleert dat de app kan starten
    await tester.pumpWidget(const ProviderScope(child: SocialBalansAppMain()));

    // We controleren enkel dat de app zonder fouten laadt
    expect(find.byType(SocialBalansAppMain), findsOneWidget);
  });
}

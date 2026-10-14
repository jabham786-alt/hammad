import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ludo/main.dart';

void main() {
  testWidgets('menu starts a pass-and-play game', (tester) async {
    await tester.pumpWidget(const LudoApp());
    expect(find.text('LUDO'), findsOneWidget);
    await tester.tap(find.text('PASS & PLAY'));
    await tester.pumpAndSettle();
    expect(find.text('RED TURN'), findsOneWidget);
    expect(find.text('ROLL'), findsOneWidget);
  });
}

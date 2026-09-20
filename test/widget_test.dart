import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WomenSafetyApp());
    expect(find.text('WOMEN SAFETY'), findsNothing); // It's in the translations
  });
}

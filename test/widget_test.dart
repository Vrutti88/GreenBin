import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GreenBinApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenBinApp());
    // Advance time to allow splash delay timer to complete and navigate to Onboarding
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(GreenBinApp), findsOneWidget);
  });
}

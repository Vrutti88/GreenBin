import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/schedule/schedule_pickup_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/primary_button.dart';
import 'package:greenbin/widgets/secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildUnifiedApp() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const SchedulePickupScreen(),
    );
  }

  group('Unified Schedule -> Review -> Confirm -> Confirmation Flow', () {
    testWidgets(
        'SchedulePickupScreen has NO direct Firestore submission button and only ONE review action',
        (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildUnifiedApp());
      await tester.pumpAndSettle();

      // Verify that the old direct button NO LONGER EXISTS
      expect(find.text('Confirm & Schedule Pickup'), findsNothing);

      // Verify that the single primary review action exists
      expect(find.text('Review Pickup Details'), findsOneWidget);
    });

    testWidgets(
        'Complete end-to-end journey: Schedule -> Review -> Confirm -> Confirmation -> My Pickups',
        (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildUnifiedApp());
      await tester.pumpAndSettle();

      // 1. SCHEDULE SCREEN
      expect(find.text('Schedule Waste Pickup'), findsOneWidget);

      // Select 'Glass' category ChoiceChip
      final glassChip = find.widgetWithText(ChoiceChip, 'Glass');
      await tester.tap(glassChip);
      await tester.pumpAndSettle();

      // Enter Address & Notes
      final textFields = find.byType(TextFormField);
      await tester.enterText(
          textFields.at(0), '77 Eco Heights, Greenfield Park');
      await tester.enterText(textFields.at(2), 'Eco City');
      await tester.enterText(textFields.at(3), 'Side bin next to garage');
      await tester.pumpAndSettle();

      // Tap 'Review Pickup Details'
      final reviewBtn = find.widgetWithText(PrimaryButton, 'Review Pickup Details');
      await tester.ensureVisible(reviewBtn);
      await tester.pumpAndSettle();
      await tester.tap(reviewBtn);
      await tester.pumpAndSettle();

      // 2. REVIEW PICKUP SCREEN
      expect(find.text('Review Pickup'), findsOneWidget);
      expect(find.text('Glass'), findsWidgets);
      expect(find.text('77 Eco Heights, Greenfield Park'), findsWidgets);
      expect(find.text('Side bin next to garage'), findsOneWidget);

      // Test returning to Schedule screen preserving values via "Edit Details" button
      final editBtn = find.widgetWithText(SecondaryButton, 'Edit Details');
      await tester.ensureVisible(editBtn);
      await tester.pumpAndSettle();
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Back on Schedule Screen, verify values are still present
      expect(find.text('Schedule Waste Pickup'), findsOneWidget);
      expect(find.text('77 Eco Heights, Greenfield Park'), findsOneWidget);

      // Re-navigate to Review
      final reReviewBtn = find.widgetWithText(PrimaryButton, 'Review Pickup Details');
      await tester.ensureVisible(reReviewBtn);
      await tester.pumpAndSettle();
      await tester.tap(reReviewBtn);
      await tester.pumpAndSettle();

      // Back on Review Screen
      expect(find.text('Review Pickup'), findsOneWidget);

      // 3. CONFIRM PICKUP ACTION (THE ONLY WRITE CALL)
      final confirmBtn = find.widgetWithText(PrimaryButton, 'Confirm Pickup');
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // 4. CONFIRMATION SCREEN
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      // Ensure NO fake IDs appear
      expect(find.text('#GB-REV-2026'), findsNothing);
      expect(find.text('#GB-94821'), findsNothing);

      // 5. VIEW MY PICKUPS ACTION
      final viewPickupsBtn = find.text('View My Pickups');
      expect(viewPickupsBtn, findsOneWidget);
      await tester.tap(viewPickupsBtn);
      await tester.pumpAndSettle();

      // Navigated to My Pickups
      expect(find.text('My Pickups'), findsOneWidget);
    });
  });
}

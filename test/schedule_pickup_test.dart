import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/schedule/schedule_pickup_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/date_selector.dart';
import 'package:greenbin/widgets/time_slot_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const viewports = <String, Size>{
    'small mobile (320x480)': Size(320, 480),
    'small mobile landscape (568x320)': Size(568, 320),
    'standard mobile (390x844)': Size(390, 844),
    'standard mobile landscape (844x390)': Size(844, 390),
    'large mobile (428x926)': Size(428, 926),
    'large mobile landscape (926x428)': Size(926, 428),
    'tablet portrait (768x1024)': Size(768, 1024),
    'tablet landscape (1024x768)': Size(1024, 768),
    'desktop (1366x768)': Size(1366, 768),
    'wide desktop (1920x1080)': Size(1920, 1080),
  };

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildScheduleApp({String? initialCategory}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: SchedulePickupScreen(initialCategory: initialCategory),
    );
  }

  group('Schedule Pickup Screen - Form Structure & Required Fields', () {
    testWidgets('renders all required form fields and 5 official categories',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildScheduleApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Screen Title
      expect(find.text('Schedule Waste Pickup'), findsOneWidget);

      // Verify Flutter Form
      expect(find.byType(Form), findsOneWidget);

      // Verify Field 1: Categories
      expect(find.textContaining('1. Select Recyclable Category'), findsOneWidget);
      for (final cat in WasteCategoryItem.defaultCategories) {
        expect(find.text(cat.name), findsWidgets);
      }

      // Verify Field 2: Subcategories (Optional items)
      expect(
          find.textContaining('2. Accepted Items in Batch'), findsOneWidget);

      // Verify Field 3: Pickup Date
      expect(find.textContaining('3. Pickup Date'), findsOneWidget);
      expect(find.byType(DateSelector), findsOneWidget);

      // Verify Field 4: Time Slot & the 5 Required Time Windows
      expect(find.textContaining('Preferred Time Slot'), findsOneWidget);
      expect(find.byType(TimeSlotSelector), findsOneWidget);
      expect(find.text('8:00 AM - 10:00 AM'), findsOneWidget);
      expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);
      expect(find.text('12:00 PM - 2:00 PM'), findsOneWidget);
      expect(find.text('2:00 PM - 4:00 PM'), findsOneWidget);
      expect(find.text('4:00 PM - 6:00 PM'), findsOneWidget);

      // Verify Field 5: Pickup Address
      expect(find.textContaining('4. Pickup Address'), findsOneWidget);
      expect(find.text('Street Address, House / Unit #'), findsOneWidget);

      // Verify Field 6: Notes (Optional)
      expect(find.textContaining('5. Notes for Collection Crew'),
          findsOneWidget);

      // Verify Action Button
      expect(find.text('Confirm & Schedule Pickup'), findsOneWidget);
    });

    testWidgets('pre-selects initialCategory passed into the screen',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildScheduleApp(initialCategory: 'Glass'));
      await tester.pumpAndSettle();

      final glassChip = find.widgetWithText(ChoiceChip, 'Glass');
      expect(glassChip, findsOneWidget);
      final chipWidget = tester.widget<ChoiceChip>(glassChip);
      expect(chipWidget.selected, isTrue);
    });
  });

  group('Schedule Pickup Screen - Form Validation Rules', () {
    testWidgets('submitting with empty street address displays validation error',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildScheduleApp());
      await tester.pumpAndSettle();

      // Submit without entering street address
      final submitBtn = find.text('Confirm & Schedule Pickup');
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your pickup street address.'), findsOneWidget);
      expect(find.text('Please complete all required fields correctly.'),
          findsOneWidget);
    });

    testWidgets('switching time slot updates selection', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildScheduleApp());
      await tester.pumpAndSettle();

      final slotFinder = find.text('2:00 PM - 4:00 PM');
      expect(slotFinder, findsOneWidget);

      await tester.tap(slotFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Schedule Pickup Screen - Successful Submission Flow', () {
    testWidgets(
        'valid form submission saves pickup and shows confirmation dialog',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildScheduleApp(initialCategory: 'Paper & Cardboard'));
      await tester.pumpAndSettle();

      // Enter valid street and city into TextFormFields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4));

      // Index 0: Street Address
      await tester.enterText(
          textFields.at(0), '42 Elm Street, Maple Residency, Apt 3B');

      // Index 2: City
      await tester.enterText(textFields.at(2), 'Springfield West');

      // Index 3: Notes
      await tester.enterText(textFields.at(3), 'Call on gate 2 arrival');

      await tester.pumpAndSettle();

      // Tap Confirm & Schedule Pickup
      final submitBtn = find.text('Confirm & Schedule Pickup');
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Confirmation Dialog should appear
      expect(find.text('Pickup Scheduled!'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsWidgets);
      expect(find.text('42 Elm Street, Maple Residency, Apt 3B'), findsWidgets);
      expect(find.text('View in My Pickups'), findsOneWidget);
    });
  });

  group('Schedule Pickup Screen - Responsive Layout Adaptations (LayoutBuilder)', () {
    testWidgets('mobile (<600px) uses single-column layout', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildScheduleApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Summary card is only present on desktop
      expect(find.text('Pickup Summary'), findsNothing);
      expect(find.text('Confirm & Schedule Pickup'), findsOneWidget);
    });

    testWidgets('desktop (>=1000px) uses balanced two-column layout with summary card',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildScheduleApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Desktop includes live Pickup Summary card
      expect(find.text('Pickup Summary'), findsOneWidget);
      expect(find.text('Free Community Pickup'), findsOneWidget);
    });
  });

  group('Schedule Pickup Screen - Responsive Viewport Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildScheduleApp(initialCategory: 'Plastic'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Schedule Waste Pickup'), findsOneWidget);
      });
    }
  });
}

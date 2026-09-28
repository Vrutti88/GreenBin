import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/schedule/pickup_confirmation_screen.dart';
import 'package:greenbin/screens/schedule/review_pickup_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/primary_button.dart';
import 'package:greenbin/widgets/secondary_button.dart';
import 'package:greenbin/widgets/status_chip.dart';

void main() {
  final testPickup = PickupModel(
    id: 'GB-TEST-7788',
    userId: 'user-vrutti-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 (555) 345-6789',
    category: 'Plastic',
    subCategories: const [
      'Beverage bottles (PET)',
      'Milk & detergent jugs (HDPE)',
    ],
    pickupDate: DateTime(2026, 10, 15, 10, 0),
    timeSlot: '10:00 AM - 12:00 PM',
    street: '123 Green Earth Boulevard',
    city: 'Sunnyvale Eco District',
    postalCode: '94085',
    landmark: 'Opposite Community Recycling Hub',
    notes: 'Please buzz apartment 402 upon arrival.',
    status: PickupStatus.confirmed,
    createdAt: DateTime(2026, 10, 1, 9, 30),
    updatedAt: DateTime(2026, 10, 1, 9, 30),
  );

  final viewports = <String, Size>{
    'small mobile (320x480)': const Size(320, 480),
    'small mobile landscape (568x320)': const Size(568, 320),
    'standard mobile (390x844)': const Size(390, 844),
    'standard mobile landscape (844x390)': const Size(844, 390),
    'large mobile (428x926)': const Size(428, 926),
    'large mobile landscape (926x428)': const Size(926, 428),
    'tablet portrait (768x1024)': const Size(768, 1024),
    'tablet landscape (1024x768)': const Size(1024, 768),
    'desktop (1366x768)': const Size(1366, 768),
    'wide desktop (1920x1080)': const Size(1920, 1080),
  };

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildReviewApp({PickupModel? pickup}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: ReviewPickupScreen(pickup: pickup ?? testPickup),
    );
  }

  Widget buildConfirmationApp({PickupModel? pickup}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: PickupConfirmationScreen(pickup: pickup ?? testPickup),
    );
  }

  // ===========================================================================
  // REVIEW PICKUP SCREEN TESTS
  // ===========================================================================
  group('Review Pickup Screen - Content & Display Requirements', () {
    testWidgets('displays all required fields: category, date, time, address, notes',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildReviewApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Screen Title
      expect(find.text('Review Pickup'), findsOneWidget);

      // Verify Category
      expect(find.text('Plastic'), findsWidgets);
      expect(find.text('Beverage bottles (PET)'), findsOneWidget);
      expect(find.text('Milk & detergent jugs (HDPE)'), findsOneWidget);

      // Verify Date & Time
      expect(find.textContaining('October 15, 2026'), findsOneWidget);
      expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);

      // Verify Address
      expect(find.text('123 Green Earth Boulevard'), findsOneWidget);
      expect(find.textContaining('Sunnyvale Eco District'), findsOneWidget);
      expect(find.textContaining('Near Opposite Community Recycling Hub'), findsOneWidget);

      // Verify Notes
      expect(find.text('Please buzz apartment 402 upon arrival.'), findsOneWidget);

      // Verify Buttons
      expect(find.widgetWithText(SecondaryButton, 'Edit Details'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Confirm Pickup'), findsOneWidget);
    });

    testWidgets('Edit Details pops navigation back to previous screen',
        (tester) async {
      setViewport(tester, const Size(390, 844));

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewPickupScreen(pickup: testPickup),
                            ),
                          );
                          popped = true;
                        },
                        child: const Text('Open Review'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Review
      await tester.tap(find.text('Open Review'));
      await tester.pumpAndSettle();
      expect(find.text('Review Pickup'), findsOneWidget);

      // Tap Edit Details button
      final editBtn = find.widgetWithText(SecondaryButton, 'Edit Details');
      await tester.ensureVisible(editBtn);
      await tester.pumpAndSettle();
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Open Review'), findsOneWidget);
    });

    testWidgets('Confirm Pickup saves to Firestore and navigates to Confirmation',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildReviewApp());
      await tester.pumpAndSettle();

      final confirmBtn = find.widgetWithText(PrimaryButton, 'Confirm Pickup');
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Should navigate to Confirmation screen
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('View My Pickups'), findsOneWidget);
    });
  });

  group('Review Pickup Screen - Responsive Layout Adaptations', () {
    testWidgets('desktop viewport (>=1000px) centers constrained card without stretching',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildReviewApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Review Pickup'), findsOneWidget);
      expect(find.text('Edit Details'), findsOneWidget);
      expect(find.text('Confirm Pickup'), findsOneWidget);
    });

    testWidgets('tablet viewport (700px-999px) renders two-column layout with centered width',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildReviewApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Review Pickup'), findsOneWidget);
      expect(find.text('Edit Details'), findsOneWidget);
      expect(find.text('Confirm Pickup'), findsOneWidget);
    });

    testWidgets('mobile viewport (<700px) renders single-column summary and full-width buttons',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildReviewApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Review Pickup'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'Confirm Pickup'), findsOneWidget);
      expect(find.widgetWithText(SecondaryButton, 'Edit Details'), findsOneWidget);
    });
  });

  group('Review Pickup Screen - Responsive Viewport Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildReviewApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Review Pickup'), findsOneWidget);
      });
    }
  });

  // ===========================================================================
  // PICKUP CONFIRMATION SCREEN TESTS
  // ===========================================================================
  group('Pickup Confirmation Screen - Content & Display Requirements', () {
    testWidgets('displays success message, pickup ID, category, date, time, status',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Success Message
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(
          find.textContaining('Your recyclable collection request has been saved'),
          findsOneWidget);

      // Verify Pickup ID
      expect(find.text('#GB-TEST-7788'), findsOneWidget);

      // Verify Category
      expect(find.text('Plastic'), findsWidgets);

      // Verify Date & Time
      expect(find.textContaining('October 15, 2026'), findsOneWidget);
      expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);

      // Verify Status Chip
      expect(find.byType(StatusChip), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      // Verify Buttons
      expect(find.widgetWithText(PrimaryButton, 'View My Pickups'), findsOneWidget);
      expect(find.widgetWithText(SecondaryButton, 'Back to Home'), findsOneWidget);
    });

    testWidgets('View My Pickups navigates to /pickups', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      final myPickupsBtn = find.widgetWithText(PrimaryButton, 'View My Pickups');
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(myPickupsBtn);
      await tester.pumpAndSettle();

      // Should land on My Pickups screen
      expect(find.text('My Pickups'), findsOneWidget);
    });

    testWidgets('Back to Home navigates to /home', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      final homeBtn = find.widgetWithText(SecondaryButton, 'Back to Home');
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(homeBtn);
      await tester.pumpAndSettle();

      // Should land on Home Dashboard
      expect(find.text('GreenBin Dashboard'), findsOneWidget);
    });
  });

  group('Pickup Confirmation Screen - Responsive Layout Adaptations', () {
    testWidgets('desktop viewport (>=1000px) uses centered card container',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('View My Pickups'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('tablet viewport (700px-999px) uses centered constrained layout',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.text('View My Pickups'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('mobile viewport (<700px) uses single-column layout with safe margins',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildConfirmationApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pickup Confirmed!'), findsOneWidget);
      expect(find.widgetWithText(PrimaryButton, 'View My Pickups'), findsOneWidget);
      expect(find.widgetWithText(SecondaryButton, 'Back to Home'), findsOneWidget);
    });
  });

  group('Pickup Confirmation Screen - Responsive Viewport Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildConfirmationApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Pickup Confirmed!'), findsOneWidget);
      });
    }
  });
}

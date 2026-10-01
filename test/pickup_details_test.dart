import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/pickups/pickup_details_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/status_chip.dart';

void main() {
  final sampleScheduledPickup = PickupModel(
    id: 'GB-TEST-1001',
    userId: 'user-resident-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 555-0123',
    category: 'Plastic',
    subCategories: const [
      'Beverage bottles (PET)',
      'Milk & detergent jugs (HDPE)',
    ],
    pickupDate: DateTime(2026, 10, 10, 9, 0),
    timeSlot: '8:00 AM - 10:00 AM',
    street: '100 Green View Road',
    city: 'Springfield Eco Ward',
    landmark: 'Near Solar Park Gate',
    postalCode: '97477',
    notes: 'Please ring bell upon arrival.',
    status: PickupStatus.scheduled,
    createdAt: DateTime(2026, 10, 1, 8, 0),
    updatedAt: DateTime(2026, 10, 1, 8, 0),
  );

  final sampleCollectedPickup = PickupModel(
    id: 'GB-TEST-1002',
    userId: 'user-resident-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 555-0123',
    category: 'Paper & Cardboard',
    subCategories: const ['Flattened cardboard boxes', 'Newspapers'],
    pickupDate: DateTime(2026, 9, 25, 14, 0),
    timeSlot: '2:00 PM - 4:00 PM',
    street: '200 Sustainability Ave',
    city: 'Springfield Eco Ward',
    landmark: 'Apartment 4B',
    postalCode: '97477',
    notes: '',
    status: PickupStatus.collected,
    assignedTeam: 'North Eco Crew #4',
    createdAt: DateTime(2026, 9, 20, 10, 0),
    updatedAt: DateTime(2026, 9, 25, 15, 30),
  );

  final sampleCancelledPickup = PickupModel(
    id: 'GB-TEST-1003',
    userId: 'user-resident-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 555-0123',
    category: 'Glass',
    subCategories: const ['Glass bottles', 'Jars'],
    pickupDate: DateTime(2026, 9, 30, 11, 0),
    timeSlot: '10:00 AM - 12:00 PM',
    street: '300 Maple Street',
    city: 'Springfield Eco Ward',
    landmark: '',
    postalCode: '97477',
    notes: 'Cancelled due to travel.',
    status: PickupStatus.cancelled,
    createdAt: DateTime(2026, 9, 28, 9, 0),
    updatedAt: DateTime(2026, 9, 29, 10, 0),
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

  Widget buildDetailsApp({
    PickupModel? initialPickup,
    String? pickupId,
    Stream<PickupModel?>? pickupStream,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: PickupDetailsScreen(
        initialPickup: initialPickup ?? sampleScheduledPickup,
        pickupId: pickupId ?? (initialPickup?.id ?? sampleScheduledPickup.id),
        pickupStream: pickupStream,
      ),
    );
  }

  // ===========================================================================
  // CONTENT & FIELD REQUIREMENTS
  // ===========================================================================
  group('Pickup Details Screen - Required Displays', () {
    testWidgets('displays all required fields: category, date, time, address, notes, status, created date, timeline',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // 1. Waste Category
      expect(find.text('Waste Category'), findsOneWidget);
      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('Beverage bottles (PET)'), findsOneWidget);
      expect(find.text('Milk & detergent jugs (HDPE)'), findsOneWidget);

      // 2. Pickup Date
      expect(find.text('Schedule & Window'), findsOneWidget);
      expect(find.text('Pickup Date'), findsOneWidget);
      expect(find.text('Saturday, October 10, 2026'), findsOneWidget);

      // 3. Time Slot
      expect(find.text('Time Slot'), findsOneWidget);
      expect(find.text('8:00 AM - 10:00 AM'), findsOneWidget);

      // 4. Address
      expect(find.text('Collection Address'), findsOneWidget);
      expect(find.text('100 Green View Road'), findsOneWidget);
      expect(find.text('Near Near Solar Park Gate'), findsOneWidget);
      expect(find.text('Springfield Eco Ward, 97477'), findsOneWidget);

      // 5. Notes
      expect(find.text('Notes for Collection Crew'), findsOneWidget);
      expect(find.text('Please ring bell upon arrival.'), findsOneWidget);

      // 6. Current Status (From StatusChip)
      expect(find.byType(StatusChip), findsOneWidget);
      expect(find.text('Scheduled'), findsWidgets);

      // 7. Created Date
      expect(find.text('Created on: '), findsOneWidget);
      expect(find.text('Oct 1, 2026 • 8:00 AM'), findsOneWidget);

      // 8. Status Timeline
      expect(find.text('Collection Status Timeline'), findsOneWidget);
      expect(find.text('Request Created'), findsOneWidget);
      expect(find.text('Pickup Scheduled'), findsOneWidget);
      expect(find.text('Crew En Route'), findsOneWidget);
      expect(find.text('Waste Collected'), findsOneWidget);
    });

    testWidgets('displays fallback text when resident notes are blank', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleCollectedPickup));
      await tester.pumpAndSettle();

      expect(find.text('No special instructions provided by resident.'), findsOneWidget);
      expect(find.text('Assigned: North Eco Crew #4'), findsOneWidget);
    });
  });

  // ===========================================================================
  // FIRESTORE LIVE REACTIVITY (STATUS MUST COME FROM FIRESTORE)
  // ===========================================================================
  group('Pickup Details Screen - Firestore Status Reactivity', () {
    testWidgets('status updates dynamically when Firestore stream emits status change from scheduled to collected',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      final streamController = StreamController<PickupModel?>();

      // Initially scheduled
      await tester.pumpWidget(
        buildDetailsApp(
          initialPickup: sampleScheduledPickup,
          pickupStream: streamController.stream,
        ),
      );
      streamController.add(sampleScheduledPickup);
      await tester.pumpAndSettle();

      // Verify initial state: Scheduled
      expect(find.text('Scheduled'), findsWidgets);
      expect(find.text('Cancel Pickup Request'), findsOneWidget);

      // Now Firestore updates status to Collected (e.g. collection crew finishes pickup)
      final updatedPickup = sampleScheduledPickup.copyWith(
        status: PickupStatus.collected,
        assignedTeam: 'GreenBin Metro Truck 02',
      );
      streamController.add(updatedPickup);
      await tester.pumpAndSettle();

      // UI immediately updates: status chip is now Collected
      expect(find.text('Collected'), findsWidgets);
      // Cancel button is removed once collected
      expect(find.text('Cancel Pickup Request'), findsNothing);
      // Assigned team appears in timeline
      expect(find.text('Assigned: GreenBin Metro Truck 02'), findsOneWidget);

      await streamController.close();
    });

    testWidgets('status updates dynamically when Firestore stream emits cancelled status',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      final streamController = StreamController<PickupModel?>();

      await tester.pumpWidget(
        buildDetailsApp(
          initialPickup: sampleScheduledPickup,
          pickupStream: streamController.stream,
        ),
      );
      streamController.add(sampleScheduledPickup);
      await tester.pumpAndSettle();

      expect(find.text('Pickup Scheduled'), findsOneWidget);

      // Stream emits cancelled status
      streamController.add(sampleCancelledPickup);
      await tester.pumpAndSettle();

      // Timeline now shows Request Cancelled
      expect(find.text('Request Cancelled'), findsOneWidget);
      expect(find.text('Cancel Pickup Request'), findsNothing);

      await streamController.close();
    });
  });

  // ===========================================================================
  // CANCEL PICKUP DIALOG
  // ===========================================================================
  group('Pickup Details Screen - Cancel Pickup Action', () {
    testWidgets('opens confirmation dialog on cancel tap and allows dismissing',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      final cancelButton = find.text('Cancel Pickup Request');
      expect(cancelButton, findsOneWidget);

      await tester.ensureVisible(cancelButton);
      await tester.pumpAndSettle();

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Verify dialog is presented
      expect(find.text('Cancel Pickup?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to cancel this recyclable collection request? This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Keep Scheduled'), findsOneWidget);
      expect(find.text('Yes, Cancel'), findsOneWidget);

      // Tap Keep Scheduled to dismiss
      await tester.tap(find.text('Keep Scheduled'));
      await tester.pumpAndSettle();

      // Dialog dismissed, still scheduled
      expect(find.text('Cancel Pickup?'), findsNothing);
      expect(find.text('Scheduled'), findsWidgets);
    });
  });

  group('Pickup Details Screen - Live Lifecycle Simulator Buttons', () {
    testWidgets('tapping Dispatch Crew transitions status to In Transit with SnackBar',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      final dispatchButton = find.text('Dispatch Crew');
      expect(dispatchButton, findsOneWidget);

      await tester.ensureVisible(dispatchButton);
      await tester.tap(dispatchButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // SnackBar is displayed
      expect(find.text('Eco Crew #4 dispatched and en route to your address!'), findsOneWidget);

      await tester.pumpAndSettle();

      // UI updates to In Transit
      expect(find.text('In Transit'), findsWidgets);
      expect(find.text('Collection Crew is En Route'), findsOneWidget);
    });

    testWidgets('tapping Complete Collection transitions status to Collected with SnackBar',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      final completeButton = find.text('Complete Collection');
      expect(completeButton, findsOneWidget);

      await tester.ensureVisible(completeButton);
      await tester.tap(completeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // SnackBar is displayed
      expect(find.textContaining('Collection completed! 4.5 kg diverted'), findsOneWidget);

      await tester.pumpAndSettle();

      // UI updates to Collected
      expect(find.text('Collected'), findsWidgets);
      expect(find.text('Collection completed · Materials weighed & diverted from landfill.'), findsOneWidget);
    });
  });

  // ===========================================================================
  // RESPONSIVE ADAPTATION: MOBILE, TABLET, DESKTOP & LANDSCAPE
  // ===========================================================================
  group('Pickup Details Screen - Responsive Layout Adaptation', () {
    testWidgets('MOBILE (<700px): renders single column and vertical status timeline',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Single column: Category Card, Schedule Card, Address Card, Notes Card, Timeline Card are stacked vertically
      final categoryPos = tester.getTopLeft(find.text('Waste Category')).dy;
      final schedulePos = tester.getTopLeft(find.text('Schedule & Window')).dy;
      final addressPos = tester.getTopLeft(find.text('Collection Address')).dy;
      final timelinePos = tester.getTopLeft(find.text('Collection Status Timeline')).dy;

      expect(categoryPos < schedulePos, isTrue);
      expect(schedulePos < addressPos, isTrue);
      expect(addressPos < timelinePos, isTrue);
    });

    testWidgets('TABLET (700-999px): renders centered constrained two-column layout',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // In tablet two-column layout:
      // Category is in Column 1 (left) and Status Timeline is in Column 2 (right)
      final categoryLeft = tester.getTopLeft(find.text('Waste Category')).dx;
      final timelineLeft = tester.getTopLeft(find.text('Collection Status Timeline')).dx;

      expect(categoryLeft < timelineLeft, isTrue);
    });

    testWidgets('DESKTOP (>=1000px): renders centered maximum-width two-column layout',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Desktop layout uses two columns with maximum content container width
      final categoryLeft = tester.getTopLeft(find.text('Waste Category')).dx;
      final timelineLeft = tester.getTopLeft(find.text('Collection Status Timeline')).dx;

      expect(categoryLeft < timelineLeft, isTrue);
      // Timeline remains completely visible and readable
      expect(find.text('Collection Status Timeline'), findsOneWidget);
      expect(find.text('Request Created'), findsOneWidget);
      expect(find.text('Pickup Scheduled'), findsOneWidget);
    });

    testWidgets('LANDSCAPE: prevents vertical clipping and scrolls cleanly',
        (tester) async {
      setViewport(tester, const Size(844, 390));
      await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Scroll through content smoothly
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // 10-VIEWPORT RESPONSIVE MATRIX TESTING (ZERO OVERFLOW)
  // ===========================================================================
  group('Pickup Details Screen - 10-Viewport Responsive Matrix', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly with zero overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildDetailsApp(initialPickup: sampleScheduledPickup));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Layout overflowed or failed on ${entry.key}',
        );

        // Core elements must be rendered
        expect(find.text('Pickup Details'), findsOneWidget);
        expect(find.text('Plastic'), findsOneWidget);
        expect(find.text('Collection Status Timeline'), findsOneWidget);
      });
    }
  });

  // ===========================================================================
  // ROUTE NAVIGATION WITH ARGUMENTS
  // ===========================================================================
  group('Pickup Details Screen - Route Navigation', () {
    testWidgets('receives PickupModel through named route arguments', (tester) async {
      setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.pickupDetails,
                    arguments: sampleCollectedPickup,
                  );
                },
                child: const Text('Open Details'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      expect(find.text('Pickup Details'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsOneWidget);
      expect(find.text('Collected'), findsWidgets);
    });
  });
}

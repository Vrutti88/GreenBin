import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/pickups/my_pickups_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/empty_state.dart';
import 'package:greenbin/widgets/loading_state.dart';
import 'package:greenbin/widgets/pickup_card.dart';
import 'package:greenbin/widgets/status_chip.dart';

void main() {
  final sampleScheduledPickup = PickupModel(
    id: 'GB-SCHED-101',
    userId: 'user-resident-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 555-0123',
    category: 'Plastic',
    subCategories: const ['Beverage bottles (PET)', 'Jugs (HDPE)'],
    pickupDate: DateTime(2026, 10, 10, 9, 0),
    timeSlot: '8:00 AM - 10:00 AM',
    street: '100 Green View Road',
    city: 'Springfield Eco Ward',
    postalCode: '97477',
    landmark: 'Near Solar Park Gate',
    notes: 'Please ring bell upon arrival.',
    status: PickupStatus.scheduled,
    createdAt: DateTime(2026, 10, 1, 8, 0),
    updatedAt: DateTime(2026, 10, 1, 8, 0),
  );

  final sampleCollectedPickup = PickupModel(
    id: 'GB-COLL-202',
    userId: 'user-resident-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 555-0123',
    category: 'Paper & Cardboard',
    subCategories: const ['Flattened cardboard boxes', 'Newspapers'],
    pickupDate: DateTime(2026, 9, 25, 14, 0),
    timeSlot: '2:00 PM - 4:00 PM',
    street: '100 Green View Road',
    city: 'Springfield Eco Ward',
    postalCode: '97477',
    notes: 'Sorted in green bins.',
    status: PickupStatus.collected,
    assignedTeam: 'North Eco Crew #4',
    createdAt: DateTime(2026, 9, 20, 10, 0),
    updatedAt: DateTime(2026, 9, 25, 15, 30),
  );

  final sampleOtherUserPickup = PickupModel(
    id: 'GB-OTHER-999',
    userId: 'different-user-999',
    residentName: 'John Doe',
    residentPhone: '+1 555-9999',
    category: 'Glass',
    pickupDate: DateTime(2026, 10, 12, 11, 0),
    timeSlot: '10:00 AM - 12:00 PM',
    street: '999 Other Street',
    city: 'Other City',
    status: PickupStatus.scheduled,
    createdAt: DateTime(2026, 10, 1, 9, 0),
    updatedAt: DateTime(2026, 10, 1, 9, 0),
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

  Widget buildMyPickupsApp({
    Stream<List<PickupModel>>? pickupsStream,
    String? initialUserId = 'user-resident-1',
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: MyPickupsScreen(
        initialUserId: initialUserId,
        pickupsStream: pickupsStream ??
            Stream.value([sampleScheduledPickup, sampleCollectedPickup]),
      ),
    );
  }

  // ===========================================================================
  // CONTENT & METADATA TESTS
  // ===========================================================================
  group('My Pickups Screen - Content & Element Requirements', () {
    testWidgets('renders all required pickup fields: category, date, time, status',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Screen Title
      expect(find.text('My Pickups'), findsOneWidget);

      // Verify Filter Chips: All, Scheduled, Collected, Cancelled
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Scheduled'), findsWidgets);
      expect(find.text('Collected'), findsWidgets);
      expect(find.text('Cancelled'), findsOneWidget);

      // Verify PickupCards rendered
      expect(find.byType(PickupCard), findsNWidgets(2));

      // 1. Waste Category displayed
      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsOneWidget);

      // 2. Scheduled Date displayed
      expect(find.textContaining('Oct 10, 2026'), findsOneWidget);
      expect(find.textContaining('Sep 25, 2026'), findsOneWidget);

      // 3. Time Slot displayed
      expect(find.text('8:00 AM - 10:00 AM'), findsOneWidget);
      expect(find.text('2:00 PM - 4:00 PM'), findsOneWidget);

      // 4. Statuses: Scheduled and Collected
      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(find.text('Scheduled'), findsWidgets);
      expect(find.text('Collected'), findsWidgets);
    });

    testWidgets('filtering by Scheduled displays only scheduled pickups',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      // Tap 'Scheduled' filter chip
      final scheduledChip = find.widgetWithText(ChoiceChip, 'Scheduled');
      expect(scheduledChip, findsOneWidget);
      await tester.tap(scheduledChip);
      await tester.pumpAndSettle();

      // Only Plastic (scheduled) should be visible, Paper (collected) should be filtered out
      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsNothing);
    });

    testWidgets('filtering by Collected displays only collected pickups',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      // Tap 'Collected' filter chip
      final collectedChip = find.widgetWithText(ChoiceChip, 'Collected');
      expect(collectedChip, findsOneWidget);
      await tester.tap(collectedChip);
      await tester.pumpAndSettle();

      // Only Paper (collected) should be visible, Plastic (scheduled) should be filtered out
      expect(find.text('Paper & Cardboard'), findsOneWidget);
      expect(find.text('Plastic'), findsNothing);
    });

    testWidgets('tapping a pickup card opens Pickup Details', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      // Tap first pickup card (Plastic)
      final firstCard = find.byType(PickupCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Pickup Details dialog/sheet appears
      expect(find.text('Pickup Details'), findsOneWidget);
      expect(find.textContaining('GB-SCHED-101'), findsOneWidget);
      expect(find.text('Collection Address'), findsOneWidget);
      expect(find.textContaining('100 Green View Road'), findsWidgets);
      expect(find.text('Close'), findsOneWidget);
    });
  });

  // ===========================================================================
  // STATE HANDLING (LOADING, EMPTY, ERROR, AUTHENTICATION)
  // ===========================================================================
  group('My Pickups Screen - State Handling', () {
    testWidgets('displays LoadingState when stream is waiting', (tester) async {
      setViewport(tester, const Size(768, 1024));
      final controller = StreamController<List<PickupModel>>();

      await tester.pumpWidget(
        buildMyPickupsApp(pickupsStream: controller.stream),
      );
      await tester.pump();

      // LoadingState should be displayed
      expect(find.byType(LoadingState), findsOneWidget);
      expect(find.textContaining('Loading your pickups'), findsOneWidget);

      await controller.close();
    });

    testWidgets('displays EmptyState when user has no pickups', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(
        buildMyPickupsApp(pickupsStream: Stream.value([])),
      );
      await tester.pumpAndSettle();

      // EmptyState should be displayed
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No pickups scheduled'), findsOneWidget);
      expect(find.text('Schedule a Pickup'), findsOneWidget);
    });

    testWidgets('displays error state when stream throws an error', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(
        buildMyPickupsApp(
          pickupsStream: Stream.error(Exception('Firestore network disconnected')),
        ),
      );
      await tester.pumpAndSettle();

      // Error UI should be displayed
      expect(find.text('Unable to Load Pickups'), findsOneWidget);
      expect(find.textContaining('Firestore network disconnected'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('displays authentication state when user is unauthenticated',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MyPickupsScreen(
            initialUserId: '',
            pickupsStream: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Unauthenticated state should be displayed
      expect(find.text('Sign In to View Pickups'), findsOneWidget);
      expect(find.text('Log In to GreenBin'), findsOneWidget);
    });

    testWidgets('only displays pickups belonging to the authenticated user',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      // Stream filtered to only user's pickups (user-resident-1)
      final userPickups = [sampleScheduledPickup, sampleCollectedPickup, sampleOtherUserPickup]
          .where((p) => p.userId == 'user-resident-1')
          .toList();

      await tester.pumpWidget(
        buildMyPickupsApp(
          initialUserId: 'user-resident-1',
          pickupsStream: Stream.value(userPickups),
        ),
      );
      await tester.pumpAndSettle();

      // Only the 2 pickups for user-resident-1 appear
      expect(find.byType(PickupCard), findsNWidgets(2));
      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsOneWidget);
      // Other user's Glass pickup does NOT appear
      expect(find.text('Glass'), findsNothing);
    });
  });

  // ===========================================================================
  // RESPONSIVE LAYOUT VERIFICATION (LayoutBuilder)
  // ===========================================================================
  group('My Pickups Screen - Responsive Layout Adaptations (LayoutBuilder)', () {
    testWidgets('mobile (<600px) uses single-column ListView', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Mobile uses ListView.separated
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(PickupCard), findsNWidgets(2));
    });

    testWidgets('tablet (600px - 899px) uses 2-column GridView', (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Tablet uses GridView
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);
      final gridWidget = tester.widget<GridView>(gridFinder);
      final delegate =
          gridWidget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('desktop (900px - 1199px) uses 3-column GridView', (tester) async {
      setViewport(tester, const Size(1024, 768));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);
      final gridWidget = tester.widget<GridView>(gridFinder);
      final delegate =
          gridWidget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));
    });

    testWidgets('wide desktop (>=1200px) uses 4-column GridView without excessive width',
        (tester) async {
      setViewport(tester, const Size(1400, 900));
      await tester.pumpWidget(buildMyPickupsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);
      final gridWidget = tester.widget<GridView>(gridFinder);
      final delegate =
          gridWidget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(4));
    });
  });

  // ===========================================================================
  // RESPONSIVE VIEWPORT MATRIX (ZERO OVERFLOW ACROSS ALL 10 VIEWPORTS)
  // ===========================================================================
  group('My Pickups Screen - Responsive Viewport Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildMyPickupsApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('My Pickups'), findsOneWidget);
        expect(find.byType(PickupCard), findsWidgets);
      });
    }
  });
}

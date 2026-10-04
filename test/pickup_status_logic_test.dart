import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/pickups/my_pickups_screen.dart';
import 'package:greenbin/screens/pickups/pickup_details_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/widgets/status_chip.dart';

void main() {
  group('GreenBin Final Status Architecture Tests', () {
    // A pickup whose scheduled date and time slot have already passed in time
    final pastScheduledPickup = PickupModel(
      id: 'GB-TEST-PAST-001',
      userId: 'test-resident-1',
      residentName: 'Test Resident',
      residentPhone: '+1 555-0123',
      wasteCategory: 'Plastic',
      pickupDate: DateTime.now().subtract(const Duration(days: 3)),
      timeSlot: '8:00 AM - 10:00 AM', // Clearly in the past
      address: '100 Green View Road',
      status: PickupStatus.scheduled, // Stored as Scheduled in Firestore
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    );

    testWidgets(
        '1. Scheduled pickup remains Scheduled in My Pickups even after time slot has passed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MyPickupsScreen(
            initialUserId: 'test-resident-1',
            pickupsStream: Stream.value([pastScheduledPickup]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card must show category
      expect(find.text('Plastic'), findsOneWidget);

      // Must display exact Firestore status "Scheduled" (NOT automatically mutated to Collected)
      expect(find.widgetWithText(StatusChip, 'Scheduled'), findsOneWidget);
      expect(find.widgetWithText(StatusChip, 'Collected'), findsNothing);
    });

    testWidgets(
        '2. Opening Pickup Details after slot has passed does NOT mutate status to Collected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: PickupDetailsScreen(
            initialPickup: pastScheduledPickup,
            pickupStream: Stream.value(pastScheduledPickup),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Details view must preserve authoritative status "Scheduled"
      expect(find.widgetWithText(StatusChip, 'Scheduled'), findsOneWidget);
      expect(find.widgetWithText(StatusChip, 'Collected'), findsNothing);
      expect(find.text('Collection Crew En Route'), findsNothing);
    });

    testWidgets(
        '3. Authoritative Collected status from Firestore is displayed accurately',
        (tester) async {
      final collectedPickup = pastScheduledPickup.copyWith(
        status: PickupStatus.collected,
        assignedTeam: 'North Eco Crew #4',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MyPickupsScreen(
            initialUserId: 'test-resident-1',
            pickupsStream: Stream.value([collectedPickup]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(StatusChip, 'Collected'), findsOneWidget);
      expect(find.widgetWithText(StatusChip, 'Scheduled'), findsNothing);
    });
  });
}

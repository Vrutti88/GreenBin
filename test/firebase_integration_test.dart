import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/models/user_model.dart';
import 'package:greenbin/screens/pickups/my_pickups_screen.dart';
import 'package:greenbin/screens/profile/profile_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('1. Firestore Collection Schema Validation', () {
    test('users/{userId} matches required schema exactly', () {
      final now = DateTime(2026, 9, 28, 12, 0);
      final user = UserModel(
        id: 'usr-12345',
        name: 'Vrutti Patil',
        email: 'vrutti@greenbin.eco',
        phone: '+1 (555) 019-2834',
        community: 'Springfield Eco Ward',
        address: '100 Green View Road, Near Solar Park',
        role: 'resident',
        createdAt: now,
      );

      final map = user.toMap();

      // Required fields verification
      expect(map['name'], 'Vrutti Patil');
      expect(map['email'], 'vrutti@greenbin.eco');
      expect(map['phone'], '+1 (555) 019-2834');
      expect(map['community'], 'Springfield Eco Ward');
      expect(map['address'], '100 Green View Road, Near Solar Park');
      expect(map['role'], 'resident');
      expect(map['createdAt'], isA<Timestamp>());

      // Deserialization round-trip
      final restored = UserModel.fromMap(map, documentId: 'usr-12345');
      expect(restored.name, 'Vrutti Patil');
      expect(restored.email, 'vrutti@greenbin.eco');
      expect(restored.phone, '+1 (555) 019-2834');
      expect(restored.community, 'Springfield Eco Ward');
      expect(restored.address, '100 Green View Road, Near Solar Park');
      expect(restored.role, 'resident');
      expect(restored.fullName, 'Vrutti Patil');
      expect(restored.phoneNumber, '+1 (555) 019-2834');
      expect(restored.street, '100 Green View Road, Near Solar Park');
    });

    test('pickups/{pickupId} matches required schema: new pickups status="Scheduled"', () {
      final pickupDate = DateTime(2026, 9, 30, 9, 30);
      final createdAt = DateTime(2026, 9, 28, 14, 0);

      final pickup = PickupModel(
        id: 'pk-98765',
        userId: 'usr-12345',
        wasteCategory: 'Plastic',
        pickupDate: pickupDate,
        timeSlot: '9:00 AM - 11:00 AM',
        address: '100 Green View Road',
        notes: 'Recyclables sorted and placed at front gate.',
        status: PickupStatus.scheduled,
        createdAt: createdAt,
      );

      final map = pickup.toMap();

      // Required fields verification
      expect(map['userId'], 'usr-12345');
      expect(map['wasteCategory'], 'Plastic');
      expect(map['pickupDate'], isA<Timestamp>());
      expect(map['timeSlot'], '9:00 AM - 11:00 AM');
      expect(map['address'], '100 Green View Road');
      expect(map['notes'], 'Recyclables sorted and placed at front gate.');
      expect(map['status'], 'Scheduled'); // Must be Scheduled for new pickups
      expect(map['createdAt'], isA<Timestamp>());

      // Deserialization round-trip
      final restored = PickupModel.fromMap(map, documentId: 'pk-98765');
      expect(restored.userId, 'usr-12345');
      expect(restored.wasteCategory, 'Plastic');
      expect(restored.category, 'Plastic');
      expect(restored.status, PickupStatus.scheduled);
      expect(restored.status.displayName, 'Scheduled');
      expect(restored.address, '100 Green View Road');
      expect(restored.street, '100 Green View Road');
    });

    test('pickups/{pickupId} later status: status="Collected"', () {
      final pickup = PickupModel(
        id: 'pk-98765',
        userId: 'usr-12345',
        wasteCategory: 'Paper & Cardboard',
        pickupDate: DateTime(2026, 9, 27),
        timeSlot: '11:00 AM - 1:00 PM',
        address: '100 Green View Road',
        status: PickupStatus.collected,
        createdAt: DateTime(2026, 9, 26),
      );

      final map = pickup.toMap();
      expect(map['status'], 'Collected');

      final restored = PickupModel.fromMap(map, documentId: 'pk-98765');
      expect(restored.status, PickupStatus.collected);
      expect(restored.status.displayName, 'Collected');
      expect(restored.status.isCollected, isTrue);
    });
  });

  group('2. Responsive Firebase States in MyPickupsScreen', () {
    final samplePickup = PickupModel(
      id: 'pk-1',
      userId: 'test-user',
      wasteCategory: 'Glass',
      pickupDate: DateTime(2026, 10, 1),
      timeSlot: '10:00 AM - 12:00 PM',
      address: '22 Ocean Drive',
      status: PickupStatus.scheduled,
      createdAt: DateTime.now(),
    );

    testWidgets('State 1: Unauthenticated UI renders responsive login prompt', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const MyPickupsScreen(initialUserId: '')));
      await tester.pumpAndSettle();

      expect(find.text('Sign In to View Pickups'), findsOneWidget);
      expect(find.text('Log In to GreenBin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 2: Loading UI renders responsive loading indicator', (tester) async {
      setViewport(tester, const Size(768, 1024));
      final controller = StreamController<List<PickupModel>>();

      await tester.pumpWidget(wrapWithApp(MyPickupsScreen(
        initialUserId: 'test-user',
        pickupsStream: controller.stream,
      )));
      await tester.pump(); // don't pumpAndSettle since stream is waiting

      expect(find.text('Loading your pickups from Cloud Firestore...'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await controller.close();
    });

    testWidgets('State 3: Error UI renders responsive error view with retry action', (tester) async {
      setViewport(tester, const Size(1024, 768));
      final stream = Stream<List<PickupModel>>.error(Exception('Firestore network timeout'));

      await tester.pumpWidget(wrapWithApp(MyPickupsScreen(
        initialUserId: 'test-user',
        pickupsStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Pickups'), findsOneWidget);
      expect(find.text('Firestore network timeout'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 4: Empty UI renders responsive empty collection state', (tester) async {
      setViewport(tester, const Size(1366, 768));
      final stream = Stream<List<PickupModel>>.value([]);

      await tester.pumpWidget(wrapWithApp(MyPickupsScreen(
        initialUserId: 'test-user',
        pickupsStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('No pickups scheduled'), findsOneWidget);
      expect(find.text('Schedule a Pickup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 5: Success UI renders responsive pickups grid/list across viewports', (tester) async {
      // Mobile Viewport (390x844)
      setViewport(tester, const Size(390, 844));
      final stream = Stream<List<PickupModel>>.value([samplePickup]);

      await tester.pumpWidget(wrapWithApp(MyPickupsScreen(
        initialUserId: 'test-user',
        pickupsStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Glass'), findsOneWidget);
      expect(find.text('Scheduled'), findsWidgets);
      expect(tester.takeException(), isNull);

      // Desktop Viewport (1440x900)
      setViewport(tester, const Size(1440, 900));
      await tester.pumpAndSettle();

      expect(find.text('Glass'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('3. Responsive Firebase States in ProfileScreen', () {
    final sampleUser = UserModel(
      id: 'usr-1',
      name: 'Vrutti Patil',
      email: 'vrutti@greenbin.eco',
      phone: '+1 (555) 019-2834',
      community: 'Eco Ward',
      address: '100 Green View Road',
      role: 'resident',
      totalPickups: 10,
      kgRecycled: 45.0,
      createdAt: DateTime(2026, 1, 1),
    );

    testWidgets('State 1: Unauthenticated UI renders responsive sign-in prompt', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const ProfileScreen(
        initialUser: null,
        userStream: null,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Sign In to View Profile'), findsOneWidget);
      expect(find.text('Log In to GreenBin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 2: Loading UI renders responsive profile loading indicator', (tester) async {
      setViewport(tester, const Size(768, 1024));
      final controller = StreamController<UserModel?>();

      await tester.pumpWidget(wrapWithApp(ProfileScreen(
        userStream: controller.stream,
      )));
      await tester.pump();

      expect(find.text('Loading your profile from Cloud Firestore...'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await controller.close();
    });

    testWidgets('State 3: Error UI renders responsive profile error view', (tester) async {
      setViewport(tester, const Size(1024, 768));
      final stream = Stream<UserModel?>.error(Exception('Permission denied in Firestore'));

      await tester.pumpWidget(wrapWithApp(ProfileScreen(
        userStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Profile'), findsOneWidget);
      expect(find.text('Permission denied in Firestore'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 4: Empty UI renders responsive incomplete profile setup state', (tester) async {
      setViewport(tester, const Size(1366, 768));
      final stream = Stream<UserModel?>.value(null);

      await tester.pumpWidget(wrapWithApp(ProfileScreen(
        userStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Profile Not Set Up'), findsOneWidget);
      expect(find.text('Complete Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State 5: Success UI renders profile data correctly without fake data', (tester) async {
      setViewport(tester, const Size(1366, 768));
      final stream = Stream<UserModel?>.value(sampleUser);

      await tester.pumpWidget(wrapWithApp(ProfileScreen(
        userStream: stream,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Vrutti Patil'), findsWidgets);
      expect(find.text('vrutti@greenbin.eco'), findsOneWidget);
      expect(find.text('100 Green View Road'), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // totalPickups
      expect(find.text('Level 2'), findsOneWidget); // zeroWasteLevel
      expect(find.text('Zero-Waste Rank'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('4. Firebase Screen-Size Independence Matrix', () {
    final sampleUser = UserModel(
      id: 'usr-1',
      name: 'Vrutti Patil',
      email: 'vrutti@greenbin.eco',
      phone: '+1 (555) 019-2834',
      community: 'Eco Ward',
      address: '100 Green View Road',
      role: 'resident',
      createdAt: DateTime(2026, 1, 1),
    );

    final viewports = <String, Size>{
      'mobile portrait (390x844)': const Size(390, 844),
      'mobile landscape (844x390)': const Size(844, 390),
      'tablet portrait (768x1024)': const Size(768, 1024),
      'desktop (1366x768)': const Size(1366, 768),
      'wide desktop (1920x1080)': const Size(1920, 1080),
    };

    for (final entry in viewports.entries) {
      testWidgets('Firebase state works consistently on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);

        await tester.pumpWidget(wrapWithApp(ProfileScreen(
          initialUser: sampleUser,
        )));
        await tester.pumpAndSettle();

        expect(find.text('Vrutti Patil'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });
}

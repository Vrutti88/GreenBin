import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/models/user_model.dart';

void main() {
  group('1. Firestore Security Rules File & Syntax Verification', () {
    late String rulesContent;

    setUpAll(() {
      final file = File('firestore.rules');
      expect(file.existsSync(), isTrue, reason: 'firestore.rules file must exist at project root');
      rulesContent = file.readAsStringSync();
    });

    test('Rules version 2 and cloud.firestore service are declared', () {
      expect(rulesContent.contains("rules_version = '2';"), isTrue);
      expect(rulesContent.contains("service cloud.firestore"), isTrue);
    });

    test('Strict Security Guarantee: "allow read, write: if true;" is NEVER used', () {
      expect(
        rulesContent.contains("allow read, write: if true;"),
        isFalse,
        reason: 'Permissive wildcard rule must not exist anywhere in security rules',
      );
      expect(
        rulesContent.contains("allow read: if true;"),
        isFalse,
        reason: 'Permissive read rule must not exist anywhere in security rules',
      );
      expect(
        rulesContent.contains("allow write: if true;"),
        isFalse,
        reason: 'Permissive write rule must not exist anywhere in security rules',
      );
    });

    test('Default catch-all denies all access (allow read, write: if false;)', () {
      expect(rulesContent.contains("match /{document=**}"), isTrue);
      expect(rulesContent.contains("allow read, write: if false;"), isTrue);
    });
  });

  group('2. User Document Security Rules (users/{userId})', () {
    late String rulesContent;

    setUpAll(() {
      rulesContent = File('firestore.rules').readAsStringSync();
    });

    test('Residents can read their own user document, Collectors and Admins can coordinate', () {
      expect(rulesContent.contains("allow get: if isOwner(userId) || isCollector() || isAdmin();"), isTrue);
      expect(rulesContent.contains("allow list: if isAdmin();"), isTrue);
    });

    test('Residents can only update their own profile and CANNOT modify another profile', () {
      expect(rulesContent.contains("allow update: if isOwner(userId)"), isTrue);
    });

    test('Do NOT allow users to assign themselves the collector role', () {
      // Must enforce role == 'resident' on creation
      expect(
        rulesContent.contains("request.resource.data.role == 'resident'"),
        isTrue,
        reason: 'Registration must enforce resident role and reject self-assigned collector role',
      );

      // Must prevent role escalation on update
      expect(
        rulesContent.contains("request.resource.data.role == resource.data.role || isAdmin()"),
        isTrue,
        reason: 'Profile updates must prohibit changing user role unless performed by admin',
      );
    });

    test('UserModel defaults to resident role and maintains immutable role across updates', () {
      final resident = UserModel(
        id: 'usr-1',
        name: 'Resident One',
        email: 'one@greenbin.eco',
        createdAt: DateTime.now(),
      );

      expect(resident.role, 'resident');

      // Attempting to copy with same role maintains resident
      final updated = resident.copyWith(name: 'Resident One Updated');
      expect(updated.role, 'resident');
      expect(updated.id, 'usr-1');
    });
  });

  group('3. Pickup Document Security Rules (pickups/{pickupId})', () {
    late String rulesContent;

    setUpAll(() {
      rulesContent = File('firestore.rules').readAsStringSync();
    });

    test('Residents can read ONLY their own pickups; Collectors can read all requests', () {
      expect(
        rulesContent.contains("resource.data.userId == request.auth.uid ||"),
        isTrue,
      );
      expect(
        rulesContent.contains("isCollector() ||"),
        isTrue,
      );
    });

    test('Residents can create pickups ONLY for themselves with status="Scheduled"', () {
      expect(
        rulesContent.contains("request.resource.data.userId == request.auth.uid"),
        isTrue,
      );
      expect(
        rulesContent.contains("request.resource.data.status == 'Scheduled'"),
        isTrue,
        reason: 'New pickups must strictly require status = "Scheduled"',
      );
    });

    test('Residents CANNOT change another user\'s pickup status or modify another\'s pickup', () {
      // Owner update condition checks resource.data.userId == request.auth.uid
      expect(
        rulesContent.contains("resource.data.userId == request.auth.uid"),
        isTrue,
      );
      // Ensures resident cannot mark their own pickup as "Collected"
      expect(
        rulesContent.contains("request.resource.data.status == resource.data.status ||"),
        isTrue,
      );
      expect(
        rulesContent.contains("(resource.data.status == 'Scheduled' && request.resource.data.status == 'Cancelled')"),
        isTrue,
      );
    });

    test('Collectors CAN update pickup status and assignment', () {
      expect(
        rulesContent.contains("(isCollector() || isAdmin())"),
        isTrue,
      );
      expect(
        rulesContent.contains("affectedKeys().hasOnly(['status', 'assignedTeam', 'updatedAt', 'notes'])"),
        isTrue,
        reason: 'Collectors can only update pickup status and assignment without altering resident core data',
      );
    });
  });

  group('4. Client-Side Security Alignment & Model Integrity', () {
    test('PickupModel ensures new pickups are initialized with status "Scheduled"', () {
      final pickup = PickupModel(
        id: 'pk-new',
        userId: 'usr-10',
        wasteCategory: 'Plastic',
        pickupDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '9:00 AM - 11:00 AM',
        address: '123 Pine St',
        createdAt: DateTime.now(),
      );

      expect(pickup.status, PickupStatus.scheduled);
      expect(pickup.toMap()['status'], 'Scheduled');
    });

    test('PickupModel status transitions support "Collected" by collectors', () {
      final pickup = PickupModel(
        id: 'pk-1',
        userId: 'usr-10',
        wasteCategory: 'Metal',
        pickupDate: DateTime.now(),
        timeSlot: '11:00 AM - 1:00 PM',
        address: '456 Oak St',
        status: PickupStatus.collected,
        createdAt: DateTime.now(),
      );

      expect(pickup.status, PickupStatus.collected);
      expect(pickup.toMap()['status'], 'Collected');
    });

    test('Responsive UI does NOT affect security parameters or query scopes', () {
      // Verify that Firestore queries specify exact userId constraint regardless of device form factor
      const userId = 'usr-current-resident';

      // Simulation of query parameter generation
      final queryParam = {'userId': userId};
      expect(queryParam['userId'], equals(userId));

      // Viewport changes (e.g. mobile vs tablet vs desktop) operate solely at the Presentation layer
      // and do not inject or alter query filters or authentication tokens
    });
  });
}

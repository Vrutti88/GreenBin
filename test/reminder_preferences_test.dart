import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenbin/models/notification_model.dart';
import 'package:greenbin/services/preferences_service.dart';
import 'package:greenbin/screens/profile/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads standard default values', () async {
      final prefsService = PreferencesService();
      expect(await prefsService.getPickupReminders(), isTrue);
      expect(await prefsService.getStatusUpdates(), isTrue);
      expect(await prefsService.getMilestoneAlerts(), isTrue);
      expect(await prefsService.getSoundAndVibrate(), isTrue);
      expect(await prefsService.getReminderWindow(), equals('1 day before'));
    });

    test('Persists and retrieves preference values in SharedPreferences',
        () async {
      final prefsService = PreferencesService();

      await prefsService.setPickupReminders(false);
      expect(await prefsService.getPickupReminders(), isFalse);

      await prefsService.setReminderWindow('2 hours before');
      expect(await prefsService.getReminderWindow(), equals('2 hours before'));

      await prefsService.setStatusUpdates(false);
      expect(await prefsService.getStatusUpdates(), isFalse);

      await prefsService.setMilestoneAlerts(false);
      expect(await prefsService.getMilestoneAlerts(), isFalse);

      await prefsService.setSoundAndVibrate(false);
      expect(await prefsService.getSoundAndVibrate(), isFalse);
    });

    test('triggerFeedbackIfEnabled executes safely without exception',
        () async {
      final prefsService = PreferencesService();
      await prefsService.setSoundAndVibrate(true);
      expect(() => prefsService.triggerFeedbackIfEnabled(), returnsNormally);

      await prefsService.setSoundAndVibrate(false);
      expect(() => prefsService.triggerFeedbackIfEnabled(), returnsNormally);
    });

    test('getReminderDuration parses all valid window durations', () {
      final prefsService = PreferencesService();
      expect(
          prefsService.getReminderDuration('2 hours before'),
          equals(const Duration(hours: 2)));
      expect(
          prefsService.getReminderDuration('1 day before'),
          equals(const Duration(days: 1)));
      expect(
          prefsService.getReminderDuration('2 days before'),
          equals(const Duration(days: 2)));
      // Default fallback
      expect(
          prefsService.getReminderDuration('unknown option'),
          equals(const Duration(days: 1)));
    });

    test('calculateReminderDateTime calculates correct alert trigger times', () {
      final prefsService = PreferencesService();
      final pickupDate = DateTime(2026, 10, 15);

      // 1 day before '09:00 AM - 11:00 AM' -> 2026-10-14 09:00 AM
      final reminder1 = prefsService.calculateReminderDateTime(
        pickupDate: pickupDate,
        timeSlot: '09:00 AM - 11:00 AM',
        window: '1 day before',
      );
      expect(reminder1, equals(DateTime(2026, 10, 14, 9, 0)));

      // 2 hours before '02:00 PM - 04:00 PM' -> 2026-10-15 12:00 PM (noon)
      final reminder2 = prefsService.calculateReminderDateTime(
        pickupDate: pickupDate,
        timeSlot: '02:00 PM - 04:00 PM',
        window: '2 hours before',
      );
      expect(reminder2, equals(DateTime(2026, 10, 15, 12, 0)));

      // 2 days before '11:30 AM' -> 2026-10-13 11:30 AM
      final reminder3 = prefsService.calculateReminderDateTime(
        pickupDate: pickupDate,
        timeSlot: '11:30 AM',
        window: '2 days before',
      );
      expect(reminder3, equals(DateTime(2026, 10, 13, 11, 30)));
    });

    test('NotificationType enum supports milestone alerts', () {
      expect(NotificationType.milestone.displayName, equals('Milestone Alert'));
      expect(NotificationType.milestone.icon, isNotNull);
      expect(NotificationType.milestone.color, isNotNull);
      expect(NotificationType.fromString('milestone'),
          equals(NotificationType.milestone));
      expect(NotificationType.fromString('milestone_alert'),
          equals(NotificationType.milestone));
    });
  });

  group('Settings Screen - All 5 Preferences Controls Interactive Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        PreferencesService.keyPickupReminders: true,
        PreferencesService.keyStatusUpdates: true,
        PreferencesService.keyMilestoneAlerts: true,
        PreferencesService.keyReminderWindow: '1 day before',
        PreferencesService.keySoundAndVibrate: true,
      });
    });

    testWidgets('1. Reminder Timing dropdown opens, updates value and persists',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reminder Timing'), findsOneWidget);
      expect(find.text('1 day before'), findsNWidgets(2));

      // Tap on the DropdownButton
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Dropdown menu options should be visible
      expect(find.text('2 hours before').last, findsOneWidget);
      expect(find.text('2 days before').last, findsOneWidget);

      // Select '2 hours before'
      await tester.tap(find.text('2 hours before').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify SnackBar feedback appears
      expect(find.text('Reminder timing set to 2 hours before'), findsOneWidget);

      // Verify SharedPreferences updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PreferencesService.keyReminderWindow),
          equals('2 hours before'));
    });

    testWidgets('2. Pickup Reminders toggle updates state and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find switch by tile title
      final pickupTile = find.ancestor(
        of: find.text('Pickup Reminders'),
        matching: find.byType(ListTile),
      );
      final switchFinder = find.descendant(
        of: pickupTile,
        matching: find.byType(Switch),
      );

      // Toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Pickup reminders disabled'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyPickupReminders), isFalse);

      // Toggle back on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Pickup reminders enabled'), findsOneWidget);
      expect(prefs.getBool(PreferencesService.keyPickupReminders), isTrue);
    });

    testWidgets('3. Status Updates toggle updates state and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Status Updates'),
        matching: find.byType(ListTile),
      );
      final switchFinder = find.descendant(
        of: tile,
        matching: find.byType(Switch),
      );

      // Toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Status updates disabled'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyStatusUpdates), isFalse);

      // Toggle on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Status updates enabled'), findsOneWidget);
      expect(prefs.getBool(PreferencesService.keyStatusUpdates), isTrue);
    });

    testWidgets('4. Milestone Alerts toggle updates state and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Milestone Alerts'),
        matching: find.byType(ListTile),
      );
      final switchFinder = find.descendant(
        of: tile,
        matching: find.byType(Switch),
      );

      // Toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Milestone alerts disabled'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyMilestoneAlerts), isFalse);

      // Toggle on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Milestone alerts enabled'), findsOneWidget);
      expect(prefs.getBool(PreferencesService.keyMilestoneAlerts), isTrue);
    });

    testWidgets('5. Sound & Vibration toggle updates state and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Sound & Vibration'),
        matching: find.byType(ListTile),
      );
      final switchFinder = find.descendant(
        of: tile,
        matching: find.byType(Switch),
      );

      // Toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Sound & vibration disabled'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keySoundAndVibrate), isFalse);

      // Toggle on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Sound & vibration enabled'), findsOneWidget);
      expect(prefs.getBool(PreferencesService.keySoundAndVibrate), isTrue);
    });
  });
}

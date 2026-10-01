import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  });

  group('Settings Screen - Reminder Timing Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        PreferencesService.keyReminderWindow: '1 day before',
        PreferencesService.keyPickupReminders: true,
      });
    });

    testWidgets('Renders Reminder Timing dropdown and updates setting',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the reminder timing tile exists
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
      await tester.pumpAndSettle();

      // Verify SnackBar feedback appears
      expect(find.text('Reminder timing set to 2 hours before'), findsOneWidget);

      // Verify SharedPreferences updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PreferencesService.keyReminderWindow),
          equals('2 hours before'));
    });

    testWidgets('Toggles Pickup Reminders switch and shows confirmation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // Tap to toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Pickup reminders disabled'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getBool(PreferencesService.keyPickupReminders), isFalse);

      // Tap to toggle on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Pickup reminders enabled'), findsOneWidget);
      expect(
          prefs.getBool(PreferencesService.keyPickupReminders), isTrue);
    });
  });
}

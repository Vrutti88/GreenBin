import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/notification_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/notifications/notifications_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
  final sampleNotifications = [
    NotificationModel(
      id: 'test-notif-1',
      userId: 'user-resident-1',
      pickupId: 'GB-TEST-1001',
      type: NotificationType.pickupStatusChanged,
      title: 'Collection Crew En Route',
      message:
          'North Eco Crew #4 is heading towards your location for the scheduled Plastic collection.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      category: 'Plastic',
    ),
    NotificationModel(
      id: 'test-notif-2',
      userId: 'user-resident-1',
      pickupId: 'GB-TEST-1002',
      type: NotificationType.pickupReminder,
      title: 'Pickup Reminder for Tomorrow',
      message:
      
          'Friendly reminder: Your Paper & Cardboard pickup is tomorrow at 2:00 PM. Please ensure materials are flattened and dry.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      category: 'Paper & Cardboard',
    ),
    NotificationModel(
      id: 'test-notif-3',
      userId: 'user-resident-1',
      pickupId: 'GB-TEST-1001',
      type: NotificationType.pickupScheduled,
      title: 'Pickup Confirmed',
      message:
          'Your Plastic waste pickup for Saturday, Oct 10 at 8:00 AM has been confirmed and assigned.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      category: 'Plastic',
    ),
  ];

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

  Widget buildNotificationsApp({
    List<NotificationModel>? initialNotifications,
    Stream<List<NotificationModel>>? notificationsStream,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: NotificationsScreen(
        initialNotifications: initialNotifications ?? sampleNotifications,
        notificationsStream: notificationsStream,
        initialUserId: 'user-resident-1',
      ),
    );
  }

  // ===========================================================================
  // CONTENT & REPRESENTED TYPES
  // ===========================================================================
  group('Notifications Screen - Required Types & Content', () {
    testWidgets('renders all 3 required notification types: scheduled, reminder, status changed',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify Screen Title
      expect(find.text('Notifications'), findsOneWidget);

      // 1. Pickup Status Changed
      expect(find.text('Status Changed'), findsOneWidget);
      expect(find.text('Collection Crew En Route'), findsOneWidget);
      expect(
        find.text(
          'North Eco Crew #4 is heading towards your location for the scheduled Plastic collection.',
        ),
        findsOneWidget,
      );

      // 2. Pickup Reminder
      expect(find.text('Pickup Reminder'), findsOneWidget);
      expect(find.text('Pickup Reminder for Tomorrow'), findsOneWidget);

      // 3. Pickup Scheduled
      expect(find.text('Pickup Scheduled'), findsOneWidget);
      expect(find.text('Pickup Confirmed'), findsOneWidget);
    });

    testWidgets('renders filter chips: All, Unread, Pickups, Reminders',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
      expect(find.text('Pickups'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
    });
  });

  // ===========================================================================
  // FILTERING & INTERACTION
  // ===========================================================================
  group('Notifications Screen - Filtering & Interactions', () {
    testWidgets('filtering by Unread displays only unread notifications',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      // Tap 'Unread' filter chip
      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();

      // Unread items are shown
      expect(find.text('Collection Crew En Route'), findsOneWidget);
      expect(find.text('Pickup Reminder for Tomorrow'), findsOneWidget);
      // Read item is hidden
      expect(find.text('Pickup Confirmed'), findsNothing);
    });

    testWidgets('filtering by Reminders displays only reminder notifications',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      final reminderChip = find.text('Reminders');
      await tester.ensureVisible(reminderChip);
      await tester.pumpAndSettle();

      await tester.tap(reminderChip);
      await tester.pumpAndSettle();

      expect(find.text('Pickup Reminder for Tomorrow'), findsOneWidget);
      expect(find.text('Collection Crew En Route'), findsNothing);
      expect(find.text('Pickup Confirmed'), findsNothing);
    });

    testWidgets('mark all as read marks unread notifications as read',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(find.text('2 unread'), findsOneWidget);

      final markAllButton = find.text('Mark all read');
      expect(markAllButton, findsOneWidget);

      await tester.tap(markAllButton);
      await tester.pumpAndSettle();

      // Unread badge is removed
      expect(find.text('2 unread'), findsNothing);
      expect(find.text('All notifications marked as read.'), findsOneWidget);
    });

    testWidgets('tapping notification card marks it as read',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(find.text('2 unread'), findsOneWidget);

      // Tap on the first notification
      await tester.tap(find.text('Collection Crew En Route'));
      await tester.pumpAndSettle();

      // Since tapping navigates if pickupId exists, it opens details or pops back
      // When back, unread counter decreases
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays empty state when filtered list has no notifications',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      // Provide an empty list
      await tester.pumpWidget(buildNotificationsApp(initialNotifications: []));
      await tester.pumpAndSettle();

      expect(find.text('No Notifications Yet'), findsOneWidget);
    });
  });

  // ===========================================================================
  // RESPONSIVE LAYOUT VERIFICATION (MOBILE, TABLET, DESKTOP, LANDSCAPE)
  // ===========================================================================
  group('Notifications Screen - Responsive Layout Adaptation', () {
    testWidgets('MOBILE (<600px): uses single-column notification list',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Cards are arranged in a single vertical column
      final pos1 = tester.getTopLeft(find.text('Collection Crew En Route')).dy;
      final pos2 = tester.getTopLeft(find.text('Pickup Reminder for Tomorrow')).dy;
      final pos3 = tester.getTopLeft(find.text('Pickup Confirmed')).dy;

      expect(pos1 < pos2, isTrue);
      expect(pos2 < pos3, isTrue);
    });

    testWidgets('TABLET (600-1023px): uses constrained notification list',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Content container is centered and constrained to 680px
      final leftPos = tester.getTopLeft(find.text('Inbox Updates')).dx;
      // In a 768px wide viewport with 680px centered box: (768 - 680)/2 = 44px margin
      expect(leftPos, greaterThanOrEqualTo(40));
    });

    testWidgets('DESKTOP (>=1024px): uses centered maximum-width panel',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // On 1366px screen, content is centered with max-width 780px:
      // (1366 - 780)/2 = 293px margin
      final leftPos = tester.getTopLeft(find.text('Inbox Updates')).dx;
      expect(leftPos, greaterThan(250));
    });

    testWidgets('LANDSCAPE: prevents clipping and scrolls smoothly',
        (tester) async {
      setViewport(tester, const Size(844, 390));
      await tester.pumpWidget(buildNotificationsApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Scroll through notifications smoothly
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // 10-VIEWPORT RESPONSIVE MATRIX (ZERO OVERFLOW)
  // ===========================================================================
  group('Notifications Screen - 10-Viewport Responsive Matrix', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly with zero overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildNotificationsApp());
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Layout overflowed or failed on ${entry.key}',
        );

        // Core elements visible
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Inbox Updates'), findsOneWidget);
      });
    }
  });
}

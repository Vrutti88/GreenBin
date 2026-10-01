import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/home/home_screen.dart';
import 'package:greenbin/screens/notifications/notifications_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
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

  Widget buildHomeScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const HomeScreen(),
    );
  }

  group('GreenBin Home Dashboard - Content & Elements Verification', () {
    testWidgets('renders all required dashboard components', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // 1. Top Greeting Header & Profile access
      expect(find.textContaining('👋'), findsOneWidget);
      expect(find.byTooltip('Resident Profile'), findsOneWidget);

      // 2. Notifications action in AppBar
      expect(find.byTooltip('Notifications'), findsOneWidget);

      // 3. Schedule Pickup Hero CTA Banner
      expect(find.text('Schedule Recyclable Pickup'), findsOneWidget);
      expect(find.text('Doorstep Pickup'), findsOneWidget);
      expect(find.text('Schedule Pickup Now'), findsOneWidget);

      // 4. Recycling Statistics (Metrics Grid)
      expect(find.text('Total Pickups'), findsOneWidget);
      expect(find.text('Active Pickups'), findsOneWidget);
      expect(find.text('Zero-Waste Rank'), findsOneWidget);
      expect(find.text('Diverted (kg)'), findsNothing);

      // 5. Upcoming Pickup section
      expect(find.text('Upcoming Pickup'), findsOneWidget);

      // 6. Waste Category shortcuts
      expect(find.text('Recycling Categories'), findsOneWidget);
      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('Paper & Cardboard'), findsOneWidget);
      expect(find.text('Glass'), findsOneWidget);
      expect(find.text('Metal'), findsOneWidget);
      expect(find.text('E-Waste'), findsOneWidget);

      // 7. Recent Pickups section
      expect(find.text('Recent Pickups'), findsOneWidget);
    });

    testWidgets('Schedule Pickup Now CTA button navigates to schedule screen',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      final scheduleBtn = find.text('Schedule Pickup Now');
      expect(scheduleBtn, findsOneWidget);

      await tester.ensureVisible(scheduleBtn);
      await tester.tap(scheduleBtn);
      await tester.pumpAndSettle();

      // Should be on the Schedule Pickup screen
      expect(find.text('Schedule Waste Pickup'), findsOneWidget);
      expect(find.text('1. Select Recyclable Category'), findsOneWidget);
    });

    testWidgets('Tapping a waste category shortcut navigates with pre-selected category',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      final plasticCard = find.text('Plastic');
      expect(plasticCard, findsOneWidget);

      await tester.ensureVisible(plasticCard);
      await tester.tap(plasticCard);
      await tester.pumpAndSettle();

      // Should open Schedule Pickup Screen with Plastic initialized
      expect(find.text('Schedule Waste Pickup'), findsOneWidget);
      expect(find.text('Plastic'), findsWidgets);
    });

    testWidgets('Tapping Notifications button opens notifications screen',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      final notifBtn = find.byTooltip('Notifications');
      expect(notifBtn, findsOneWidget);

      await tester.tap(notifBtn);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsWidgets);
      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('Tapping profile avatar switches to Profile tab', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      final profileBtn = find.byTooltip('Resident Profile');
      expect(profileBtn, findsOneWidget);

      await tester.tap(profileBtn);
      await tester.pumpAndSettle();

      expect(find.text('Sign In to View Profile'), findsOneWidget);
    });

    testWidgets('Tapping View Guide in Categories switches to Guide tab',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      final viewGuideBtn = find.text('View Guide');
      expect(viewGuideBtn, findsOneWidget);

      await tester.ensureVisible(viewGuideBtn);
      await tester.tap(viewGuideBtn);
      await tester.pumpAndSettle();

      expect(find.text('Waste Category Guide'), findsWidgets);
    });
  });

  group('GreenBin Home Dashboard - Responsive Viewport Matrix', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(buildHomeScreen());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Core elements must exist on all screen sizes
        expect(find.textContaining('👋'), findsOneWidget);
        expect(find.text('Schedule Recyclable Pickup'), findsOneWidget);
        expect(find.text('Total Pickups'), findsOneWidget);
        expect(find.text('Recycling Categories'), findsOneWidget);

        // Responsive Navigation verification
        final isDesktop = entry.value.width >= 1024;
        final isLandscape = entry.value.width > entry.value.height;
        final isCompactHeight = entry.value.height < 500;

        if (isDesktop) {
          // Desktop uses persistent Sidebar
          expect(find.text('GreenBin'), findsOneWidget);
          expect(find.text('MENU'), findsOneWidget);
          // Multi-column companion
          expect(find.text('Community Eco Impact'), findsOneWidget);
        } else if (isCompactHeight || isLandscape) {
          // Mobile Landscape or Tablet Landscape uses NavigationRail
          expect(find.byType(NavigationRail), findsOneWidget);
        } else if (entry.value.width < 600) {
          // Mobile portrait uses Bottom NavigationBar
          expect(find.byType(NavigationBar), findsOneWidget);
        } else {
          // Tablet portrait uses NavigationRail
          expect(find.byType(NavigationRail), findsOneWidget);
        }
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/home/home_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
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

  Widget wrapWithApp(Widget widget) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: widget,
    );
  }

  // ===========================================================================
  // 1. MOBILE BOTTOM NAVIGATION SPECIFICATION
  // ===========================================================================
  group('1. Mobile Adaptive Navigation', () {
    testWidgets('renders bottom navigation with exact 5 destinations',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Verify the 5 required bottom navigation items
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Pickups'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('switches views via bottom navigation without duplicating navigation stack',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap Guide
      await tester.tap(find.text('Guide'));
      await tester.pumpAndSettle();
      expect(find.text('Recycling Category Guide'), findsOneWidget);
      expect(find.text('Recycling Categories'), findsNothing);

      // Tap Schedule
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Waste Pickup'), findsWidgets);

      // Tap Pickups
      await tester.tap(find.text('Pickups'));
      await tester.pumpAndSettle();
      expect(find.text('My Pickups'), findsWidgets);

      // Tap Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Resident Profile'), findsWidgets);

      // Tap back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Recyclable Pickup'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 2. TABLET NAVIGATION RAIL SPECIFICATION
  // ===========================================================================
  group('2. Tablet Adaptive Navigation (NavigationRail)', () {
    testWidgets('renders NavigationRail on tablet portrait (768x1024)',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Primary rail destinations
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Pickups'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Trailing actions on rail
      expect(find.byTooltip('Notifications'), findsWidgets);
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.byTooltip('Help & FAQ'), findsOneWidget);
      expect(find.byTooltip('Logout'), findsOneWidget);
    });

    testWidgets('taps rail destinations and trailing actions on tablet',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap Guide rail destination
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Recycling Category Guide'), findsOneWidget);

      // Tap Settings in trailing rail
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Pickup Notifications'), findsOneWidget);

      // Tap Help & FAQ in trailing rail
      await tester.tap(find.byTooltip('Help & FAQ'));
      await tester.pumpAndSettle();
      expect(find.text('Search FAQ questions & topics...'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 3. DESKTOP PERMANENT SIDEBAR SPECIFICATION
  // ===========================================================================
  group('3. Desktop Permanent Sidebar Navigation', () {
    testWidgets('renders permanent sidebar with all 9 required navigation items',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      // No bottom nav or compact rail
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);

      // Branding Header
      expect(find.text('GreenBin'), findsWidgets);
      expect(find.text('Community Recycling'), findsOneWidget);
      expect(find.text('MENU'), findsOneWidget);
      expect(find.text('SETTINGS & SUPPORT'), findsOneWidget);

      // 9 Required Navigation Items
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Waste Guide'), findsOneWidget);
      expect(find.text('Schedule Pickup'), findsWidgets);
      expect(find.text('My Pickups'), findsWidgets);
      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Help & FAQ'), findsWidgets);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('clicking desktop sidebar items switches view in content area',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      // 1. Waste Guide
      await tester.tap(find.text('Waste Guide'));
      await tester.pumpAndSettle();
      expect(find.text('Recycling Category Guide'), findsOneWidget);

      // 2. Schedule Pickup
      await tester.tap(find.text('Schedule Pickup').first);
      await tester.pumpAndSettle();
      expect(find.text('1. Select Recyclable Category'), findsOneWidget);

      // 3. My Pickups
      await tester.tap(find.text('My Pickups'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In to View Pickups'), findsOneWidget);

      // 4. Notifications
      await tester.tap(find.text('Notifications').first);
      await tester.pumpAndSettle();
      expect(find.text('Inbox Updates'), findsOneWidget);

      // 5. Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Pickup Notifications'), findsOneWidget);

      // 6. Help & FAQ
      await tester.tap(find.text('Help & FAQ'));
      await tester.pumpAndSettle();
      expect(find.text('Search FAQ questions & topics...'), findsOneWidget);

      // 7. Profile
      await tester.tap(find.text('Profile').first);
      await tester.pumpAndSettle();
      expect(find.text('Sign In to View Profile'), findsOneWidget);
    });

    testWidgets('clicking Logout opens confirmation dialog', (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(wrapWithApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Log Out of GreenBin'), findsOneWidget);
      expect(
        find.text('Are you sure you want to log out of your resident account?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Log Out of GreenBin'), findsNothing);
    });
  });

  // ===========================================================================
  // 4. 10-VIEWPORT RESPONSIVE MATRIX & OVERFLOW CHECK
  // ===========================================================================
  group('4. Adaptive Navigation - 10-Viewport Zero Overflow Matrix', () {
    for (final entry in viewports.entries) {
      testWidgets('Navigation adapts cleanly without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(const HomeScreen()));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Navigation overflowed on ${entry.key}',
        );

        final isDesktop = entry.value.width >= 1024;
        final isLandscape = entry.value.width > entry.value.height;
        final isCompactHeight = entry.value.height < 500;

        if (isDesktop) {
          expect(find.text('GreenBin'), findsWidgets);
          expect(find.text('MENU'), findsOneWidget);
          expect(find.text('Logout'), findsOneWidget);
        } else if (isCompactHeight || isLandscape) {
          expect(find.byType(NavigationRail), findsOneWidget);
        } else if (entry.value.width < 600) {
          expect(find.byType(NavigationBar), findsOneWidget);
        } else {
          expect(find.byType(NavigationRail), findsOneWidget);
        }
      });
    }
  });
}

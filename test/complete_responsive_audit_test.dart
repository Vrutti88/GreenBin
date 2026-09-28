import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/pickup_model.dart';
import 'package:greenbin/models/user_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/auth/forgot_password_screen.dart';
import 'package:greenbin/screens/auth/login_screen.dart';
import 'package:greenbin/screens/auth/profile_setup_screen.dart';
import 'package:greenbin/screens/auth/register_screen.dart';
import 'package:greenbin/screens/guide/category_details_screen.dart';
import 'package:greenbin/screens/guide/waste_guide_screen.dart';
import 'package:greenbin/screens/home/home_screen.dart';
import 'package:greenbin/screens/notifications/notifications_screen.dart';
import 'package:greenbin/screens/onboarding/onboarding_screen.dart';
import 'package:greenbin/screens/pickups/my_pickups_screen.dart';
import 'package:greenbin/screens/pickups/pickup_details_screen.dart';
import 'package:greenbin/screens/profile/change_password_screen.dart';
import 'package:greenbin/screens/profile/edit_profile_screen.dart';
import 'package:greenbin/screens/profile/help_faq_screen.dart';
import 'package:greenbin/screens/profile/profile_screen.dart';
import 'package:greenbin/screens/profile/settings_screen.dart';
import 'package:greenbin/screens/schedule/pickup_confirmation_screen.dart';
import 'package:greenbin/screens/schedule/review_pickup_screen.dart';
import 'package:greenbin/screens/schedule/schedule_pickup_screen.dart';
import 'package:greenbin/screens/splash/splash_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
  final sampleUser = UserModel(
    id: 'usr-audit-1',
    name: 'Vrutti Patil',
    email: 'vrutti@greenbin.eco',
    phone: '+1 (555) 019-2834',
    community: 'Springfield Eco Ward',
    address: '100 Green View Road',
    city: 'Springfield Eco Ward',
    postalCode: '97477',
    landmark: 'Near Solar Park Gate',
    role: 'resident',
    totalPickups: 12,
    kgRecycled: 48.5,
    createdAt: DateTime(2026, 1, 1),
  );

  final samplePickup = PickupModel(
    id: 'GB-AUDIT-9900',
    userId: 'usr-audit-1',
    residentName: 'Vrutti Patil',
    residentPhone: '+1 (555) 019-2834',
    wasteCategory: 'Plastic',
    subCategories: const ['Beverage bottles (PET)', 'Milk jugs (HDPE)'],
    pickupDate: DateTime(2026, 10, 15, 10, 0),
    timeSlot: '10:00 AM - 12:00 PM',
    address: '100 Green View Road',
    city: 'Springfield Eco District',
    postalCode: '97477',
    landmark: 'Near Solar Park Gate',
    notes: 'Please buzz apartment 402 upon arrival.',
    status: PickupStatus.scheduled,
    createdAt: DateTime(2026, 10, 1, 9, 30),
    updatedAt: DateTime(2026, 10, 1, 9, 30),
  );

  final sampleCategory = WasteCategoryItem.defaultCategories.first;

  final Map<String, Size> viewports = {
    // MOBILE (portrait & landscape)
    'Mobile 320x568 (P)': const Size(320, 568),
    'Mobile 568x320 (L)': const Size(568, 320),
    'Mobile 360x800 (P)': const Size(360, 800),
    'Mobile 800x360 (L)': const Size(800, 360),
    'Mobile 390x844 (P)': const Size(390, 844),
    'Mobile 844x390 (L)': const Size(844, 390),
    'Mobile 430x932 (P)': const Size(430, 932),
    'Mobile 932x430 (L)': const Size(932, 430),

    // TABLET (portrait & landscape)
    'Tablet 600x960 (P)': const Size(600, 960),
    'Tablet 960x600 (L)': const Size(960, 600),
    'Tablet 768x1024 (P)': const Size(768, 1024),
    'Tablet 1024x768 (L)': const Size(1024, 768),

    // DESKTOP
    'Desktop 1280x720': const Size(1280, 720),
    'Desktop 1366x768': const Size(1366, 768),
    'Desktop 1440x900': const Size(1440, 900),
    'Desktop 1920x1080': const Size(1920, 1080),
  };

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
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

  // List of all 20 screens with their builders
  final Map<String, Widget Function()> screens = {
    '1. Splash': () => const SplashScreen(),
    '2. Onboarding': () => const OnboardingScreen(),
    '3. Login': () => const LoginScreen(),
    '4. Register': () => const RegisterScreen(),
    '5. Forgot Password': () => const ForgotPasswordScreen(),
    '6. Profile Setup': () => const ProfileSetupScreen(),
    '7. Home': () => const HomeScreen(),
    '8. Waste Category Guide': () => const WasteGuideScreen(),
    '9. Category Details': () => CategoryDetailsScreen(category: sampleCategory),
    '10. Schedule Pickup': () => const SchedulePickupScreen(),
    '11. Review Pickup': () => ReviewPickupScreen(pickup: samplePickup),
    '12. Pickup Confirmation': () => PickupConfirmationScreen(pickup: samplePickup),
    '13. My Pickups': () => MyPickupsScreen(
          initialUserId: sampleUser.id,
          pickupsStream: Stream.value([samplePickup]),
        ),
    '14. Pickup Details': () => PickupDetailsScreen(
          initialPickup: samplePickup,
          pickupStream: Stream.value(samplePickup),
        ),
    '15. Notifications': () => const NotificationsScreen(),
    '16. Profile': () => ProfileScreen(
          initialUser: sampleUser,
          userStream: Stream.value(sampleUser),
        ),
    '17. Edit Profile': () => EditProfileScreen(initialUser: sampleUser),
    '18. Settings': () => const SettingsScreen(),
    '19. Change Password': () => const ChangePasswordScreen(),
    '20. Help & FAQ': () => const HelpFaqScreen(),
  };

  group('COMPLETE RESPONSIVE AUDIT (20 Screens x 16 Viewports = 320 Tests)', () {
    for (final screenEntry in screens.entries) {
      group('Screen: ${screenEntry.key}', () {
        for (final vpEntry in viewports.entries) {
          testWidgets('${screenEntry.key} renders cleanly without overflow on ${vpEntry.key}', (tester) async {
            setViewport(tester, vpEntry.value);

            await tester.pumpWidget(wrapWithApp(screenEntry.value()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));

            // Verify zero unhandled exceptions (catches RenderFlex overflow, clipping, etc.)
            expect(
              tester.takeException(),
              isNull,
              reason: 'Overflow/layout exception detected on ${screenEntry.key} at ${vpEntry.key}',
            );
          });
        }
      });
    }
  });
}

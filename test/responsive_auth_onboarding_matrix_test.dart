import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/auth/forgot_password_screen.dart';
import 'package:greenbin/screens/auth/login_screen.dart';
import 'package:greenbin/screens/auth/profile_setup_screen.dart';
import 'package:greenbin/screens/auth/register_screen.dart';
import 'package:greenbin/screens/onboarding/onboarding_screen.dart';
import 'package:greenbin/screens/splash/splash_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Standard test viewports representing all requested device classes and orientations
  const viewports = <String, Size>{
    'small mobile (320x480)': Size(320, 480),
    'small mobile landscape (568x320)': Size(568, 320),
    'standard mobile (390x844)': Size(390, 844),
    'standard mobile landscape (844x390)': Size(844, 390),
    'large mobile (428x926)': Size(428, 926),
    'large mobile landscape (926x428)': Size(926, 428),
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

  Widget buildViewport(Widget screen) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: screen,
    );
  }

  group('Screen 1: Splash Screen across all viewports', () {
    for (final entry in viewports.entries) {
      testWidgets('renders without overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(
            const SplashScreen(autoNavigate: false),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('GreenBin'), findsOneWidget);
        expect(find.text('Community Recycling Pickup Scheduler'), findsOneWidget);
      });
    }
  });

  group('Screen 2, 3, 4: Onboarding (Recycle Smarter, Schedule Easy Pickups, Track Your Recycling)', () {
    for (final entry in viewports.entries) {
      testWidgets('renders all controls without overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(const OnboardingScreen()),
        );
        expect(tester.takeException(), isNull);

        // Slide 1 verify
        expect(find.text('Recycle Smarter'), findsOneWidget);
        expect(find.textContaining('Skip'), findsOneWidget);

        // Advance to slide 2
        final nextFinder = find.byType(ElevatedButton).first;
        await tester.tap(nextFinder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Slide 2 verify
        expect(find.text('Schedule Easy Pickups'), findsOneWidget);

        // Advance to slide 3
        final nextFinder2 = find.byType(ElevatedButton).first;
        await tester.tap(nextFinder2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Slide 3 verify
        expect(find.text('Track Your Recycling'), findsOneWidget);
      });
    }
  });

  group('Screen 5: Login Screen across all viewports', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(const LoginScreen()),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Remember me'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);

        // Verify form validation triggers cleanly
        final loginBtn = find.text('Log In');
        await tester.ensureVisible(loginBtn);
        await tester.tap(loginBtn);
        await tester.pump();
        expect(find.text('Please enter your email.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Screen 6: Register Screen across all viewports', () {
    for (final entry in viewports.entries) {
      testWidgets('renders cleanly without overflow on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(const RegisterScreen()),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Join GreenBin'), findsOneWidget);
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.text('Create Account & Continue'), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);

        // Tap create account without filling to trigger validation
        final registerBtn = find.text('Create Account & Continue');
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pump();
        expect(find.text('Please enter your full name.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Screen 7: Forgot Password Screen across all viewports', () {
    for (final entry in viewports.entries) {
      testWidgets('renders form and handles inputs on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(const ForgotPasswordScreen()),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Forgot your password?'), findsOneWidget);
        expect(find.text('Registered Email Address'), findsOneWidget);
        expect(find.text('Send Reset Link'), findsOneWidget);
        expect(find.text('Back to Login'), findsOneWidget);

        // Tap send reset link without email
        final sendBtn = find.text('Send Reset Link');
        await tester.ensureVisible(sendBtn);
        await tester.tap(sendBtn);
        await tester.pump();
        expect(find.text('Please enter your email.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Screen 8: Profile Setup Screen across all viewports', () {
    for (final entry in viewports.entries) {
      testWidgets('renders responsive residence and address sections on ${entry.key}', (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(
          buildViewport(const ProfileSetupScreen()),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Complete Profile Setup'), findsOneWidget);
        expect(find.text('Resident Information'), findsOneWidget);
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Contact Phone Number'), findsOneWidget);
        expect(find.text('Residence Type'), findsOneWidget);
        expect(find.text('Apartment'), findsOneWidget);
        expect(find.text('House'), findsOneWidget);
        expect(find.text('Villa'), findsOneWidget);
        expect(find.text('Gated Community'), findsOneWidget);
        expect(find.text('Pickup Address'), findsOneWidget);
        expect(find.text('Street Address'), findsOneWidget);
        expect(find.text('Save & Enter GreenBin'), findsOneWidget);
        expect(find.text('Skip for now (I will configure this later)'), findsOneWidget);

        // Select a different residence type
        final houseChip = find.text('House');
        await tester.ensureVisible(houseChip);
        await tester.tap(houseChip);
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

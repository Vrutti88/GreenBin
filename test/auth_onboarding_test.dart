import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Widget buildScreen(Widget screen, {Size size = const Size(320, 640)}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: screen,
        ),
      ),
    );
  }

  testWidgets('Screen 1: SplashScreen renders on small mobile (320x480)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildScreen(const SplashScreen(), size: const Size(320, 480)),
    );
    expect(find.text('GreenBin'), findsOneWidget);
    expect(find.text('Community Recycling Pickup Scheduler'), findsOneWidget);
  });

  testWidgets('Screen 2, 3, 4: OnboardingScreen renders slides and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildScreen(const OnboardingScreen(), size: const Size(360, 640)),
    );
    // Slide 1: Recycle Smarter
    expect(find.text('Recycle Smarter'), findsOneWidget);
    expect(find.text('ZERO-WASTE COMMUNITY SORTING'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Screen 5: LoginScreen renders without overflow on narrow 320px phone',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildScreen(const LoginScreen(), size: const Size(320, 568)),
    );
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('Screen 6: RegisterScreen renders on 320px screen without overflow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildScreen(const RegisterScreen(), size: const Size(320, 600)),
    );
    expect(find.text('Join GreenBin'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Create Account & Continue'), findsOneWidget);
  });

  testWidgets('Screen 7: ForgotPasswordScreen renders without overflow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildScreen(const ForgotPasswordScreen(), size: const Size(320, 500)),
    );
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
  });

  testWidgets('Screen 8: ProfileSetupScreen renders on mobile and desktop without overflow',
      (WidgetTester tester) async {
    // Mobile Viewport
    await tester.pumpWidget(
      buildScreen(const ProfileSetupScreen(), size: const Size(320, 700)),
    );
    expect(find.text('Complete Profile Setup'), findsOneWidget);
    expect(find.text('Apartment'), findsOneWidget);
    expect(find.text('Save & Enter GreenBin'), findsOneWidget);

    // Desktop Viewport
    await tester.pumpWidget(
      buildScreen(const ProfileSetupScreen(), size: const Size(1200, 800)),
    );
    expect(find.text('Complete Profile Setup'), findsOneWidget);
    expect(find.text('Save & Enter GreenBin'), findsOneWidget);
  });
}

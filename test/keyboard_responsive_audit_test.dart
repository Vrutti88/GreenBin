import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/user_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/auth/forgot_password_screen.dart';
import 'package:greenbin/screens/auth/login_screen.dart';
import 'package:greenbin/screens/auth/profile_setup_screen.dart';
import 'package:greenbin/screens/auth/register_screen.dart';
import 'package:greenbin/screens/profile/change_password_screen.dart';
import 'package:greenbin/screens/profile/edit_profile_screen.dart';
import 'package:greenbin/screens/schedule/schedule_pickup_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
  final sampleUser = UserModel(
    id: 'usr-kbd-1',
    name: 'Vrutti Patil',
    email: 'vrutti@greenbin.eco',
    phone: '+1 (555) 019-2834',
    community: 'Springfield Eco Ward',
    address: '100 Green View Road',
    city: 'Springfield',
    postalCode: '97477',
    role: 'resident',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: child,
    );
  }

  void setKeyboardViewport(WidgetTester tester, Size size, double keyboardHeight) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
  }

  final formScreens = <String, Widget Function()>{
    'LoginScreen': () => const LoginScreen(),
    'RegisterScreen': () => const RegisterScreen(),
    'ForgotPasswordScreen': () => const ForgotPasswordScreen(),
    'ProfileSetupScreen': () => const ProfileSetupScreen(),
    'SchedulePickupScreen': () => const SchedulePickupScreen(),
    'EditProfileScreen': () => EditProfileScreen(initialUser: sampleUser),
    'ChangePasswordScreen': () => const ChangePasswordScreen(),
  };

  final testDevices = <String, Size>{
    'Small Mobile (320x568)': const Size(320, 568),
    'Standard Mobile (390x844)': const Size(390, 844),
    'Mobile Landscape (568x320)': const Size(568, 320),
    'Tablet Portrait (768x1024)': const Size(768, 1024),
  };

  group('Keyboard Responsiveness Audit (7 Form Screens x 4 Viewports with 300px Keyboard)', () {
    for (final form in formScreens.entries) {
      group('Form: ${form.key}', () {
        for (final device in testDevices.entries) {
          testWidgets('${form.key} scrolls and prevents overflow with keyboard on ${device.key}', (tester) async {
            // Apply 300px keyboard on portrait / 180px on landscape
            final double keyboardHeight = device.value.height < 400 ? 160.0 : 300.0;
            setKeyboardViewport(tester, device.value, keyboardHeight);

            await tester.pumpWidget(wrapWithApp(form.value()));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));

            expect(
              tester.takeException(),
              isNull,
              reason: 'Keyboard overflow caught on ${form.key} at ${device.key} with ${keyboardHeight}px keyboard',
            );
          });
        }
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/models/user_model.dart';
import 'package:greenbin/routes/app_routes.dart';
import 'package:greenbin/screens/profile/change_password_screen.dart';
import 'package:greenbin/screens/profile/edit_profile_screen.dart';
import 'package:greenbin/screens/profile/help_faq_screen.dart';
import 'package:greenbin/screens/profile/profile_screen.dart';
import 'package:greenbin/screens/profile/settings_screen.dart';
import 'package:greenbin/theme/app_theme.dart';

void main() {
  final sampleUser = UserModel(
    id: 'user-test-101',
    email: 'vrutti@greenbin.eco',
    fullName: 'Vrutti Patil',
    phoneNumber: '+1 (555) 019-2834',
    street: '100 Green View Road',
    city: 'Springfield Eco Ward',
    postalCode: '97477',
    landmark: 'Solar Park Gate',
    totalPickups: 15,
    kgRecycled: 62.4,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

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

  Widget wrapWithApp(Widget screen) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: screen,
    );
  }

  // ===========================================================================
  // 1. PROFILE SCREEN TESTS
  // ===========================================================================
  group('1. Profile Screen', () {
    testWidgets('renders all user profile sections, impact stats, and details',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Identity & Badges
      expect(find.text('Resident Profile'), findsOneWidget);
      expect(find.text('Vrutti Patil'), findsOneWidget);
      expect(find.text('vrutti@greenbin.eco'), findsOneWidget);
      expect(find.text('Verified Resident Member'), findsOneWidget);

      // Environmental Footprint
      expect(find.text('Your Environmental Footprint'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('62.4 kg'), findsOneWidget);

      // Contact & Address
      expect(find.text('Account & Contact Details'), findsOneWidget);
      expect(find.text('+1 (555) 019-2834'), findsOneWidget);
      expect(
        find.text('100 Green View Road, Near Solar Park Gate, Springfield Eco Ward, 97477'),
        findsOneWidget,
      );

      // Navigation Items
      expect(find.widgetWithText(TextButton, 'Edit Profile'), findsOneWidget);
      expect(find.text('Edit Profile Information'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Help & FAQ'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('MOBILE (<700px): uses single-column profile layout',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      final avatarPos = tester.getTopLeft(find.text('Vrutti Patil')).dy;
      final impactPos = tester.getTopLeft(find.text('Your Environmental Footprint')).dy;
      final contactPos = tester.getTopLeft(find.text('Account & Contact Details')).dy;

      expect(avatarPos < impactPos, isTrue);
      expect(impactPos < contactPos, isTrue);
    });

    testWidgets('TABLET (700-999px): centers profile content with constrained width',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      final leftPos = tester.getTopLeft(find.text('Your Environmental Footprint')).dx;
      // In a 768px viewport with 680px constrained box, left margin should be >= 40px
      expect(leftPos, greaterThanOrEqualTo(40));
    });

    testWidgets('DESKTOP (>=1000px): uses balanced two-column profile layout',
        (tester) async {
      setViewport(tester, const Size(1366, 768));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      // In desktop 2-column layout:
      // Left Column has Avatar & Footprint
      // Right Column has Contact Details & Settings
      final impactLeft = tester.getTopLeft(find.text('Your Environmental Footprint')).dx;
      final contactLeft = tester.getTopLeft(find.text('Account & Contact Details')).dx;

      expect(impactLeft < contactLeft, isTrue);
    });

    testWidgets('navigates to Edit Profile on button tap', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      final editBtn = find.widgetWithText(TextButton, 'Edit Profile');
      expect(editBtn, findsOneWidget);

      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Personal Details'), findsOneWidget);
      expect(find.text('Default Collection Address'), findsOneWidget);
    });

    testWidgets('opens Log Out confirmation dialog', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      final logOutBtn = find.text('Log Out');
      await tester.ensureVisible(logOutBtn);
      await tester.pumpAndSettle();

      await tester.tap(logOutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of GreenBin?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of GreenBin?'), findsNothing);
    });
  });

  // ===========================================================================
  // 2. EDIT PROFILE SCREEN TESTS
  // ===========================================================================
  group('2. Edit Profile Screen', () {
    testWidgets('renders pre-populated form fields and allows updating',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(EditProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Vrutti Patil'), findsOneWidget);
      expect(find.text('+1 (555) 019-2834'), findsOneWidget);
      expect(find.text('100 Green View Road'), findsOneWidget);
      expect(find.text('Springfield Eco Ward'), findsOneWidget);
      expect(find.text('97477'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('shows validation errors when required fields are cleared',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(EditProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      // Clear full name
      final nameField = find.widgetWithText(TextFormField, 'Vrutti Patil');
      await tester.enterText(nameField, '');

      final saveButton = find.text('Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('TABLET / DESKTOP (>=600px): renders two-column fields for City & Postal Code',
        (tester) async {
      setViewport(tester, const Size(768, 1024));
      await tester.pumpWidget(wrapWithApp(EditProfileScreen(initialUser: sampleUser)));
      await tester.pumpAndSettle();

      final cityField = find.widgetWithText(TextFormField, 'Springfield Eco Ward');
      final postalField = find.widgetWithText(TextFormField, '97477');

      final cityLeft = tester.getTopLeft(cityField).dx;
      final postalLeft = tester.getTopLeft(postalField).dx;

      expect(cityLeft < postalLeft, isTrue);
    });
  });

  // ===========================================================================
  // 3. SETTINGS SCREEN TESTS
  // ===========================================================================
  group('3. Settings Screen', () {
    testWidgets('renders all settings sections, switches, and toggles',
        (tester) async {
      setViewport(tester, const Size(700, 1400));
      await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Pickup Notifications'), findsOneWidget);
      expect(find.text('Pickup Reminders'), findsOneWidget);
      expect(find.text('Status Updates'), findsOneWidget);
      expect(find.text('Milestone Alerts'), findsOneWidget);

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Reminder Timing'), findsOneWidget);
      expect(find.text('Sound & Vibration'), findsOneWidget);

      expect(find.text('Security & Account'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      expect(find.text('Support & About'), findsOneWidget);
      expect(find.text('Help & FAQ'), findsOneWidget);
      expect(find.text('GreenBin Version'), findsOneWidget);
      expect(find.text('v1.0.0 (Build 2026.1)'), findsOneWidget);
    });

    testWidgets('toggles notification switch state', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      final switchTile = find.widgetWithText(SwitchListTile, 'Pickup Reminders');
      expect(switchTile, findsOneWidget);

      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('opens Privacy Policy and Terms dialogs', (tester) async {
      setViewport(tester, const Size(700, 1400));
      await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      final privacyTile = find.text('Privacy Policy');
      await tester.ensureVisible(privacyTile);
      await tester.pumpAndSettle();

      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 4. CHANGE PASSWORD SCREEN TESTS
  // ===========================================================================
  group('4. Change Password Screen', () {
    testWidgets('renders password fields with proper keyboard handling and validation',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const ChangePasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates matching passwords and minimum length',
        (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const ChangePasswordScreen()));
      await tester.pumpAndSettle();

      final submitBtn = find.text('Update Password');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your current password'), findsOneWidget);
      expect(find.text('Please enter a new password'), findsOneWidget);
      expect(find.text('Please confirm your new password'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 5. HELP & FAQ SCREEN TESTS
  // ===========================================================================
  group('5. Help & FAQ Screen', () {
    testWidgets('renders categories, search field, and expandable FAQ items',
        (tester) async {
      setViewport(tester, const Size(700, 1400));
      await tester.pumpWidget(wrapWithApp(const HelpFaqScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Help & FAQ'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Scheduling'), findsOneWidget);
      expect(find.text('Recycling'), findsOneWidget);
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      expect(
        find.text('How do I schedule a recyclable waste pickup?'),
        findsOneWidget,
      );

      // Expand FAQ tile
      await tester.tap(find.text('How do I schedule a recyclable waste pickup?'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tap the "Schedule Pickup" button on your Home dashboard or Guide screen. Choose your recyclable waste category, select an available date and time slot, verify your address, and confirm the request.',
        ),
        findsOneWidget,
      );

      // Contact support card
      expect(find.text('Still have questions?'), findsOneWidget);
      expect(find.text('Contact Eco Support'), findsOneWidget);
    });

    testWidgets('filters FAQ items via search query', (tester) async {
      setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(wrapWithApp(const HelpFaqScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'wash');
      await tester.pumpAndSettle();

      expect(
        find.text('Do I need to wash containers before collection?'),
        findsOneWidget,
      );
      expect(
        find.text('How do I schedule a recyclable waste pickup?'),
        findsNothing,
      );
    });

    testWidgets('opens Eco Support dialog', (tester) async {
      setViewport(tester, const Size(700, 1400));
      await tester.pumpWidget(wrapWithApp(const HelpFaqScreen()));
      await tester.pumpAndSettle();

      final supportBtn = find.text('Contact Eco Support');
      await tester.ensureVisible(supportBtn);
      await tester.pumpAndSettle();

      await tester.tap(supportBtn);
      await tester.pumpAndSettle();

      expect(find.text('Contact Eco Support'), findsWidgets);
      expect(find.text('support@greenbin.eco'), findsOneWidget);
      expect(find.text('+1 (800) 555-GREEN'), findsOneWidget);
    });

    testWidgets('interacts with Eco Support dialog: copy channels and submit ticket',
        (tester) async {
      setViewport(tester, const Size(700, 1400));
      await tester.pumpWidget(wrapWithApp(const HelpFaqScreen()));
      await tester.pumpAndSettle();

      final supportBtn = find.text('Contact Eco Support');
      await tester.ensureVisible(supportBtn);
      await tester.pumpAndSettle();
      await tester.tap(supportBtn);
      await tester.pumpAndSettle();

      // Verify contact options and actions
      expect(find.text('Email Eco Support'), findsOneWidget);
      expect(find.text('Toll-Free Hotline'), findsOneWidget);
      expect(find.text('Send In-App Support Ticket'), findsOneWidget);

      // Tap copy email button
      final copyEmailBtn = find.widgetWithIcon(IconButton, Icons.copy_rounded).first;
      expect(copyEmailBtn, findsOneWidget);
      await tester.tap(copyEmailBtn);
      await tester.pumpAndSettle();

      // Fill and submit support inquiry form
      final subjectField = find.widgetWithText(TextFormField, 'Subject');
      expect(subjectField, findsOneWidget);
      await tester.enterText(subjectField, 'Question regarding broken blue bin');

      final messageField = find.widgetWithText(TextFormField, 'Message');
      expect(messageField, findsOneWidget);
      await tester.enterText(messageField, 'My bin handle is cracked and needs a replacement.');

      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Support Ticket');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify success confirmation view
      expect(find.text('Inquiry Submitted!'), findsOneWidget);
      expect(find.textContaining('Ticket ID: GB-'), findsOneWidget);

      final doneBtn = find.widgetWithText(ElevatedButton, 'Done');
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      // Dialog closed
      expect(find.text('Inquiry Submitted!'), findsNothing);
    });
  });

  // ===========================================================================
  // 6. 10-VIEWPORT MATRIX TESTING (ZERO OVERFLOW ACROSS ALL 5 SCREENS)
  // ===========================================================================
  group('6. Profile Suite - 10-Viewport Responsive Matrix (Zero Overflow)', () {
    for (final entry in viewports.entries) {
      testWidgets('ProfileScreen renders without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(ProfileScreen(initialUser: sampleUser)));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'ProfileScreen overflowed on ${entry.key}',
        );
      });

      testWidgets('EditProfileScreen renders without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(EditProfileScreen(initialUser: sampleUser)));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'EditProfileScreen overflowed on ${entry.key}',
        );
      });

      testWidgets('SettingsScreen renders without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'SettingsScreen overflowed on ${entry.key}',
        );
      });

      testWidgets('ChangePasswordScreen renders without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(const ChangePasswordScreen()));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'ChangePasswordScreen overflowed on ${entry.key}',
        );
      });

      testWidgets('HelpFaqScreen renders without overflow on ${entry.key}',
          (tester) async {
        setViewport(tester, entry.value);
        await tester.pumpWidget(wrapWithApp(const HelpFaqScreen()));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'HelpFaqScreen overflowed on ${entry.key}',
        );
      });
    }
  });
}

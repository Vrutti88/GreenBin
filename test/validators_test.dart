import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenbin/screens/auth/register_screen.dart';
import 'package:greenbin/theme/app_theme.dart';
import 'package:greenbin/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppValidators.validateEmail unit tests', () {
    test('returns error when email is null or empty', () {
      expect(AppValidators.validateEmail(null), 'Please enter your email.');
      expect(AppValidators.validateEmail(''), 'Please enter your email.');
      expect(AppValidators.validateEmail('   '), 'Please enter your email.');
    });

    test('returns specific error when email starts with a number', () {
      expect(
        AppValidators.validateEmail('123@gmail.com'),
        'Email address cannot start with a number.',
      );
      expect(
        AppValidators.validateEmail('9876543210@test.com'),
        'Email address cannot start with a number.',
      );
      expect(
        AppValidators.validateEmail('0abc@domain.com'),
        'Email address cannot start with a number.',
      );
      expect(
        AppValidators.validateEmail('5user@greenbin.org'),
        'Email address cannot start with a number.',
      );
    });

    test('returns specific error when email starts with non-letter symbol', () {
      expect(
        AppValidators.validateEmail('.user@domain.com'),
        'Email address must start with a letter.',
      );
      expect(
        AppValidators.validateEmail('_user@domain.com'),
        'Email address must start with a letter.',
      );
      expect(
        AppValidators.validateEmail('@domain.com'),
        'Email address must start with a letter.',
      );
      expect(
        AppValidators.validateEmail('-user@domain.com'),
        'Email address must start with a letter.',
      );
    });

    test('returns error when email format is invalid', () {
      expect(
        AppValidators.validateEmail('resident'),
        'Please enter a valid email address.',
      );
      expect(
        AppValidators.validateEmail('resident@'),
        'Please enter a valid email address.',
      );
      expect(
        AppValidators.validateEmail('resident@domain'),
        'Please enter a valid email address.',
      );
      expect(
        AppValidators.validateEmail('resident@domain..com'),
        'Please enter a valid email address.',
      );
      expect(
        AppValidators.validateEmail('resident@.com'),
        'Please enter a valid email address.',
      );
    });

    test('returns null for valid emails', () {
      expect(AppValidators.validateEmail('resident@example.com'), isNull);
      expect(AppValidators.validateEmail('john.doe@greenbin.org'), isNull);
      expect(AppValidators.validateEmail('user_name+tag@sub.domain.co'), isNull);
      expect(AppValidators.validateEmail('  alice@example.com  '), isNull);
    });
  });

  group('RegisterScreen email validation UI tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'shows "Email address cannot start with a number." when email starts with digit',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MediaQuery(
              data: MediaQueryData(size: Size(400, 900)),
              child: RegisterScreen(),
            ),
          ),
        );

        // We find TextFormFields: 0: Name, 1: Phone, 2: Email, 3: Password, 4: ConfirmPassword
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(5));

        await tester.enterText(textFields.at(0), 'John Doe');
        await tester.enterText(textFields.at(1), '+1234567890');
        // Enter email starting with a number
        await tester.enterText(textFields.at(2), '9876543210@test.com');
        await tester.enterText(textFields.at(3), 'password123');
        await tester.enterText(textFields.at(4), 'password123');

        // Scroll to submit button and tap
        final submitButton = find.text('Create Account & Continue');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should display the validation error
        expect(
          find.text('Email address cannot start with a number.'),
          findsOneWidget,
        );
      },
    );
  });
}

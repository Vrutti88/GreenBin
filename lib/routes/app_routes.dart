import 'package:flutter/material.dart';
import '../models/pickup_model.dart';
import '../models/user_model.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/design_system/design_system_screen.dart';
import '../screens/guide/category_details_screen.dart';
import '../screens/guide/waste_guide_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/pickups/my_pickups_screen.dart';
import '../screens/pickups/pickup_details_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/help_faq_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/schedule/pickup_confirmation_screen.dart';
import '../screens/schedule/review_pickup_screen.dart';
import '../screens/schedule/schedule_pickup_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Centralized route definitions and route generator for GreenBin.
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String guide = '/guide';
  static const String schedule = '/schedule';
  static const String reviewPickup = '/review-pickup';
  static const String pickupConfirmation = '/pickup-confirmation';
  static const String pickups = '/pickups';
  static const String pickupDetails = '/pickup-details';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String profileSetup = '/profile-setup';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String helpFaq = '/help-faq';
  static const String categoryDetails = '/category-details';
  static const String designSystem = '/design-system';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case guide:
        return MaterialPageRoute(builder: (_) => const WasteGuideScreen());
      case categoryDetails:
        final category = routeSettings.arguments is WasteCategoryItem
            ? routeSettings.arguments as WasteCategoryItem
            : routeSettings.arguments is String
                ? WasteCategoryItem.findByNameOrId(routeSettings.arguments as String)
                : null;
        return MaterialPageRoute(
          builder: (_) => CategoryDetailsScreen(category: category),
        );
      case schedule:
        final initialCategory = routeSettings.arguments is String
            ? routeSettings.arguments as String
            : routeSettings.arguments is WasteCategoryItem
                ? (routeSettings.arguments as WasteCategoryItem).name
                : null;
        return MaterialPageRoute(
          builder: (_) => SchedulePickupScreen(initialCategory: initialCategory),
        );
      case reviewPickup:
        final pickup = routeSettings.arguments is PickupModel
            ? routeSettings.arguments as PickupModel
            : null;
        return MaterialPageRoute(
          builder: (_) => ReviewPickupScreen(pickup: pickup),
        );
      case pickupConfirmation:
        final pickup = routeSettings.arguments is PickupModel
            ? routeSettings.arguments as PickupModel
            : null;
        return MaterialPageRoute(
          builder: (_) => PickupConfirmationScreen(pickup: pickup),
        );
      case pickups:
        return MaterialPageRoute(builder: (_) => const MyPickupsScreen());
      case pickupDetails:
        final initialPickup = routeSettings.arguments is PickupModel
            ? routeSettings.arguments as PickupModel
            : null;
        final pickupId = routeSettings.arguments is String
            ? routeSettings.arguments as String
            : null;
        return MaterialPageRoute(
          builder: (_) => PickupDetailsScreen(
            initialPickup: initialPickup,
            pickupId: pickupId,
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        final initialUser = routeSettings.arguments is UserModel
            ? routeSettings.arguments as UserModel
            : null;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(initialUser: initialUser),
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case helpFaq:
        return MaterialPageRoute(builder: (_) => const HelpFaqScreen());
      case designSystem:
        return MaterialPageRoute(builder: (_) => const DesignSystemScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

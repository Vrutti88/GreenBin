import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';

/// Screen 1: Splash Screen
/// Initializes application state, checks Firebase Auth, verifies profile completeness,
/// and determines navigation between Onboarding, Login, Profile Setup, or Home.
class SplashScreen extends StatefulWidget {
  final Duration delay;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 1400),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  Timer? _routingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoNavigate) {
      _routingTimer = Timer(widget.delay, () {
        if (mounted) {
          _handleRouting();
        }
      });
    }
  }

  @override
  void dispose() {
    _routingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRouting() async {
    if (!mounted) return;

    final user = _authService.currentUser;

    if (user != null) {
      // User is authenticated, verify if profile is completed in Firestore
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (!mounted) return;

      if (profile != null && profile.isProfileComplete) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      }
      return;
    }

    // Check if resident has previously seen onboarding
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;

      if (!mounted) return;
      if (hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveContainer(
              maxWidth: AppBreakpoints.maxCardWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Animated / Styled Brand Emblem
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),

                // Brand Name
                Text(
                  'GreenBin',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Community Subtitle
                Text(
                  'Community Recycling Pickup Scheduler',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Progress Indicator
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}

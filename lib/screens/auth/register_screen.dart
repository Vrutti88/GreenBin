import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/widgets.dart';

/// Screen 6: Register Screen
/// Creates resident account via Firebase Authentication, initializes user profile
/// in Cloud Firestore, and advances to Profile Setup.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _agreeToTerms = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Community Guidelines & Terms.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = UserModel(
        id: cred.user!.uid,
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: 'resident',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveUserProfile(user);

      if (!mounted) return;
      // Advance to profile setup for address and housing preferences
      Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ResponsiveContainer(
              maxWidth: AppBreakpoints.maxFormWidth,
              child: Card(
                elevation: context.isMobile ? 0 : 1,
                color: context.isMobile
                    ? Colors.transparent
                    : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: context.isMobile
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.isMobile ? 8.0 : 36.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Brand Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.recycling_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GreenBin',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Community Recycling',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        Text(
                          'Join GreenBin',
                          style: AppTextStyles.displaySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a resident account to start scheduling recyclable waste pickups.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          ErrorState(
                            message: _errorMessage!,
                            isCard: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Full Name Field
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          isRequired: true,
                          hint: 'Enter your name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Please enter your full name.'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          isRequired: true,
                          hint: '+1 234 567 8900',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Please enter your phone number.'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          isRequired: true,
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: AppValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          isRequired: true,
                          hint: 'Minimum 6 characters',
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (value) => (value == null || value.length < 6)
                              ? 'Password must be at least 6 characters.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          isRequired: true,
                          hint: 'Re-enter your password',
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Please confirm your password.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Terms and Community Guidelines Agreement
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() => _agreeToTerms = val ?? true);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I agree to the Community Recycling Guidelines and Terms of Service.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        PrimaryButton(
                          text: 'Create Account & Continue',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.bodyMedium,
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: Text(
                                    'Log In',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

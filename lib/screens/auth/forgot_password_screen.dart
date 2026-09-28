import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/widgets.dart';

/// Screen 7: Forgot Password Screen
/// Allows residents to request a secure password reset link via Firebase Authentication.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      setState(() {
        _isSuccess = true;
      });
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
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
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
                  child: _isSuccess
                      ? _buildSuccessView(context)
                      : _buildFormView(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Forgot your password?',
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your registered email address and we will send you secure instructions to reset your account password.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            ErrorState(
              message: _errorMessage!,
              isCard: true,
            ),
            const SizedBox(height: 20),
          ],

          AppTextField(
            controller: _emailController,
            label: 'Registered Email Address',
            isRequired: true,
            hint: 'resident@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email.';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          PrimaryButton(
            text: 'Send Reset Link',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 12),

          SecondaryButton(
            text: 'Back to Login',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      children: [
        EmptyState(
          icon: Icons.mark_email_read_rounded,
          title: 'Reset Link Dispatched',
          message:
              'We have sent password reset instructions to ${_emailController.text}. Please check your inbox and spam folder.',
          actionText: 'Return to Login',
          actionIcon: Icons.login_rounded,
          onActionPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'secondary_button.dart';

/// Responsive Error State widget for network failures, Firestore query errors,
/// or general submission issues.
class ErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final bool isCard;

  const ErrorState({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
    this.isCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.statusCancelledBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.statusCancelled.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: AppColors.statusCancelled,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title ?? 'Something went wrong',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          SecondaryButton(
            text: retryText,
            icon: Icons.refresh_rounded,
            isFullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ],
    );

    if (isCard) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.statusCancelledBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.statusCancelled.withValues(alpha: 0.25),
          ),
        ),
        child: content,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: content,
        ),
      ),
    );
  }
}

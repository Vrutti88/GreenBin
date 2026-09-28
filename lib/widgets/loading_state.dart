import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Responsive loading indicator with branded eco-green spinner and optional status text.
class LoadingState extends StatelessWidget {
  final String? message;
  final double size;
  final bool isOverlay;

  const LoadingState({
    super.key,
    this.message,
    this.size = 36.0,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: indicator,
      );
    }

    return indicator;
  }
}

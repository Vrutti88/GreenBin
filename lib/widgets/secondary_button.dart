import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Secondary outlined action button with adaptive width, accessible touch target, and loading support.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isFullWidth;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48.0,
    this.isFullWidth = true,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    Widget buttonContent;

    if (isLoading) {
      buttonContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: effectiveTextColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.labelLarge.copyWith(color: effectiveTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveTextColor,
        side: BorderSide(color: effectiveBorderColor, width: 1.5),
        minimumSize: Size(width ?? (isFullWidth ? double.infinity : 64.0), height),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: buttonContent,
    );

    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }

    return button;
  }
}

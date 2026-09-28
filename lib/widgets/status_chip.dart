import 'package:flutter/material.dart';
import '../models/pickup_model.dart';
import '../theme/app_text_styles.dart';

/// Pill badge showing pickup lifecycle state with semantic color-coding and an indicator dot.
class StatusChip extends StatelessWidget {
  final PickupStatus status;
  final bool isCompact;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: isCompact ? 6 : 8,
              height: isCompact ? 6 : 8,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: isCompact ? 5 : 7),
          ],
          Text(
            status.displayName,
            style: (isCompact ? AppTextStyles.labelSmall : AppTextStyles.labelMedium).copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

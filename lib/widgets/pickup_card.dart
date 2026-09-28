import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pickup_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_chip.dart';

/// Fully responsive card displaying a scheduled or completed pickup.
/// Guarantees zero text overflow on narrow mobile screens (320dp+) while
/// maintaining elegant proportions on wide tablet and desktop grids.
class PickupCard extends StatelessWidget {
  final PickupModel pickup;
  final VoidCallback? onTap;

  const PickupCard({
    super.key,
    required this.pickup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(pickup.pickupDate);

    // Dynamic category icon & color lookup
    IconData categoryIcon = Icons.recycling_rounded;
    Color categoryColor = AppColors.primary;
    for (final cat in WasteCategoryItem.defaultCategories) {
      if (cat.name.toLowerCase() == pickup.category.toLowerCase() ||
          cat.id.toLowerCase() == pickup.category.toLowerCase()) {
        categoryIcon = cat.icon;
        categoryColor = cat.color;
        break;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for Card internal padding (16 left + 16 right = 32) and icon width (15 + 6 = 21)
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth - 32
            : 300.0;
        final maxChipTextWidth = (availableWidth - 26).clamp(40.0, double.infinity);

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row: Category Badge + Status Chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(categoryIcon, color: categoryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickup.category,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (pickup.subCategories.isNotEmpty)
                              Text(
                                pickup.subCategories.join(', '),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: pickup.status, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Date & Time: Wrap with constrained max widths prevents overflow on narrow screens
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxChipTextWidth),
                            child: Text(
                              formattedDate,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxChipTextWidth),
                            child: Text(
                              pickup.timeSlot,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Address Row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pickup.fullAddress,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/pickup_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable, fully responsive Waste Category Card widget.
/// Guarantees consistent typography, icon sizing, spacing, and aspect ratio
/// across Mobile (single-column), Tablet (2-column grid), and Desktop (3-column grid).
class WasteCategoryCard extends StatelessWidget {
  final WasteCategoryItem category;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCompact;
  final bool isSingleColumn;

  const WasteCategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.isCompact = false,
    this.isSingleColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSingleColumn) {
      return _buildSingleColumnCard(context);
    }
    return _buildGridCard(context);
  }

  /// Single-column card optimized for Mobile ListView
  Widget _buildSingleColumnCard(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? category.color : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? category.color.withValues(alpha: 0.05)
          : AppColors.surfaceLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Consistent 44x44 icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (category.acceptedItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: category.acceptedItems.take(3).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Grid card optimized for Tablet (2-column) and Desktop (3-column) Responsive GridView
  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? category.color : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? category.color.withValues(alpha: 0.05)
          : AppColors.surfaceLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Icon + Category Name + Trailing Arrow
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Middle: Category Description
              Text(
                category.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Bottom: Accepted Preview Pills
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: category.acceptedItems.take(2).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

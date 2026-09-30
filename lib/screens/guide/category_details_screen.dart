import 'package:flutter/material.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/category_illustration.dart';
import '../../widgets/interactive_animations.dart';

/// Responsive Category Details Screen displaying full material rules,
/// accepted/rejected items, sorting tips, and direct scheduling action.
class CategoryDetailsScreen extends StatelessWidget {
  final WasteCategoryItem? category;

  const CategoryDetailsScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    // Resolve category from constructor or named route arguments
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final resolvedCategory = category ??
        (routeArgs is WasteCategoryItem
            ? routeArgs
            : routeArgs is String
                ? WasteCategoryItem.findByNameOrId(routeArgs)
                : null) ??
        WasteCategoryItem.defaultCategories.first;

    return Scaffold(
      appBar: AppBar(
        title: Text('${resolvedCategory.name} Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Sorting Guide',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Shared ${resolvedCategory.name} recycling guidelines.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: AppBreakpoints.maxContentWidth,
            child: ResponsiveBuilder(
              builder: (context, constraints, deviceType) {
                final isDesktop = deviceType == DeviceScreenType.desktop ||
                    context.screenWidth >= 1000;
                final isTablet = deviceType == DeviceScreenType.tablet;

                if (isDesktop) {
                  return _buildDesktopLayout(context, resolvedCategory);
                } else if (isTablet) {
                  return _buildTabletLayout(context, resolvedCategory);
                } else {
                  return _buildMobileLayout(context, resolvedCategory);
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: context.isMobile
          ? _buildMobileBottomBar(context, resolvedCategory)
          : null,
    );
  }

  // =========================================================================
  // MOBILE SINGLE-COLUMN LAYOUT
  // =========================================================================
  Widget _buildMobileLayout(
      BuildContext context, WasteCategoryItem category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFadeSlide(
          duration: const Duration(milliseconds: 220),
          offsetDistance: 6,
          child: _buildHeroBanner(category),
        ),
        const SizedBox(height: 20),
        AppFadeSlide(
          duration: const Duration(milliseconds: 260),
          offsetDistance: 6,
          child: _buildAcceptedItemsCard(category),
        ),
        const SizedBox(height: 16),
        AppFadeSlide(
          duration: const Duration(milliseconds: 300),
          offsetDistance: 6,
          child: _buildRejectedItemsCard(category),
        ),
        const SizedBox(height: 16),
        AppFadeSlide(
          duration: const Duration(milliseconds: 340),
          offsetDistance: 6,
          child: _buildPreparationGuidelinesCard(category),
        ),
        const SizedBox(height: 16),
        AppFadeSlide(
          duration: const Duration(milliseconds: 380),
          offsetDistance: 6,
          child: _buildEnvironmentalImpactCard(category),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // =========================================================================
  // TABLET TWO-COLUMN LAYOUT
  // =========================================================================
  Widget _buildTabletLayout(
      BuildContext context, WasteCategoryItem category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(category),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAcceptedItemsCard(category)),
            const SizedBox(width: 16),
            Expanded(child: _buildRejectedItemsCard(category)),
          ],
        ),
        const SizedBox(height: 20),
        _buildPreparationGuidelinesCard(category),
        const SizedBox(height: 20),
        _buildEnvironmentalImpactCard(category),
        const SizedBox(height: 24),
        _buildScheduleActionBanner(context, category),
      ],
    );
  }

  // =========================================================================
  // DESKTOP MULTI-COLUMN LAYOUT
  // =========================================================================
  Widget _buildDesktopLayout(
      BuildContext context, WasteCategoryItem category) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (flex: 3): Hero, Accepted, Prohibited, Preparation
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(category),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAcceptedItemsCard(category)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildRejectedItemsCard(category)),
                ],
              ),
              const SizedBox(height: 24),
              _buildPreparationGuidelinesCard(category),
            ],
          ),
        ),
        const SizedBox(width: 28),

        // Right Column (flex: 2): Sticky Action & Eco Impact
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDesktopActionCard(context, category),
              const SizedBox(height: 24),
              _buildEnvironmentalImpactCard(category),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SHARED CONTENT WIDGETS
  // =========================================================================
  Widget _buildHeroBanner(WasteCategoryItem category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showBadge = constraints.maxWidth >= 330;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: category.color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Eco Color Accent Strip
                Container(
                  height: 4,
                  color: category.color,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: category.color.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(category.icon, color: category.color, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    category.name,
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Recyclable',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: category.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showBadge) ...[
                        const SizedBox(width: 12),
                        CategoryIllustration(
                          categoryName: category.name,
                          categoryColor: category.color,
                          size: 42,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcceptedItemsCard(WasteCategoryItem category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.borderLight,
          width: 1.0,
        ),
      ),
      color: AppColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompleted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusCompleted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Accepted Materials',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...category.acceptedItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.statusCompleted.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.statusCompleted,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedItemsCard(WasteCategoryItem category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.borderLight,
          width: 1.0,
        ),
      ),
      color: AppColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.statusCancelled.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.statusCancelled,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Not Accepted / Prohibited',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...category.rejectedItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.statusCancelled.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.statusCancelled,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationGuidelinesCard(WasteCategoryItem category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Preparation & Sorting Instructions',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...category.preparationTips.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(WasteCategoryItem category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      color: AppColors.primaryContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Community Impact Note',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Properly sorting ${category.name.toLowerCase()} ensures 100% of collected batches are recycled into new raw materials rather than discarded in regional landfills.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActionCard(
      BuildContext context, WasteCategoryItem category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Collection',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to recycle your ${category.name.toLowerCase()}? Book a free doorstep pickup with our community team.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Schedule ${category.name} Pickup',
              icon: Icons.calendar_month_rounded,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.schedule,
                  arguments: category.name,
                );
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Back to Category Guide',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleActionBanner(
      BuildContext context, WasteCategoryItem category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to recycle ${category.name}?',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Book a quick doorstep collection in under 1 minute.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          PrimaryButton(
            text: 'Schedule Pickup',
            icon: Icons.calendar_month_rounded,
            width: 200,
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.schedule,
                arguments: category.name,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar(
      BuildContext context, WasteCategoryItem category) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: PrimaryButton(
        text: 'Schedule ${category.name} Pickup',
        icon: Icons.calendar_month_rounded,
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.schedule,
            arguments: category.name,
          );
        },
      ),
    );
  }
}

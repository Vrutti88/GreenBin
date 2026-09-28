import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_chip.dart';

/// Screen displaying the final confirmation of a scheduled recyclable waste pickup.
class PickupConfirmationScreen extends StatelessWidget {
  final PickupModel? pickup;

  const PickupConfirmationScreen({super.key, this.pickup});

  PickupModel _getEffectivePickup(BuildContext context) {
    if (pickup != null) return pickup!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PickupModel) return args;

    // Fallback sample pickup for direct routes or testing
    return PickupModel(
      id: 'GB-94821',
      userId: 'resident-demo-user',
      residentName: 'Green Resident',
      residentPhone: '+1 (555) 019-2834',
      category: 'Plastic',
      subCategories: const [
        'Beverage bottles (PET)',
        'Milk & detergent jugs (HDPE)',
      ],
      pickupDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '10:00 AM - 12:00 PM',
      street: '742 Evergreen Terrace',
      city: 'Springfield Eco District',
      landmark: 'Near Central Community Park',
      postalCode: '97477',
      notes: 'Bags placed near side gate for easy collection.',
      status: PickupStatus.confirmed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _copyPickupIdToClipboard(BuildContext context, String pickupId) {
    Clipboard.setData(ClipboardData(text: pickupId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pickup ID #$pickupId copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePickup = _getEffectivePickup(context);
    final categoryItem = WasteCategoryItem.findByNameOrId(effectivePickup.category);
    final categoryColor = categoryItem?.color ?? AppColors.primary;
    final categoryIcon = categoryItem?.icon ?? Icons.recycling_rounded;
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(effectivePickup.pickupDate);
    final displayId = effectivePickup.id.isNotEmpty
        ? effectivePickup.id
        : 'GB-94821';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Pickup Confirmation'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close to Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContainer(
              maxWidth: AppBreakpoints.maxContentWidth,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  if (width >= 1000) {
                    return _buildDesktopLayout(
                      context,
                      effectivePickup,
                      displayId,
                      categoryColor,
                      categoryIcon,
                      formattedDate,
                    );
                  } else if (width >= 700) {
                    return _buildTabletLayout(
                      context,
                      effectivePickup,
                      displayId,
                      categoryColor,
                      categoryIcon,
                      formattedDate,
                    );
                  } else {
                    return _buildMobileLayout(
                      context,
                      effectivePickup,
                      displayId,
                      categoryColor,
                      categoryIcon,
                      formattedDate,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE LAYOUT (< 700px): Single-Column Summary with Full-Width CTAs
  // ===========================================================================
  Widget _buildMobileLayout(
    BuildContext context,
    PickupModel pickup,
    String displayId,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        _buildSuccessHero(),
        const SizedBox(height: 20),
        _buildReferenceAndStatusCard(context, pickup, displayId),
        const SizedBox(height: 16),
        _buildPickupSummaryCard(
          pickup,
          categoryColor,
          categoryIcon,
          formattedDate,
        ),
        const SizedBox(height: 16),
        _buildNextStepsCard(),
        const SizedBox(height: 28),
        PrimaryButton(
          text: 'View My Pickups',
          icon: Icons.list_alt_rounded,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.pickups,
              (route) => route.isFirst,
            );
          },
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: 'Back to Home',
          icon: Icons.home_rounded,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ===========================================================================
  // TABLET LAYOUT (700px - 999px): Centered Constrained Two-Column Summary
  // ===========================================================================
  Widget _buildTabletLayout(
    BuildContext context,
    PickupModel pickup,
    String displayId,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            _buildSuccessHero(),
            const SizedBox(height: 24),
            _buildReferenceAndStatusCard(context, pickup, displayId),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPickupSummaryCard(
                    pickup,
                    categoryColor,
                    categoryIcon,
                    formattedDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNextStepsCard(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Back to Home',
                    icon: Icons.home_rounded,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'View My Pickups',
                    icon: Icons.list_alt_rounded,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.pickups,
                        (route) => route.isFirst,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP LAYOUT (>= 1000px): Centered Elevated Card (Not stretched)
  // ===========================================================================
  Widget _buildDesktopLayout(
    BuildContext context,
    PickupModel pickup,
    String displayId,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSuccessHero(),
              const SizedBox(height: 28),
              _buildReferenceAndStatusCard(context, pickup, displayId),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildPickupSummaryCard(
                      pickup,
                      categoryColor,
                      categoryIcon,
                      formattedDate,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 5,
                    child: _buildNextStepsCard(),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const Divider(color: AppColors.dividerLight),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    text: 'Back to Home',
                    icon: Icons.home_rounded,
                    isFullWidth: false,
                    width: 200,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  PrimaryButton(
                    text: 'View My Pickups',
                    icon: Icons.list_alt_rounded,
                    isFullWidth: false,
                    width: 240,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.pickups,
                        (route) => route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO & CONFIRMATION CARDS
  // ===========================================================================

  Widget _buildSuccessHero() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onPrimary,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Pickup Confirmed!',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your recyclable collection request has been saved and queued for community collection.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReferenceAndStatusCard(
    BuildContext context,
    PickupModel pickup,
    String displayId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tag_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup ID',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyPickupIdToClipboard(context, displayId),
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '#$displayId',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(status: pickup.status),
        ],
      ),
    );
  }

  Widget _buildPickupSummaryCard(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Collection Details',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          // Category Row
          _buildItemRow(
            icon: categoryIcon,
            iconColor: categoryColor,
            label: 'Waste Category',
            value: pickup.category,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Date Row
          _buildItemRow(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.primary,
            label: 'Pickup Date',
            value: formattedDate,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Time Row
          _buildItemRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.secondary,
            label: 'Time Window',
            value: pickup.timeSlot,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Address Row
          _buildItemRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.textSecondary,
            label: 'Collection Address',
            value: pickup.fullAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Helpful Reminders',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTipBullet(
            '1',
            'Place cleaned, sorted recyclables in a bin or bag by the start of the window.',
          ),
          const SizedBox(height: 10),
          _buildTipBullet(
            '2',
            'Keep items dry and away from rain or damp areas.',
          ),
          const SizedBox(height: 10),
          _buildTipBullet(
            '3',
            'Our collection crew will verify weights and update status in real-time.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipBullet(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

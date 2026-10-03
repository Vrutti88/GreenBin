import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_chip.dart';

/// Screen allowing the resident to review all recyclable pickup details
/// before confirming and dispatching to Cloud Firestore.
class ReviewPickupScreen extends StatefulWidget {
  final PickupModel? pickup;

  const ReviewPickupScreen({super.key, this.pickup});

  @override
  State<ReviewPickupScreen> createState() => _ReviewPickupScreenState();
}

class _ReviewPickupScreenState extends State<ReviewPickupScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _errorMessage;

  PickupModel? _getEffectivePickup(BuildContext context) {
    if (widget.pickup != null) return widget.pickup;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PickupModel) return args;
    return null;
  }

  Widget _buildMissingPickupState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pickup Details to Review',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please complete the pickup scheduling form before reviewing your collection request.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: PrimaryButton(
                text: 'Go to Schedule Pickup',
                icon: Icons.calendar_month_rounded,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.schedule);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirmPickup(PickupModel pickup) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ensure the pickup has empty ID so Firestore assigns a fresh document ID,
      // and guaranteed status = Scheduled
      final pickupToCreate = pickup.copyWith(
        id: '',
        status: PickupStatus.scheduled,
        updatedAt: DateTime.now(),
      );

      final pickupId = await _firestoreService.createPickup(pickupToCreate);

      final confirmedPickup = pickupToCreate.copyWith(
        id: pickupId,
        status: PickupStatus.scheduled,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.pickupConfirmation,
        arguments: confirmedPickup,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _getEffectivePickup(context);
    if (pickup == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Review Pickup'),
        ),
        body: SafeArea(child: _buildMissingPickupState(context)),
      );
    }

    final categoryItem = WasteCategoryItem.findByNameOrId(pickup.category);
    final categoryColor = categoryItem?.color ?? AppColors.primary;
    final categoryIcon = categoryItem?.icon ?? Icons.recycling_rounded;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(pickup.pickupDate);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Review Pickup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Edit Details',
        ),
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
                    pickup,
                    categoryColor,
                    categoryIcon,
                    formattedDate,
                  );
                } else if (width >= 700) {
                  return _buildTabletLayout(
                    pickup,
                    categoryColor,
                    categoryIcon,
                    formattedDate,
                  );
                } else {
                  return _buildMobileLayout(
                    pickup,
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
    );
  }

  // ===========================================================================
  // MOBILE LAYOUT (< 700px): Single-Column Summary & Full-Width CTA Buttons
  // ===========================================================================
  Widget _buildMobileLayout(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(_errorMessage!),
        ],
        const SizedBox(height: 16),
        _buildCategoryCard(pickup, categoryColor, categoryIcon),
        const SizedBox(height: 16),
        _buildScheduleCard(pickup, formattedDate),
        const SizedBox(height: 16),
        _buildLocationCard(pickup),
        const SizedBox(height: 16),
        _buildNotesCard(pickup),
        const SizedBox(height: 16),
        _buildEcoGuaranteeCard(),
        const SizedBox(height: 28),
        PrimaryButton(
          text: 'Confirm Pickup',
          icon: Icons.check_circle_outline_rounded,
          isLoading: _isLoading,
          onPressed: () => _handleConfirmPickup(pickup),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: 'Edit Details',
          icon: Icons.edit_note_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ===========================================================================
  // TABLET LAYOUT (700px - 999px): Centered Constrained Two-Column Information
  // ===========================================================================
  Widget _buildTabletLayout(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorBanner(_errorMessage!),
            ],
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Waste Category & Location
                Expanded(
                  child: Column(
                    children: [
                      _buildCategoryCard(pickup, categoryColor, categoryIcon),
                      const SizedBox(height: 16),
                      _buildLocationCard(pickup),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Column 2: Date & Time, Notes, Eco Guarantee
                Expanded(
                  child: Column(
                    children: [
                      _buildScheduleCard(pickup, formattedDate),
                      const SizedBox(height: 16),
                      _buildNotesCard(pickup),
                      const SizedBox(height: 16),
                      _buildEcoGuaranteeCard(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Edit Details',
                    icon: Icons.edit_note_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Confirm Pickup',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _isLoading,
                    onPressed: () => _handleConfirmPickup(pickup),
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
  // DESKTOP LAYOUT (>= 1000px): Centered Elevated Container with Balanced Grid
  // ===========================================================================
  Widget _buildDesktopLayout(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorBanner(_errorMessage!),
              ],
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Category & Notes
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryCard(pickup, categoryColor, categoryIcon),
                        const SizedBox(height: 16),
                        _buildNotesCard(pickup),
                        const SizedBox(height: 16),
                        _buildEcoGuaranteeCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column: Date, Time & Address
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScheduleCard(pickup, formattedDate),
                        const SizedBox(height: 16),
                        _buildLocationCard(pickup),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.dividerLight),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    text: 'Edit Details',
                    icon: Icons.edit_note_rounded,
                    isFullWidth: false,
                    width: 180,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  PrimaryButton(
                    text: 'Confirm Pickup',
                    icon: Icons.check_circle_outline_rounded,
                    isFullWidth: false,
                    width: 260,
                    isLoading: _isLoading,
                    onPressed: () => _handleConfirmPickup(pickup),
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
  // REUSABLE CARD COMPONENTS
  // ===========================================================================

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Pickup Request',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please confirm your waste category, schedule, and collection address before dispatching to the community recycling crew.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCancelledBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.statusCancelled.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.statusCancelled, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.statusCancelled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3.5,
              width: double.infinity,
              color: categoryColor,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Waste Category',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status: pickup.status, isCompact: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.category,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Free Community Collection',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pickup.subCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Accepted Items in Batch:',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pickup.subCategories.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ),
  ],
),
),
);
  }

  Widget _buildScheduleCard(PickupModel pickup, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule & Timing',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.primary,
            label: 'Pickup Date',
            value: formattedDate,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.access_time_filled_rounded,
            iconColor: AppColors.secondary,
            label: 'Preferred Time Slot',
            value: pickup.timeSlot,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PickupModel pickup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Address',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.street,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (pickup.landmark.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Near ${pickup.landmark}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${pickup.city}${pickup.postalCode.isNotEmpty ? ', ${pickup.postalCode}' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(PickupModel pickup) {
    final hasNotes = pickup.notes != null && pickup.notes!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2_rounded, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Notes & Special Instructions',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasNotes ? pickup.notes! : 'No additional instructions provided for the collection crew.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasNotes ? AppColors.textPrimary : AppColors.textMuted,
              fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoGuaranteeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.eco_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '100% Diverted from Landfills • Certified Community Recycling',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
                  fontWeight: FontWeight.w700,
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

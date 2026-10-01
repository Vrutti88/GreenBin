import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pickup_model.dart';
import '../../services/firestore_service.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_chip.dart';

/// Screen displaying the complete details and vertical status timeline
/// for a recyclable waste pickup, updated live from Cloud Firestore.
///
/// Responsive Behavior:
/// - MOBILE (< 700px): Single-column information with vertical status timeline.
/// - TABLET (700px - 999px): Centered constrained two-column layout.
/// - DESKTOP (>= 1000px): Centered maximum-width container with balanced 2-column layout.
/// - LANDSCAPE: Scrollable without vertical clipping or overflow.
class PickupDetailsScreen extends StatefulWidget {
  final PickupModel? initialPickup;
  final String? pickupId;
  final Stream<PickupModel?>? pickupStream;

  const PickupDetailsScreen({
    super.key,
    this.initialPickup,
    this.pickupId,
    this.pickupStream,
  });

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  final _firestoreService = FirestoreService();
  final _prefsService = PreferencesService();
  bool _isCancelling = false;
  bool _isSimulating = false;

  PickupStatus? _simulatedStatus;
  String? _simulatedAssignedTeam;

  PickupModel? _resolvedInitialPickup;
  String _resolvedPickupId = '';

  @override
  void initState() {
    super.initState();
    _resolvedInitialPickup = widget.initialPickup;
    _resolvedPickupId = widget.initialPickup?.id ?? widget.pickupId ?? '';
    if (_resolvedPickupId.isNotEmpty) {
      _firestoreService.checkAndAdvanceSinglePickup(_resolvedPickupId);
    }
  }

  Future<void> _simulateCrewEnRoute(PickupModel pickup) async {
    if (_isSimulating) return;
    setState(() {
      _isSimulating = true;
      _simulatedStatus = PickupStatus.inTransit;
      _simulatedAssignedTeam = 'North Eco Crew #4';
      _resolvedInitialPickup = (_resolvedInitialPickup ?? pickup).copyWith(
        status: PickupStatus.inTransit,
        assignedTeam: 'North Eco Crew #4',
        updatedAt: DateTime.now(),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Eco Crew #4 dispatched and en route to your address!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      await _firestoreService.updatePickupStatus(
        pickupId: pickup.id,
        status: PickupStatus.inTransit,
        assignedTeam: 'North Eco Crew #4',
      );
      await _prefsService.triggerFeedbackIfEnabled();
    } catch (_) {
      // Safe fallback
    } finally {
      if (mounted) {
        setState(() => _isSimulating = false);
      }
    }
  }

  Future<void> _simulateCompleteCollection(PickupModel pickup) async {
    if (_isSimulating) return;
    setState(() {
      _isSimulating = true;
      _simulatedStatus = PickupStatus.collected;
      _resolvedInitialPickup = (_resolvedInitialPickup ?? pickup).copyWith(
        status: PickupStatus.collected,
        updatedAt: DateTime.now(),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Collection completed! 4.5 kg diverted from landfill.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      await _firestoreService.markPickupCollected(pickup.id, weightKg: 4.5);
      await _prefsService.triggerFeedbackIfEnabled();
    } catch (_) {
      // Safe fallback
    } finally {
      if (mounted) {
        setState(() => _isSimulating = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedInitialPickup == null) {
      if (widget.initialPickup != null) {
        _resolvedInitialPickup = widget.initialPickup;
        _resolvedPickupId = widget.initialPickup!.id;
      } else {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is PickupModel) {
          _resolvedInitialPickup = args;
          _resolvedPickupId = args.id;
        } else if (args is String) {
          _resolvedPickupId = args;
        } else if (widget.pickupId != null) {
          _resolvedPickupId = widget.pickupId!;
        }
      }

      // Default sample fallback if no arguments supplied (e.g. testing)
      _resolvedInitialPickup ??= PickupModel(
        id: _resolvedPickupId.isNotEmpty ? _resolvedPickupId : 'GB-DEMO-2026',
        userId: 'current-user-demo',
        residentName: 'Community Resident',
        residentPhone: '+1 (555) 019-2834',
        category: 'Plastic',
        subCategories: const [
          'Beverage bottles (PET)',
          'Milk & detergent jugs (HDPE)',
        ],
        pickupDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '8:00 AM - 10:00 AM',
        street: '100 Green View Road',
        city: 'Springfield Eco Ward',
        landmark: 'Near Solar Park Gate',
        postalCode: '97477',
        notes: 'Please ring bell upon arrival.',
        status: PickupStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      );

      if (_resolvedPickupId.isEmpty) {
        _resolvedPickupId = _resolvedInitialPickup!.id;
      }
    }
  }

  Future<void> _handleCancelPickup(PickupModel pickup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Pickup?'),
        content: const Text(
          'Are you sure you want to cancel this recyclable collection request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Keep Scheduled'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCancelling = true;
      _simulatedStatus = PickupStatus.cancelled;
      _resolvedInitialPickup = (_resolvedInitialPickup ?? pickup).copyWith(
        status: PickupStatus.cancelled,
        updatedAt: DateTime.now(),
      );
    });

    try {
      await _firestoreService.cancelPickup(
        pickup.id,
        reason: 'Cancelled by resident via app',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup has been cancelled.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling pickup: $e'),
            backgroundColor: AppColors.statusCancelled,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.pickupStream ??
        (_resolvedPickupId.isNotEmpty
            ? _firestoreService.streamPickupById(_resolvedPickupId)
            : Stream.value(_resolvedInitialPickup));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pickup Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<PickupModel?>(
          stream: stream,
          initialData: _resolvedInitialPickup,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _resolvedInitialPickup == null) {
              return const LoadingState(
                message: 'Loading pickup details from Firestore...',
                size: 36,
              );
            }

            final rawPickup = snapshot.data ?? _resolvedInitialPickup;

            if (rawPickup == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'Pickup Not Found',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This collection request could not be located in Cloud Firestore.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        text: 'Back to My Pickups',
                        isFullWidth: false,
                        width: 200,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            }

            final pickup = _simulatedStatus != null
                ? rawPickup.copyWith(
                    status: _simulatedStatus,
                    assignedTeam:
                        _simulatedAssignedTeam ?? rawPickup.assignedTeam,
                  )
                : rawPickup;

            final categoryItem =
                WasteCategoryItem.findByNameOrId(pickup.category);
            final categoryColor = categoryItem?.color ?? AppColors.primary;
            final categoryIcon = categoryItem?.icon ?? Icons.recycling_rounded;
            final formattedDate =
                DateFormat('EEEE, MMMM d, yyyy').format(pickup.pickupDate);
            final formattedCreatedDate = DateFormat('MMM d, yyyy • h:mm a')
                .format(pickup.createdAt);

            return SingleChildScrollView(
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
                        formattedCreatedDate,
                      );
                    } else if (width >= 700) {
                      return _buildTabletLayout(
                        pickup,
                        categoryColor,
                        categoryIcon,
                        formattedDate,
                        formattedCreatedDate,
                      );
                    } else {
                      return _buildMobileLayout(
                        pickup,
                        categoryColor,
                        categoryIcon,
                        formattedDate,
                        formattedCreatedDate,
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // MOBILE LAYOUT (< 700px): Single-Column Info & Vertical Timeline
  // ===========================================================================
  Widget _buildMobileLayout(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
    String formattedCreatedDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderStatusCard(pickup),
        const SizedBox(height: 16),
        _buildCategoryCard(pickup, categoryColor, categoryIcon),
        const SizedBox(height: 16),
        _buildScheduleCard(pickup, formattedDate),
        const SizedBox(height: 16),
        _buildAddressCard(pickup),
        const SizedBox(height: 16),
        _buildNotesAndMetadataCard(pickup, formattedCreatedDate),
        const SizedBox(height: 16),
        _buildStatusTimelineCard(pickup),
        const SizedBox(height: 28),
        _buildActionButtons(pickup, isFullWidth: true),
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
    String formattedCreatedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderStatusCard(pickup),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Category, Schedule, Address & Notes
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildCategoryCard(pickup, categoryColor, categoryIcon),
                      const SizedBox(height: 16),
                      _buildScheduleCard(pickup, formattedDate),
                      const SizedBox(height: 16),
                      _buildAddressCard(pickup),
                      const SizedBox(height: 16),
                      _buildNotesAndMetadataCard(pickup, formattedCreatedDate),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                // Column 2: Live Status Timeline & Actions
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildStatusTimelineCard(pickup),
                      const SizedBox(height: 20),
                      _buildActionButtons(pickup, isFullWidth: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP LAYOUT (>= 1000px): Centered Max-Width Elevated Card Container
  // ===========================================================================
  Widget _buildDesktopLayout(
    PickupModel pickup,
    Color categoryColor,
    IconData categoryIcon,
    String formattedDate,
    String formattedCreatedDate,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
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
              _buildHeaderStatusCard(pickup),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Logistics, Location & Notes
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryCard(pickup, categoryColor, categoryIcon),
                        const SizedBox(height: 16),
                        _buildScheduleCard(pickup, formattedDate),
                        const SizedBox(height: 16),
                        _buildAddressCard(pickup),
                        const SizedBox(height: 16),
                        _buildNotesAndMetadataCard(pickup, formattedCreatedDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column: Vertical Status Timeline & Quick Actions
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusTimelineCard(pickup),
                        const SizedBox(height: 24),
                        _buildActionButtons(pickup, isFullWidth: false),
                      ],
                    ),
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
  // WIDGET COMPONENTS: HEADER, DETAILS CARDS, VERTICAL TIMELINE
  // ===========================================================================

  Widget _buildHeaderStatusCard(PickupModel pickup) {
    final displayId = pickup.id.isNotEmpty ? pickup.id : 'GB-PENDING';

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tag_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Reference',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '#$displayId',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
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
          Text(
            'Waste Category',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
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
            const Divider(height: 1, color: AppColors.dividerLight),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.primary),
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
            'Schedule & Window',
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
          const Divider(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.secondary,
            label: 'Time Slot',
            value: pickup.timeSlot,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(PickupModel pickup) {
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
            'Collection Address',
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

  Widget _buildNotesAndMetadataCard(
      PickupModel pickup, String formattedCreatedDate) {
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
              const Icon(Icons.sticky_note_2_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Notes for Collection Crew',
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
            hasNotes
                ? pickup.notes!
                : 'No special instructions provided by resident.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasNotes ? AppColors.textPrimary : AppColors.textMuted,
              fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Created on: ',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  formattedCreatedDate,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VERTICAL STATUS TIMELINE
  // ===========================================================================

  Widget _buildStatusTimelineCard(PickupModel pickup) {
    final status = pickup.status;
    final isCancelled = status == PickupStatus.cancelled;

    // Timeline state resolution
    final bool step1Done = true; // Request submitted
    final bool step2Done = !isCancelled &&
        (status == PickupStatus.scheduled ||
            status == PickupStatus.confirmed ||
            status == PickupStatus.inTransit ||
            status == PickupStatus.completed ||
            status == PickupStatus.collected);
    final bool step3Done = !isCancelled &&
        (status == PickupStatus.inTransit ||
            status == PickupStatus.completed ||
            status == PickupStatus.collected);
    final bool step4Done = !isCancelled &&
        (status == PickupStatus.completed || status == PickupStatus.collected);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timeline_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Collection Status Timeline',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Timeline Step 1: Request Created
          _buildTimelineItem(
            icon: Icons.check_circle_rounded,
            title: 'Request Created',
            subtitle: 'Pickup registered by resident in GreenBin',
            time: DateFormat('MMM d • h:mm a').format(pickup.createdAt),
            isCompleted: step1Done,
            isActive: !step2Done && !isCancelled,
            isLast: false,
          ),

          // Timeline Step 2: Scheduled & Confirmed
          _buildTimelineItem(
            icon: isCancelled
                ? Icons.cancel_rounded
                : (step2Done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded),
            title: isCancelled ? 'Request Cancelled' : 'Pickup Scheduled',
            subtitle: isCancelled
                ? 'Cancelled by resident or collection administrator'
                : 'Collection slot confirmed & queued for collection team',
            time: isCancelled
                ? 'Cancelled'
                : (step2Done ? 'Confirmed' : 'Pending Confirmation'),
            isCompleted: isCancelled || step2Done,
            isActive: !isCancelled && step2Done && !step3Done,
            isError: isCancelled,
            isLast: isCancelled,
          ),

          if (!isCancelled) ...[
            // Timeline Step 3: Crew En Route / In Transit
            _buildTimelineItem(
              icon: step3Done
                  ? Icons.check_circle_rounded
                  : (status == PickupStatus.inTransit
                      ? Icons.local_shipping_rounded
                      : Icons.radio_button_unchecked_rounded),
              title: 'Crew En Route',
              subtitle: pickup.assignedTeam != null &&
                      pickup.assignedTeam!.isNotEmpty
                  ? 'Assigned: ${pickup.assignedTeam}'
                  : 'Recycling vehicle dispatched during chosen window',
              time: status == PickupStatus.inTransit
                  ? 'In Transit'
                  : (step3Done ? 'Completed' : 'Upcoming'),
              isCompleted: step3Done,
              isActive: status == PickupStatus.inTransit,
              isLast: false,
            ),

            // Timeline Step 4: Waste Collected & Diverted
            _buildTimelineItem(
              icon: step4Done
                  ? Icons.verified_rounded
                  : Icons.radio_button_unchecked_rounded,
              title: 'Waste Collected',
              subtitle:
                  'Materials verified, weighed, and diverted from landfills',
              time: step4Done ? 'Collected' : 'Pending Collection',
              isCompleted: step4Done,
              isActive: step4Done,
              isLast: true,
            ),
          ],
          if (!isCancelled) ...[
            _buildSimulationControls(pickup),
          ],
        ],
      ),
    );
  }

  Widget _buildSimulationControls(PickupModel pickup) {
    if (pickup.status == PickupStatus.scheduled) {
      return Container(
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Collection Testing & Simulator',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Test the crew dispatch and collection stages in real time without waiting for the scheduled window.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      _isSimulating ? null : () => _simulateCrewEnRoute(pickup),
                  icon: const Icon(Icons.local_shipping_rounded, size: 16),
                  label: const Text('Dispatch Crew'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSimulating
                      ? null
                      : () => _simulateCompleteCollection(pickup),
                  icon: const Icon(Icons.verified_rounded, size: 16),
                  label: const Text('Complete Collection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (pickup.status == PickupStatus.inTransit) {
      return Container(
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Collection Crew is En Route',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Eco vehicle is currently travelling to your location. Confirm completion once collected.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSimulating
                  ? null
                  : () => _simulateCompleteCollection(pickup),
              icon: const Icon(Icons.verified_rounded, size: 16),
              label: const Text('Mark Materials Collected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (pickup.status.isCollected) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.statusConfirmedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.statusConfirmed.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded,
                color: AppColors.statusConfirmed, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Collection completed · Materials weighed & diverted from landfill.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    required bool isActive,
    bool isError = false,
    required bool isLast,
  }) {
    final Color nodeColor;
    if (isError) {
      nodeColor = AppColors.statusCancelled;
    } else if (isCompleted) {
      nodeColor = AppColors.primary;
    } else if (isActive) {
      nodeColor = AppColors.statusConfirmed;
    } else {
      nodeColor = AppColors.borderLight;
    }

    final Color iconColor = (isCompleted || isActive || isError)
        ? nodeColor
        : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator icon & vertical connector line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isError
                      ? AppColors.statusCancelledBg
                      : (isCompleted || isActive
                          ? AppColors.primaryContainer
                          : AppColors.surfaceVariantLight),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: nodeColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content Column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isError
                              ? AppColors.statusCancelled
                              : (isCompleted || isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isError
                              ? AppColors.statusCancelled
                              : (isCompleted
                                  ? AppColors.primary
                                  : AppColors.textMuted),
                          fontWeight:
                              isCompleted ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PickupModel pickup, {required bool isFullWidth}) {
    return Column(
      children: [
        if (pickup.status.isScheduled) ...[
          SecondaryButton(
            text: 'Cancel Pickup Request',
            icon: Icons.cancel_outlined,
            textColor: AppColors.statusCancelled,
            borderColor: AppColors.statusCancelled,
            isFullWidth: isFullWidth,
            isLoading: _isCancelling,
            onPressed: () => _handleCancelPickup(pickup),
          ),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          text: 'Close',
          icon: Icons.check_circle_outline_rounded,
          isFullWidth: isFullWidth,
          onPressed: () => Navigator.pop(context),
        ),
      ],
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

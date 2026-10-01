import 'package:flutter/material.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/pickup_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Screen displaying recyclable waste pickups scheduled and collected for
/// the authenticated community resident using Cloud Firestore.
///
/// Responsive Behavior:
/// - MOBILE (< 600px): Single-column scrollable ListView.
/// - TABLET (600px - 899px): Responsive 2-column grid.
/// - DESKTOP (900px - 1199px): Responsive 3-column grid.
/// - WIDE DESKTOP (>= 1200px): Responsive 4-column grid with constrained max card width.
class MyPickupsScreen extends StatefulWidget {
  final bool isEmbedded;
  final Stream<List<PickupModel>>? pickupsStream;
  final String? initialUserId;

  const MyPickupsScreen({
    super.key,
    this.isEmbedded = false,
    this.pickupsStream,
    this.initialUserId,
  });

  @override
  State<MyPickupsScreen> createState() => _MyPickupsScreenState();
}

class _MyPickupsScreenState extends State<MyPickupsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // 0: All, 1: Scheduled, 2: Collected, 3: Cancelled
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Scheduled', 'Collected', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    final uid = widget.initialUserId ?? _authService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      _firestoreService.autoAdvancePickupLifecycle(uid);
    }
  }

  List<PickupModel> _filterPickups(List<PickupModel> pickups) {
    switch (_selectedFilterIndex) {
      case 1: // Scheduled
        return pickups.where((p) => p.status.isScheduled).toList();
      case 2: // Collected
        return pickups.where((p) => p.status.isCollected).toList();
      case 3: // Cancelled
        return pickups.where((p) => p.status == PickupStatus.cancelled).toList();
      case 0: // All
      default:
        return pickups;
    }
  }

  void _showPickupDetails(PickupModel pickup) {
    Navigator.pushNamed(
      context,
      AppRoutes.pickupDetails,
      arguments: pickup,
    );
  }

  // ===========================================================================
  // AUTHENTICATION, LOADING, ERROR & EMPTY STATES
  // ===========================================================================

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign In to View Pickups',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please log in to your GreenBin account to view your scheduled and collected recycling requests.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: PrimaryButton(
                  text: 'Log In to GreenBin',
                  icon: Icons.login_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.statusCancelledBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 36,
                  color: AppColors.statusCancelled,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Pickups',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceFirst('Exception: ', ''),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: SecondaryButton(
                  text: 'Try Again',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MAIN BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final userId = widget.initialUserId ?? _authService.currentUser?.uid ?? '';

    // If user is unauthenticated and no custom mock stream is injected, prompt login
    if (userId.isEmpty && widget.pickupsStream == null) {
      return _wrapScaffold(
        context,
        _buildUnauthenticatedState(context),
      );
    }

    final pickupsStream = widget.pickupsStream ?? _firestoreService.streamUserPickups(userId);

    final content = ResponsiveContainer(
      maxWidth: AppBreakpoints.maxContentWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row: All, Scheduled, Collected, Cancelled
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilterIndex = index);
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Pickups List / Grid with Firestore Stream
          Expanded(
            child: StreamBuilder<List<PickupModel>>(
              stream: pickupsStream,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(
                    message: 'Loading your pickups from Cloud Firestore...',
                    size: 34,
                  );
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error!);
                }

                final allPickups = snapshot.data ?? [];
                final filtered = _filterPickups(allPickups);

                // 3. Empty State
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.recycling_rounded,
                    title: _selectedFilterIndex == 0
                        ? 'No pickups scheduled'
                        : 'No ${_filters[_selectedFilterIndex].toLowerCase()} pickups',
                    message: _selectedFilterIndex == 0
                        ? 'Schedule your first recyclable waste collection with the community crew.'
                        : 'You do not have any requests under ${_filters[_selectedFilterIndex].toLowerCase()}.',
                    actionText: 'Schedule a Pickup',
                    actionIcon: Icons.add_rounded,
                    onActionPressed: () {
                      Navigator.pushNamed(context, AppRoutes.schedule);
                    },
                  );
                }

                // 4. Responsive Grid/List using LayoutBuilder
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    // Number of columns adapts dynamically to available screen width
                    final int crossAxisCount;
                    if (width >= 1080) {
                      crossAxisCount = 4; // Wide desktop
                    } else if (width >= 800) {
                      crossAxisCount = 3; // Desktop
                    } else if (width >= 560) {
                      crossAxisCount = 2; // Tablet
                    } else {
                      crossAxisCount = 1; // Mobile single-column
                    }

                    // MOBILE: Single-column ListView
                    if (crossAxisCount == 1) {
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pickup = filtered[index];
                          return PickupCard(
                            pickup: pickup,
                            onTap: () => _showPickupDetails(pickup),
                          );
                        },
                      );
                    }

                    // TABLET & DESKTOP: Responsive multi-column GridView
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 185,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final pickup = filtered[index];
                        return PickupCard(
                          pickup: pickup,
                          onTap: () => _showPickupDetails(pickup),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    return _wrapScaffold(context, content);
  }

  Widget _wrapScaffold(BuildContext context, Widget body) {
    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pickups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Schedule Pickup',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.schedule);
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: body),
    );
  }
}

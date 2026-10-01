import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../models/pickup_model.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/adaptive_navigation.dart';
import '../../widgets/category_card.dart';
import '../../widgets/interactive_animations.dart';
import '../../widgets/pickup_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_illustration.dart';
import '../../widgets/status_chip.dart';
import '../guide/waste_guide_screen.dart';
import '../notifications/notifications_screen.dart';
import '../pickups/my_pickups_screen.dart';
import '../profile/help_faq_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../schedule/schedule_pickup_screen.dart';

/// Main Application Shell hosting adaptive navigation and the responsive Home Dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum HomeNavTab {
  home,
  guide,
  schedule,
  pickups,
  notifications,
  profile,
  settings,
  helpFaq,
}

class _HomeScreenState extends State<HomeScreen> {
  HomeNavTab _activeTab = HomeNavTab.home;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    final uid = _authService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      _firestoreService.autoAdvancePickupLifecycle(uid);
      _firestoreService.checkAndGenerateUpcomingReminders(uid);
      _firestoreService.checkAndGenerateMilestones(uid);
    }
  }

  static const List<AppNavDestination> _mobileNavDestinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Guide',
    ),
    AppNavDestination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Schedule',
    ),
    AppNavDestination(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping_rounded,
      label: 'Pickups',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const List<AppNavDestination> _tabletNavDestinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Guide',
    ),
    AppNavDestination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Schedule',
    ),
    AppNavDestination(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping_rounded,
      label: 'Pickups',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  List<AppNavDestination> _getDesktopNavDestinations(String? unreadBadgeText) => [
    const AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    const AppNavDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Waste Guide',
    ),
    const AppNavDestination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Schedule Pickup',
    ),
    const AppNavDestination(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping_rounded,
      label: 'My Pickups',
    ),
    AppNavDestination(
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      label: 'Notifications',
      badgeText: unreadBadgeText,
    ),
    const AppNavDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
    const AppNavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
    const AppNavDestination(
      icon: Icons.help_outline_rounded,
      selectedIcon: Icons.help_rounded,
      label: 'Help & FAQ',
    ),
    AppNavDestination(
      icon: Icons.logout_rounded,
      label: 'Logout',
      isDestructive: true,
      onTap: _showLogoutDialog,
    ),
  ];

  int get _mobileIndex {
    switch (_activeTab) {
      case HomeNavTab.home:
        return 0;
      case HomeNavTab.guide:
        return 1;
      case HomeNavTab.schedule:
        return 2;
      case HomeNavTab.pickups:
        return 3;
      case HomeNavTab.profile:
      case HomeNavTab.settings:
      case HomeNavTab.helpFaq:
      case HomeNavTab.notifications:
        return 4;
    }
  }

  int get _desktopIndex {
    switch (_activeTab) {
      case HomeNavTab.home:
        return 0;
      case HomeNavTab.guide:
        return 1;
      case HomeNavTab.schedule:
        return 2;
      case HomeNavTab.pickups:
        return 3;
      case HomeNavTab.notifications:
        return 4;
      case HomeNavTab.profile:
        return 5;
      case HomeNavTab.settings:
        return 6;
      case HomeNavTab.helpFaq:
        return 7;
    }
  }

  void _onDesktopSelect(int index) {
    switch (index) {
      case 0:
        setState(() => _activeTab = HomeNavTab.home);
        break;
      case 1:
        setState(() => _activeTab = HomeNavTab.guide);
        break;
      case 2:
        setState(() => _activeTab = HomeNavTab.schedule);
        break;
      case 3:
        setState(() => _activeTab = HomeNavTab.pickups);
        break;
      case 4:
        setState(() => _activeTab = HomeNavTab.notifications);
        break;
      case 5:
        setState(() => _activeTab = HomeNavTab.profile);
        break;
      case 6:
        setState(() => _activeTab = HomeNavTab.settings);
        break;
      case 7:
        setState(() => _activeTab = HomeNavTab.helpFaq);
        break;
      case 8:
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out of GreenBin'),
        content: const Text(
          'Are you sure you want to log out of your resident account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _authService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildTabletTrailing(int unreadCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Divider(indent: 14, endIndent: 14, height: 1),
        const SizedBox(height: 8),
        IconButton(
          icon: unreadCount > 0
              ? Badge(
                  label: Text('$unreadCount'),
                  backgroundColor: AppColors.statusPending,
                  child: const Icon(Icons.notifications_outlined),
                )
              : const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          color: _activeTab == HomeNavTab.notifications
              ? AppColors.primary
              : AppColors.textSecondary,
          onPressed: () {
            setState(() => _activeTab = HomeNavTab.notifications);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          color: _activeTab == HomeNavTab.settings
              ? AppColors.primary
              : AppColors.textSecondary,
          onPressed: () {
            setState(() => _activeTab = HomeNavTab.settings);
          },
        ),
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          tooltip: 'Help & FAQ',
          color: _activeTab == HomeNavTab.helpFaq
              ? AppColors.primary
              : AppColors.textSecondary,
          onPressed: () {
            setState(() => _activeTab = HomeNavTab.helpFaq);
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
          color: AppColors.error,
          onPressed: _showLogoutDialog,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';
    final notifsStream = userId.isNotEmpty
        ? _firestoreService.streamUserNotifications(userId)
        : const Stream<List<NotificationModel>>.empty();

    return StreamBuilder<List<NotificationModel>>(
      stream: notifsStream,
      builder: (context, notifsSnapshot) {
        final notifs = notifsSnapshot.data ?? const <NotificationModel>[];
        final unreadCount = notifs.where((n) => !n.isRead).length;
        final unreadBadgeText = unreadCount > 0 ? '$unreadCount' : null;

        return AdaptiveNavigationScaffold(
          currentIndex: _mobileIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                setState(() => _activeTab = HomeNavTab.home);
                break;
              case 1:
                setState(() => _activeTab = HomeNavTab.guide);
                break;
              case 2:
                setState(() => _activeTab = HomeNavTab.schedule);
                break;
              case 3:
                setState(() => _activeTab = HomeNavTab.pickups);
                break;
              case 4:
                setState(() => _activeTab = HomeNavTab.profile);
                break;
            }
          },
          destinations: _mobileNavDestinations,
          mobileDestinations: _mobileNavDestinations,
          tabletDestinations: _tabletNavDestinations,
          desktopDestinations: _getDesktopNavDestinations(unreadBadgeText),
          tabletSelectedIndex: _mobileIndex,
          onTabletDestinationSelected: (index) {
            switch (index) {
              case 0:
                setState(() => _activeTab = HomeNavTab.home);
                break;
              case 1:
                setState(() => _activeTab = HomeNavTab.guide);
                break;
              case 2:
                setState(() => _activeTab = HomeNavTab.schedule);
                break;
              case 3:
                setState(() => _activeTab = HomeNavTab.pickups);
                break;
              case 4:
                setState(() => _activeTab = HomeNavTab.profile);
                break;
            }
          },
          tabletTrailing: _buildTabletTrailing(unreadCount),
          desktopSelectedIndex: _desktopIndex,
          onDesktopDestinationSelected: _onDesktopSelect,
          title: _getTabTitle(_activeTab),
          leading: _activeTab != HomeNavTab.home
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back to Home',
                  onPressed: () => setState(() => _activeTab = HomeNavTab.home),
                )
              : null,
          actions: [
            // Real-time unread notifications counter
            IconButton(
              icon: unreadCount > 0
                  ? Badge(
                      label: Text('$unreadCount'),
                      backgroundColor: AppColors.statusPending,
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            const SizedBox(width: 8),
          ],
      floatingActionButton: _activeTab == HomeNavTab.home || _activeTab == HomeNavTab.pickups
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.schedule);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Schedule Pickup'),
            )
          : null,
      body: _buildCurrentTabBody(),
    );
      },
    );
  }

  String _getTabTitle(HomeNavTab tab) {
    switch (tab) {
      case HomeNavTab.home:
        return 'GreenBin Dashboard';
      case HomeNavTab.guide:
        return 'Waste Category Guide';
      case HomeNavTab.schedule:
        return 'Schedule Waste Pickup';
      case HomeNavTab.pickups:
        return 'My Pickups';
      case HomeNavTab.notifications:
        return 'Notifications';
      case HomeNavTab.profile:
        return 'Resident Profile';
      case HomeNavTab.settings:
        return 'Settings';
      case HomeNavTab.helpFaq:
        return 'Help & FAQ';
    }
  }

  Widget _buildCurrentTabBody() {
    switch (_activeTab) {
      case HomeNavTab.home:
        return _buildDashboardContent();
      case HomeNavTab.guide:
        return const WasteGuideScreen(isEmbedded: true);
      case HomeNavTab.schedule:
        return const SchedulePickupScreen(isEmbedded: true);
      case HomeNavTab.pickups:
        return const MyPickupsScreen(isEmbedded: true);
      case HomeNavTab.notifications:
        return const NotificationsScreen(isEmbedded: true);
      case HomeNavTab.profile:
        return const ProfileScreen(isEmbedded: true);
      case HomeNavTab.settings:
        return const SettingsScreen(isEmbedded: true);
      case HomeNavTab.helpFaq:
        return const HelpFaqScreen(isEmbedded: true);
    }
  }

  Widget _buildDashboardContent() {
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';

    return StreamBuilder<UserModel?>(
      stream: userId.isNotEmpty
          ? _firestoreService.streamUserProfile(userId)
          : const Stream.empty(),
      builder: (context, userSnapshot) {
        final userModel = userSnapshot.data;
        final displayName = userModel?.fullName.isNotEmpty == true
            ? userModel!.fullName
            : (user?.displayName ?? 'Community Resident');

        return StreamBuilder<List<PickupModel>>(
          stream: userId.isNotEmpty
              ? _firestoreService.streamUserPickups(userId)
              : const Stream.empty(),
          builder: (context, pickupsSnapshot) {
            final allPickups = pickupsSnapshot.data ?? [];

            // Filter upcoming pickups (scheduled, pending, confirmed, in transit)
            final upcomingPickups = allPickups
                .where((p) => p.status.isScheduled)
                .toList()
              ..sort((a, b) => a.pickupDate.compareTo(b.pickupDate));

            // Filter completed pickups (collected, completed)
            final completedPickups = allPickups
                .where((p) => p.status.isCollected)
                .toList()
              ..sort((a, b) => b.pickupDate.compareTo(a.pickupDate));

            final double divertedKg = (userModel?.kgRecycled ?? 0.0) > 0
                ? userModel!.kgRecycled
                : completedPickups.length * 4.5;

            final int totalPickupsCount = (userModel?.totalPickups ?? 0) > 0
                ? userModel!.totalPickups
                : allPickups.length;

            return SingleChildScrollView(
              child: ResponsiveContainer(
                maxWidth: AppBreakpoints.maxContentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Greeting & Profile Header
                    AppFadeSlide(
                      delay: Duration.zero,
                      child: _buildHeaderStats(displayName, userModel),
                    ),
                    const SizedBox(height: 20),

                    // 2. Schedule Pickup Hero CTA Banner
                    AppFadeSlide(
                      delay: const Duration(milliseconds: 60),
                      child: _buildScheduleHeroCard(),
                    ),
                    const SizedBox(height: 24),

                    // 3. Recycling Statistics (4 Metrics Responsive Grid)
                    AppFadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: _buildRecyclingStatistics(
                        totalPickups: totalPickupsCount,
                        divertedKg: divertedKg,
                        activePickups: upcomingPickups.length,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Responsive Content Layout (Categories, Upcoming, Recent)
                    AppFadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: ResponsiveBuilder(
                      builder: (context, constraints, deviceType) {
                        final isDesktop = deviceType == DeviceScreenType.desktop ||
                            context.screenWidth >= 1000;
                        final isLandscape =
                            MediaQuery.orientationOf(context) == Orientation.landscape;
                        final isMultiColumn = isDesktop ||
                            (isLandscape && constraints.maxWidth >= 600) ||
                            constraints.maxWidth >= 850;

                        if (isMultiColumn) {
                          // ==========================================
                          // DESKTOP & WIDE LANDSCAPE: Multi-Column Area
                          // Left: Category Shortcuts + Recent Pickups
                          // Right: Upcoming Pickup Spotlight + Eco Impact
                          // ==========================================
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCategoriesSection(deviceType),
                                    const SizedBox(height: 32),
                                    _buildRecentPickupsSection(completedPickups),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildUpcomingPickupSpotlight(upcomingPickups),
                                    const SizedBox(height: 24),
                                    _buildCommunityImpactCard(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else if (deviceType == DeviceScreenType.tablet) {
                          // ==========================================
                          // TABLET PORTRAIT: Two-Column Sections
                          // ==========================================
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUpcomingPickupSpotlight(upcomingPickups),
                              const SizedBox(height: 32),
                              _buildCategoriesSection(deviceType),
                              const SizedBox(height: 32),
                              _buildRecentPickupsSection(completedPickups),
                            ],
                          );
                        } else {
                          // ==========================================
                          // MOBILE: Single-Column Dashboard
                          // ==========================================
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUpcomingPickupSpotlight(upcomingPickups),
                              const SizedBox(height: 28),
                              _buildCategoriesSection(deviceType),
                              const SizedBox(height: 28),
                              _buildRecentPickupsSection(completedPickups),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 1. GREETING & PROFILE ACCESS HEADER
  // =========================================================================
  Widget _buildHeaderStats(String name, UserModel? user) {
    final greeting = _getTimeGreeting();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    final address = user?.street.isNotEmpty == true
        ? '${user!.street}, ${user.city.isNotEmpty ? user.city : "Oakridge"}'
        : 'Oakridge Ward • GreenBin Community';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $name 👋',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: AppTextStyles.bodySmall.copyWith(
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
        ),
        const SizedBox(width: 12),
        // Resident Avatar Icon Button
        InkWell(
          onTap: () => setState(() => _activeTab = HomeNavTab.profile),
          borderRadius: BorderRadius.circular(24),
          child: Tooltip(
            message: 'Resident Profile',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. SCHEDULE PICKUP CTA HERO BANNER
  // =========================================================================
  Widget _buildScheduleHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final showSideFeatures = constraints.maxWidth >= 780;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flash_on_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Doorstep Pickup',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Schedule Recyclable Pickup',
                      style: (isMobile
                              ? AppTextStyles.headlineMedium
                              : AppTextStyles.headlineLarge)
                          .copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select waste categories, choose your preferred date and time slot. Our community crew collects directly from your doorstep.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      text: 'Schedule Pickup Now',
                      icon: Icons.calendar_month_rounded,
                      width: isMobile ? double.infinity : 240,
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.schedule);
                      },
                    ),
                  ],
                ),
              ),
              if (showSideFeatures) ...[
                const SizedBox(width: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeroFeatureRow(
                          Icons.check_circle_rounded,
                          'Free Service',
                        ),
                        const SizedBox(height: 8),
                        _buildHeroFeatureRow(
                          Icons.access_time_rounded,
                          'Mon-Sat: 8AM-6PM',
                        ),
                        const SizedBox(height: 8),
                        _buildHeroFeatureRow(
                          Icons.eco_rounded,
                          '100% Recycled',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. RECYCLING STATISTICS (4 METRICS RESPONSIVE GRID)
  // =========================================================================
  Widget _buildRecyclingStatistics({
    required int totalPickups,
    double? divertedKg,
    required int activePickups,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns;
        final double aspectRatio;

        final bool showSubtitle = width >= 340;

        if (width >= 800) {
          columns = 3;
          aspectRatio = 1.4;
        } else if (width >= 650) {
          columns = 3;
          aspectRatio = 1.2;
        } else if (width >= 360) {
          columns = 2;
          aspectRatio = 1.25;
        } else if (width >= 250) {
          columns = 2;
          aspectRatio = 0.95;
        } else {
          columns = 2;
          aspectRatio = 0.85;
        }

        final zeroWasteLevel = (totalPickups ~/ 3) + 1;
        final zeroWasteRank = totalPickups >= 10
            ? 'Eco Master'
            : totalPickups >= 5
                ? 'Eco Champion'
                : 'Eco Explorer';

        final nextPickupMilestone = ((totalPickups ~/ 5) + 1) * 5;
        final pickupsInLevel = totalPickups % 3;
        final pickupsNeeded = 3 - pickupsInLevel;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            _buildStatCard(
              icon: Icons.local_shipping_rounded,
              label: 'Total Pickups',
              value: '$totalPickups',
              subtitle: 'Doorstep requests',
              badgeText: 'Lifetime',
              progressLabel: 'Goal: $nextPickupMilestone',
              showSubtitle: showSubtitle,
              color: AppColors.primary,
              illustrationType: StatIllustrationType.pickups,
              watermarkIcon: Icons.local_shipping_rounded,
              onTap: () => setState(() => _activeTab = HomeNavTab.pickups),
            ),
            _buildStatCard(
              icon: Icons.pending_actions_rounded,
              label: 'Active Pickups',
              value: '$activePickups',
              subtitle: activePickups == 0 ? 'All collected' : 'In transit / pending',
              badgeText: activePickups == 0 ? 'All Clear' : 'In Progress',
              progressLabel: activePickups == 0 ? 'On schedule' : '$activePickups active',
              showSubtitle: showSubtitle,
              color: AppColors.statusPending,
              illustrationType: StatIllustrationType.activePickups,
              watermarkIcon: Icons.schedule_rounded,
              onTap: () => setState(() => _activeTab = HomeNavTab.pickups),
            ),
            _buildStatCard(
              icon: Icons.energy_savings_leaf_rounded,
              label: 'Zero-Waste Rank',
              value: 'Level $zeroWasteLevel',
              subtitle: zeroWasteRank,
              badgeText: zeroWasteRank,
              progressLabel: '$pickupsNeeded to Lvl ${zeroWasteLevel + 1}',
              showSubtitle: showSubtitle,
              color: AppColors.tertiary,
              illustrationType: StatIllustrationType.zeroWasteRank,
              watermarkIcon: Icons.military_tech_rounded,
              onTap: () => setState(() => _activeTab = HomeNavTab.profile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required StatIllustrationType illustrationType,
    required IconData watermarkIcon,
    required String badgeText,
    required String progressLabel,
    VoidCallback? onTap,
    bool showSubtitle = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        final bool showBadge = cardWidth >= 165;
        final double illustrationSize = cardWidth < 140
            ? 30.0
            : (cardWidth < 180 ? 34.0 : 40.0);

        return InteractiveBounce(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Eco Accent Strip
                  Container(
                    height: 3.5,
                    width: double.infinity,
                    color: color,
                  ),

                  // Card Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardWidth < 140 ? 8 : 10,
                        vertical: cardHeight < 130 ? 6 : 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Row: StatIllustration on left & Contextual Status Badge on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              StatIllustration(
                                type: illustrationType,
                                size: illustrationSize,
                              ),
                              if (showBadge)
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.09),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.22),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            badgeText,
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Middle: Prominent Hero Metric & Category Label
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  value,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                    fontSize: cardWidth < 130 ? 18 : 22,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                label,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Bottom: Subtitle & Status Detail Row (without progress bar line)
                          if (showSubtitle)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subtitle,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    progressLabel,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // 4. UPCOMING PICKUP SPOTLIGHT SECTION
  // =========================================================================
  Widget _buildUpcomingPickupSpotlight(List<PickupModel> upcomingPickups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Pickup',
          actionText: upcomingPickups.isNotEmpty ? 'View All' : null,
          onActionTap: upcomingPickups.isNotEmpty
              ? () => setState(() => _activeTab = HomeNavTab.pickups)
              : null,
        ),
        const SizedBox(height: 12),
        if (upcomingPickups.isEmpty)
          _buildEmptyUpcomingCard()
        else
          _buildSpotlightCard(upcomingPickups.first, upcomingPickups.length),
      ],
    );
  }

  Widget _buildSpotlightCard(PickupModel pickup, int totalUpcoming) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(pickup.pickupDate);

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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
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
            // Top Row: Category + Status Chip
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.category,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pickup.subCategories.isNotEmpty
                            ? pickup.subCategories.join(', ')
                            : 'Scheduled Recyclable Pickup',
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
                StatusChip(status: pickup.status),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Date & Time Window Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pickup.timeSlot,
                                style: AppTextStyles.bodySmall.copyWith(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pickup Address
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
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showPickupDetailsModal(context, pickup),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (totalUpcoming > 1)
                  TextButton(
                    onPressed: () => setState(() => _activeTab = HomeNavTab.pickups),
                    child: Text(
                      '+${totalUpcoming - 1} more scheduled',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
),
);
  }

  Widget _buildEmptyUpcomingCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No pickups scheduled',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Got recyclable items ready? Book a free doorstep pickup.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Schedule a Pickup',
              icon: Icons.add_rounded,
              height: 44,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.schedule);
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. WASTE CATEGORY SHORTCUTS SECTION
  // =========================================================================
  Widget _buildCategoriesSection(DeviceScreenType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recycling Categories',
          actionText: 'View Guide',
          onActionTap: () => setState(() => _activeTab = HomeNavTab.guide),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int crossAxisCount;
            final double childAspectRatio;
            final bool isCompact = width < 450;

            if (width >= 600) {
              crossAxisCount = 3;
              childAspectRatio = 1.25;
            } else if (width >= 400) {
              crossAxisCount = 2;
              childAspectRatio = 1.25;
            } else {
              crossAxisCount = 2;
              childAspectRatio = 1.05;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: WasteCategoryItem.defaultCategories.length,
              itemBuilder: (context, index) {
                final category = WasteCategoryItem.defaultCategories[index];
                return CategoryCard(
                  category: category,
                  isCompact: isCompact,
                  onTap: () {
                    // Direct shortcut into Schedule Pickup with category pre-selected
                    Navigator.pushNamed(
                      context,
                      AppRoutes.schedule,
                      arguments: category.name,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  // =========================================================================
  // 6. RECENT PICKUPS SECTION
  // =========================================================================
  Widget _buildRecentPickupsSection(List<PickupModel> completedPickups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Pickups',
          actionText: completedPickups.isNotEmpty ? 'View History' : null,
          onActionTap: completedPickups.isNotEmpty
              ? () => setState(() => _activeTab = HomeNavTab.pickups)
              : null,
        ),
        const SizedBox(height: 12),
        if (completedPickups.isEmpty)
          _buildEmptyRecentCard()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedPickups.take(3).length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pickup = completedPickups[index];
              return PickupCard(
                pickup: pickup,
                onTap: () => _showPickupDetailsModal(context, pickup),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyRecentCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.secondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No completed pickups yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your collection history and diverted landfill kg will appear here.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 7. COMMUNITY IMPACT & TIPS CARD (DESKTOP / WIDE SCREEN COMPANION)
  // =========================================================================
  Widget _buildCommunityImpactCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3.5,
              width: double.infinity,
              color: AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Eco Impact',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Oakridge Ward Zero-Waste Drive',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '1,240+ kg diverted this month!',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Our community has prevented ~3.8 metric tons of CO2 emissions this month through prompt recycling.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.tertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Rinsing containers prevents pests and improves recycling quality.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => setState(() => _activeTab = HomeNavTab.guide),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('Read Recycling Guide'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
  }

  // =========================================================================
  // 8. PICKUP DETAILS BOTTOM SHEET MODAL
  // =========================================================================
  void _showPickupDetailsModal(BuildContext context, PickupModel pickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pickup Details',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StatusChip(status: pickup.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.recycling_rounded,
                    label: 'Waste Category',
                    value: pickup.category,
                  ),
                  if (pickup.subCategories.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.checklist_rounded,
                      label: 'Specified Items',
                      value: pickup.subCategories.join(', '),
                    ),
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Scheduled Date',
                    value:
                        DateFormat('EEE, MMM d, yyyy').format(pickup.pickupDate),
                  ),
                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time Window',
                    value: pickup.timeSlot,
                  ),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Pickup Address',
                    value: pickup.fullAddress,
                  ),
                  if (pickup.notes != null && pickup.notes!.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Notes for Crew',
                      value: pickup.notes!,
                    ),
                  if (pickup.assignedTeam != null)
                    _buildDetailRow(
                      icon: Icons.group_outlined,
                      label: 'Assigned Crew',
                      value: pickup.assignedTeam!,
                    ),
                  const SizedBox(height: 24),
                  if (pickup.status == PickupStatus.pending)
                    SecondaryButton(
                      text: 'Cancel Pickup Request',
                      textColor: AppColors.statusCancelled,
                      borderColor: AppColors.statusCancelled,
                      onPressed: () async {
                        Navigator.pop(context);
                        await _firestoreService.cancelPickup(
                          pickup.id,
                          reason: 'Cancelled by resident',
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Pickup request cancelled.'),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
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
      ),
    );
  }
}

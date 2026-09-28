import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_utils.dart';

/// Navigation destination data holder for adaptive navigation.
class AppNavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? badgeText;
  final VoidCallback? onTap;
  final bool isDestructive;

  const AppNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeText,
    this.onTap,
    this.isDestructive = false,
  });
}

/// Adaptive scaffold switching seamlessly between:
/// - Mobile portrait: NavigationBar (Bottom navigation)
/// - Mobile landscape / Tablet: Compact, scrollable NavigationRail (prevents overflow)
/// - Desktop: Extended permanent Sidebar navigation
class AdaptiveNavigationScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;
  final List<AppNavDestination>? mobileDestinations;
  final List<AppNavDestination>? tabletDestinations;
  final List<AppNavDestination>? desktopDestinations;
  final int? tabletSelectedIndex;
  final ValueChanged<int>? onTabletDestinationSelected;
  final int? desktopSelectedIndex;
  final ValueChanged<int>? onDesktopDestinationSelected;
  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? tabletLeading;
  final Widget? tabletTrailing;
  final VoidCallback? onLogout;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.mobileDestinations,
    this.tabletDestinations,
    this.desktopDestinations,
    this.tabletSelectedIndex,
    this.onTabletDestinationSelected,
    this.desktopSelectedIndex,
    this.onDesktopDestinationSelected,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.tabletLeading,
    this.tabletTrailing,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        // Landscape check on smaller heights: switch to Rail to conserve vertical space
        final isCompactHeight = MediaQuery.sizeOf(context).height < 500;
        final isDesktop = deviceType == DeviceScreenType.desktop;
        final shouldUseRail = (deviceType != DeviceScreenType.mobile && !isDesktop) || isCompactHeight;

        if (!shouldUseRail && !isDesktop) {
          // ==========================================
          // MOBILE PORTRAIT: Bottom Navigation Bar
          // ==========================================
          final effectiveDests = mobileDestinations ?? destinations;
          final safeIndex = currentIndex.clamp(0, effectiveDests.length - 1);

          return Scaffold(
            appBar: title != null
                ? AppBar(
                    title: Text(title!),
                    leading: leading,
                    actions: actions,
                  )
                : null,
            body: SafeArea(child: body),
            bottomNavigationBar: NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: (idx) {
                final dest = effectiveDests[idx];
                if (dest.onTap != null) {
                  dest.onTap!();
                } else {
                  onDestinationSelected(idx);
                }
              },
              destinations: effectiveDests.map((d) {
                return NavigationDestination(
                  icon: d.badgeText != null
                      ? Badge(
                          label: Text(d.badgeText!),
                          backgroundColor: AppColors.statusPending,
                          child: Icon(d.icon),
                        )
                      : Icon(d.icon),
                  selectedIcon: d.badgeText != null
                      ? Badge(
                          label: Text(d.badgeText!),
                          backgroundColor: AppColors.statusPending,
                          child: Icon(d.selectedIcon ?? d.icon),
                        )
                      : Icon(d.selectedIcon ?? d.icon),
                  label: d.label,
                );
              }).toList(),
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        // ==========================================
        // TABLET & DESKTOP: Navigation Rail / Sidebar
        // ==========================================
        return Scaffold(
          body: Row(
            children: [
              // Left Navigation Element
              if (isDesktop)
                _buildDesktopSidebar(context)
              else
                _buildTabletRail(context),

              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.borderLight,
              ),

              // Main Responsive Body Area
              Expanded(
                child: Scaffold(
                  appBar: title != null
                      ? AppBar(
                          title: Text(title!),
                          leading: leading,
                          actions: actions,
                        )
                      : null,
                  body: SafeArea(child: body),
                  floatingActionButton: floatingActionButton,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Compact Navigation Rail for Tablet or Landscape phone.
  /// Wrapped in a SingleChildScrollView to eliminate vertical overflow on short screens.
  Widget _buildTabletRail(BuildContext context) {
    final effectiveDests = tabletDestinations ?? destinations;
    final targetIndex = tabletSelectedIndex ?? currentIndex;
    final safeIndex = targetIndex.clamp(0, effectiveDests.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: NavigationRail(
                selectedIndex: safeIndex,
                onDestinationSelected: (val) {
                  final dest = effectiveDests[val];
                  if (dest.onTap != null) {
                    dest.onTap!();
                  } else if (onTabletDestinationSelected != null) {
                    onTabletDestinationSelected!(val);
                  } else {
                    onDestinationSelected(val);
                  }
                },
                labelType: NavigationRailLabelType.selected,
                leading: tabletLeading ??
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.recycling_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                    ),
                trailing: tabletTrailing,
                destinations: effectiveDests.map((d) {
                  return NavigationRailDestination(
                    icon: d.badgeText != null
                        ? Badge(
                            label: Text(d.badgeText!),
                            backgroundColor: AppColors.statusPending,
                            child: Icon(d.icon),
                          )
                        : Icon(d.icon),
                    selectedIcon: d.badgeText != null
                        ? Badge(
                            label: Text(d.badgeText!),
                            backgroundColor: AppColors.statusPending,
                            child: Icon(d.selectedIcon ?? d.icon),
                          )
                        : Icon(d.selectedIcon ?? d.icon),
                    label: Text(d.label),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Extended Permanent Sidebar Navigation for Desktop Screens
  Widget _buildDesktopSidebar(BuildContext context) {
    final effectiveDests = desktopDestinations ?? destinations;
    final selIndex = desktopSelectedIndex ?? currentIndex;

    return Container(
      width: 270,
      color: AppColors.surfaceLight,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Branding Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GreenBin',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Community Recycling',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Scrollable Navigation List: Guaranteed zero overflow on short screens
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 8),
                    child: Text(
                      'MENU',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...List.generate(effectiveDests.length, (index) {
                    final d = effectiveDests[index];
                    final isSelected = selIndex == index;
                    final isFirstSupportItem = d.label == 'Settings';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstSupportItem) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppColors.dividerLight),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 8),
                            child: Text(
                              'SETTINGS & SUPPORT',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: InkWell(
                            onTap: () {
                              if (d.onTap != null) {
                                d.onTap!();
                              } else if (onDesktopDestinationSelected != null) {
                                onDesktopDestinationSelected!(index);
                              } else {
                                onDestinationSelected(index);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? (d.selectedIcon ?? d.icon)
                                        : d.icon,
                                    size: 22,
                                    color: d.isDestructive
                                        ? AppColors.error
                                        : (isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      d.label,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: d.isDestructive
                                            ? AppColors.error
                                            : (isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (d.badgeText != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusPending,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        d.badgeText!,
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Bottom Community Tag / Info
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zero Waste Initiative',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

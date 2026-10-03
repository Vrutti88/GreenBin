import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Screen displaying user notifications for scheduled pickups, reminders,
/// and live collection status changes based on the Figma design.
///
/// Responsive Behavior:
/// - MOBILE (< 600px): Full-width single-column notification list.
/// - TABLET (600px - 1023px): Constrained, centered notification list (max-width: 680px).
/// - DESKTOP (>= 1024px): Centered maximum-width notification panel (max-width: 780px).
///   Notification cards adapt smoothly to available width without excessive stretching.
/// - LANDSCAPE: Scrollable, preventing clipping or overflow.
class NotificationsScreen extends StatefulWidget {
  final List<NotificationModel>? initialNotifications;
  final Stream<List<NotificationModel>>? notificationsStream;
  final String? initialUserId;
  final bool isEmbedded;

  const NotificationsScreen({
    super.key,
    this.initialNotifications,
    this.notificationsStream,
    this.initialUserId,
    this.isEmbedded = false,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  // Active filter index: 0 = All, 1 = Unread, 2 = Pickups, 3 = Reminders
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'All',
    'Unread',
    'Pickups',
    'Reminders',
  ];

  // Local state cache for demonstration/offline/in-memory manipulation
  List<NotificationModel>? _localNotifications;

  @override
  void initState() {
    super.initState();
    if (widget.initialNotifications != null) {
      _localNotifications = List.from(widget.initialNotifications!);
    }
    final uid = widget.initialUserId ?? _authService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      _firestoreService.autoAdvancePickupLifecycle(uid);
      _firestoreService.checkAndGenerateUpcomingReminders(uid);
      _firestoreService.checkAndGenerateMilestones(uid);
    }
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> items) {
    switch (_selectedFilterIndex) {
      case 1: // Unread
        return items.where((n) => !n.isRead).toList();
      case 2: // Pickups (Scheduled or Status Changed)
        return items
            .where((n) =>
                n.type == NotificationType.pickupScheduled ||
                n.type == NotificationType.pickupStatusChanged)
            .toList();
      case 3: // Reminders
        return items
            .where((n) => n.type == NotificationType.pickupReminder)
            .toList();
      case 0: // All
      default:
        return items;
    }
  }

  void _markAsRead(NotificationModel notification) {
    if (notification.isRead) return;

    if (_localNotifications != null) {
      setState(() {
        final index =
            _localNotifications!.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _localNotifications![index] =
              _localNotifications![index].copyWith(isRead: true);
        }
      });
    }

    _firestoreService.markNotificationAsRead(notification.id);
  }

  void _markAllAsRead(List<NotificationModel> currentList) {
    final userId =
        widget.initialUserId ?? _authService.currentUser?.uid ?? 'user-resident-1';

    setState(() {
      if (_localNotifications != null) {
        _localNotifications =
            _localNotifications!.map((n) => n.copyWith(isRead: true)).toList();
      }
    });

    _firestoreService.markAllNotificationsAsRead(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteNotification(NotificationModel notification) {
    setState(() {
      _localNotifications?.removeWhere((n) => n.id == notification.id);
    });

    _firestoreService.deleteNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification removed.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  void _navigateToPickupDetails(String pickupId) {
    Navigator.pushNamed(
      context,
      AppRoutes.pickupDetails,
      arguments: pickupId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        widget.initialUserId ?? _authService.currentUser?.uid ?? '';

    final effectiveStream = widget.notificationsStream ??
        (_localNotifications != null
            ? Stream.value(_localNotifications!)
            : (userId.isNotEmpty
                ? _firestoreService.streamUserNotifications(userId)
                : Stream.value(const <NotificationModel>[])));

    final content = StreamBuilder<List<NotificationModel>>(
          stream: effectiveStream,
          initialData: _localNotifications,
          builder: (context, snapshot) {
            final rawList = snapshot.data ??
                _localNotifications ??
                const <NotificationModel>[];

            final currentList = _localNotifications ?? rawList;
            final filteredList = _applyFilter(currentList);
            final unreadCount = currentList.where((n) => !n.isRead).length;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // Responsive Container Widths:
                // - Mobile: Full width with 16px margins
                // - Tablet: Constrained to 680px
                // - Desktop: Centered panel max-width 780px
                final double contentMaxWidth;
                if (width >= 1024) {
                  contentMaxWidth = 780; // Desktop centered panel
                } else if (width >= 600) {
                  contentMaxWidth = 680; // Tablet constrained list
                } else {
                  contentMaxWidth = double.infinity; // Mobile full width
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width < 600 ? 16.0 : 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Summary & Actions Bar
                          _buildHeaderBar(unreadCount, currentList),
                          const SizedBox(height: 14),

                          // Filter Chips (All, Unread, Pickups, Reminders)
                          _buildFilterChips(currentList),
                          const SizedBox(height: 16),

                          // Notifications List
                          Expanded(
                            child: filteredList.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: filteredList.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = filteredList[index];
                                      return _buildNotificationCard(
                                        context: context,
                                        notification: item,
                                        availableWidth: width < 600
                                            ? width - 32
                                            : (contentMaxWidth < width
                                                ? contentMaxWidth - 48
                                                : width - 48),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () {
              final currentList =
                  _localNotifications ?? const <NotificationModel>[];
              _markAllAsRead(currentList);
            },
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }

  // ===========================================================================
  // HEADER BAR & FILTER CHIPS
  Widget _buildHeaderBar(
      int unreadCount, List<NotificationModel> currentList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Inbox Updates',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (unreadCount > 0)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _markAllAsRead(currentList),
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips(List<NotificationModel> allItems) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          int badgeCount = 0;
          if (index == 0) badgeCount = allItems.length;
          if (index == 1) badgeCount = allItems.where((n) => !n.isRead).length;
          if (index == 2) {
            badgeCount = allItems
                .where((n) =>
                    n.type == NotificationType.pickupScheduled ||
                    n.type == NotificationType.pickupStatusChanged)
                .length;
          }
          if (index == 3) {
            badgeCount = allItems
                .where((n) => n.type == NotificationType.pickupReminder)
                .length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filters[index]),
                  if (badgeCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryContainer,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    );
  }

  // ===========================================================================
  // NOTIFICATION CARD (ADAPTS TO AVAILABLE WIDTH)
  // ===========================================================================

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required double availableWidth,
  }) {
    final isUnread = !notification.isRead;
    final typeColor = notification.type.color;
    final typeBg = notification.type.backgroundColor;
    final typeIcon = notification.type.icon;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            _markAsRead(notification);
            if (notification.pickupId != null &&
                notification.pickupId!.isNotEmpty) {
              _navigateToPickupDetails(notification.pickupId!);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isUnread
                  ? AppColors.surfaceLight
                  : AppColors.surfaceLight.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.borderLight,
                width: isUnread ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isUnread ? 0.04 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Main Info Column (Adapts to available width)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Type Tag & Time Ago & Unread Dot
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.type.displayName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notification.timeAgo,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Notification Title
                      Text(
                        notification.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight:
                              isUnread ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Message Body
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),

                      // Optional Action: View Pickup Details
                      if (notification.pickupId != null &&
                          notification.pickupId!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          onTap: () {
                            _markAsRead(notification);
                            _navigateToPickupDetails(notification.pickupId!);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'View Pickup Details',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilterIndex == 0
                    ? 'No Notifications Yet'
                    : 'No ${_filters[_selectedFilterIndex]} Notifications',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilterIndex == 0
                    ? 'You will receive updates here when your recyclable waste pickups are scheduled, crew is en route, or collection is completed.'
                    : 'Try selecting a different filter category to view your past updates and alerts.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFilterIndex != 0) ...[
                const SizedBox(height: 18),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('View All Notifications'),
                  onPressed: () {
                    setState(() => _selectedFilterIndex = 0);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

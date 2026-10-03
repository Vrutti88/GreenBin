import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Categories of notifications supported in GreenBin.
enum NotificationType {
  pickupScheduled,
  pickupReminder,
  pickupStatusChanged,
  milestone;

  String get displayName {
    switch (this) {
      case NotificationType.pickupScheduled:
        return 'Pickup Scheduled';
      case NotificationType.pickupReminder:
        return 'Pickup Reminder';
      case NotificationType.pickupStatusChanged:
        return 'Status Changed';
      case NotificationType.milestone:
        return 'Milestone Alert';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.pickupScheduled:
        return Icons.event_available_rounded;
      case NotificationType.pickupReminder:
        return Icons.alarm_rounded;
      case NotificationType.pickupStatusChanged:
        return Icons.sync_rounded;
      case NotificationType.milestone:
        return Icons.military_tech_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.pickupScheduled:
        return AppColors.statusConfirmed;
      case NotificationType.pickupReminder:
        return AppColors.tertiary;
      case NotificationType.pickupStatusChanged:
        return AppColors.primary;
      case NotificationType.milestone:
        return AppColors.secondary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case NotificationType.pickupScheduled:
        return AppColors.statusConfirmedBg;
      case NotificationType.pickupReminder:
        return AppColors.tertiaryContainer;
      case NotificationType.pickupStatusChanged:
        return AppColors.primaryContainer;
      case NotificationType.milestone:
        return AppColors.secondaryContainer;
    }
  }

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pickupscheduled':
      case 'pickup_scheduled':
      case 'scheduled':
        return NotificationType.pickupScheduled;
      case 'pickupreminder':
      case 'pickup_reminder':
      case 'reminder':
        return NotificationType.pickupReminder;
      case 'pickupstatuschanged':
      case 'pickup_status_changed':
      case 'status_changed':
      case 'status':
        return NotificationType.pickupStatusChanged;
      case 'milestone':
      case 'milestonealert':
      case 'milestone_alert':
        return NotificationType.milestone;
      default:
        return NotificationType.pickupScheduled;
    }
  }
}

/// Represents a single user notification for scheduled pickups, reminders,
/// and live status updates.
class NotificationModel {
  final String id;
  final String userId;
  final String? pickupId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? category;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.pickupId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.category,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? pickupId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? category,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pickupId: pickupId ?? this.pickupId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pickupId': pickupId,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'category': category,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedTimestamp;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      parsedTimestamp = rawTs.toDate();
    } else if (rawTs is String) {
      parsedTimestamp = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return NotificationModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      pickupId: map['pickupId'],
      type: NotificationType.fromString(map['type']),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: parsedTimestamp,
      isRead: map['isRead'] ?? false,
      category: map['category'],
    );
  }

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationModel.fromMap(data, docId: doc.id);
  }

  /// Relative human-readable time string (e.g. "10m ago", "2h ago", "Yesterday")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}';
    }
  }

  /// Exact formatted time (e.g. "8:00 AM", "10:30 PM")
  String get formattedTime {
    return DateFormat('h:mm a').format(timestamp);
  }

  /// Exact date and time string (e.g. "Today, 8:00 AM", "Oct 2, 8:00 AM")
  String get formattedDateTime {
    final now = DateTime.now();
    final isToday = now.year == timestamp.year &&
        now.month == timestamp.month &&
        now.day == timestamp.day;
    final timeStr = formattedTime;
    if (isToday) return 'Today, $timeStr';
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == timestamp.year &&
        yesterday.month == timestamp.month &&
        yesterday.day == timestamp.day;
    if (isYesterday) return 'Yesterday, $timeStr';
    return '${DateFormat('MMM d').format(timestamp)}, $timeStr';
  }

  /// Compact header label combining relative time and exact time
  /// e.g. "Just now", "15m ago • 8:00 AM", "Yesterday • 8:00 AM"
  String get headerTimeLabel {
    final ago = timeAgo;
    if (ago == 'Just now') return ago;
    return '$ago • $formattedTime';
  }

  /// Default sample notifications for demonstration, testing, and offline modes.
  static List<NotificationModel> get defaultNotifications => [
        NotificationModel(
          id: 'notif-1',
          userId: 'user-resident-1',
          pickupId: 'GB-TEST-1001',
          type: NotificationType.pickupStatusChanged,
          title: 'Collection Crew En Route',
          message:
              'North Eco Crew #4 is heading towards your location for the scheduled Plastic collection.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: false,
          category: 'Plastic',
        ),
        NotificationModel(
          id: 'notif-reminder-morning',
          userId: 'user-resident-1',
          pickupId: 'GB-TEST-1001',
          type: NotificationType.pickupReminder,
          title: 'Reminder: Someone Coming to Pickup',
          message:
              'Reminder: An Eco Collector is coming to pick up your Plastic recyclables this morning (8:00 AM - 10:00 AM). Please ensure your bins are placed outside and accessible.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: false,
          category: 'Plastic',
        ),
        NotificationModel(
          id: 'notif-2',
          userId: 'user-resident-1',
          pickupId: 'GB-TEST-1002',
          type: NotificationType.pickupReminder,
          title: 'Pickup Reminder for Tomorrow',
          message:
              'Friendly reminder: Your Paper & Cardboard pickup is tomorrow at 2:00 PM. Please ensure materials are flattened and dry.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: false,
          category: 'Paper & Cardboard',
        ),
        NotificationModel(
          id: 'notif-3',
          userId: 'user-resident-1',
          pickupId: 'GB-TEST-1001',
          type: NotificationType.pickupScheduled,
          title: 'Pickup Confirmed',
          message:
              'Your Plastic waste pickup for Saturday, Oct 10 at 8:00 AM has been confirmed and assigned.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          category: 'Plastic',
        ),
        NotificationModel(
          id: 'notif-4',
          userId: 'user-resident-1',
          pickupId: 'GB-TEST-1003',
          type: NotificationType.pickupStatusChanged,
          title: 'Pickup Completed',
          message:
              'Your Glass recycling batch was successfully collected and transported to the Springfield Recovery Center.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          category: 'Glass',
        ),
        NotificationModel(
          id: 'notif-5',
          userId: 'user-resident-1',
          pickupId: null,
          type: NotificationType.pickupReminder,
          title: 'E-Waste Preparation Tip',
          message:
              'Please tape terminals of all rechargeable batteries before placing electronic items in collection bins.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
          category: 'E-Waste',
        ),
      ];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/pickup_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'preferences_service.dart';

/// Service managing all Cloud Firestore operations for GreenBin with safe test fallback.
/// Enforces schemas:
/// - users/{userId}: name, email, phone, community, address, role, createdAt
/// - pickups/{pickupId}: userId, wasteCategory, pickupDate, timeSlot, address, notes, status, createdAt
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (_isFirebaseReady) return FirebaseFirestore.instance;
    return null;
  }

  // Collection References
  CollectionReference<Map<String, dynamic>>? get _usersCol =>
      _firestore?.collection('users');

  CollectionReference<Map<String, dynamic>>? get _pickupsCol =>
      _firestore?.collection('pickups');

  CollectionReference<Map<String, dynamic>>? get _notificationsCol =>
      _firestore?.collection('notifications');

  CollectionReference<Map<String, dynamic>>? get _supportTicketsCol =>
      _firestore?.collection('support_tickets');

  // ==========================================
  // USER PROFILE OPERATIONS (users/{userId})
  // ==========================================

  /// Save or update user profile document in Firestore: `users/{userId}`
  Future<void> saveUserProfile(UserModel user) async {
    final col = _usersCol;
    if (col == null) return;
    await col.doc(user.id).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Get user profile once by UID from `users/{userId}`
  Future<UserModel?> getUserProfile(String uid) async {
    final col = _usersCol;
    if (col == null) return null;
    final doc = await col.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Real-time stream of user profile from `users/{userId}`
  Stream<UserModel?> streamUserProfile(String uid) {
    final col = _usersCol;
    if (col == null) return const Stream.empty();
    return col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Update user address and community fields in `users/{userId}`
  Future<void> updateUserAddress({
    required String uid,
    required String address,
    String? street,
    String? city,
    String? postalCode,
    String? landmark,
    String? community,
  }) async {
    final col = _usersCol;
    if (col == null) return;
    final effectiveAddress = address.isNotEmpty ? address : (street ?? '');
    await col.doc(uid).update({
      'address': effectiveAddress,
      'street': effectiveAddress,
      'community': ?community,
      'city': ?city,
      'postalCode': ?postalCode,
      'landmark': ?landmark,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // PICKUP REQUEST OPERATIONS (pickups/{pickupId})
  // ==========================================

  /// Create a new recyclable waste pickup request in `pickups/{pickupId}`
  /// New pickups are always assigned status = "Scheduled".
  Future<String> createPickup(PickupModel pickup) async {
    final col = _pickupsCol;
    if (col == null) return 'local-demo-id';

    final docRef = pickup.id.isEmpty ? col.doc() : col.doc(pickup.id);
    final pickupWithId = pickup.copyWith(
      id: docRef.id,
      status: PickupStatus.scheduled, // Guaranteed "Scheduled" for new pickups
    );
    await docRef.set(pickupWithId.toMap());

    // Increment user's total pickup counter
    _usersCol?.doc(pickup.userId).update({
      'totalPickups': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create real-time notification for the scheduled pickup
    try {
      final formattedDate =
          DateFormat('EEE, MMM d, yyyy').format(pickup.pickupDate);
      await createNotification(
        NotificationModel(
          id: '',
          userId: pickup.userId,
          pickupId: docRef.id,
          type: NotificationType.pickupScheduled,
          title: 'Pickup Confirmed',
          message:
              'Your ${pickup.wasteCategory} waste pickup for $formattedDate at ${pickup.timeSlot} has been confirmed.',
          timestamp: DateTime.now(),
          isRead: false,
          category: pickup.wasteCategory,
        ),
      );
    } catch (_) {
      // Safe fallback if notifications collection is restricted
    }

    // Pre-schedule dedicated morning reminder for someone coming to pickup
    try {
      final (pickupStart, _) = PreferencesService.parseSlotWindowStatic(
        pickup.pickupDate,
        pickup.timeSlot,
      );
      final morningReminderTime = pickupStart;
      await createNotification(
        NotificationModel(
          id: '',
          userId: pickup.userId,
          pickupId: docRef.id,
          type: NotificationType.pickupReminder,
          title: 'Reminder: Someone Coming to Pickup',
          message:
              'Reminder: An Eco Collector is coming to pick up your ${pickup.wasteCategory} recyclables this morning (${pickup.timeSlot}). Please ensure your bins are placed outside and accessible.',
          timestamp: morningReminderTime,
          isRead: false,
          category: pickup.wasteCategory,
        ),
      );
    } catch (_) {
      // Safe fallback
    }

    // Evaluate if this new pickup falls within user's reminder window
    try {
      await checkAndGenerateUpcomingReminders(pickup.userId);
    } catch (_) {
      // Safe fallback
    }

    return docRef.id;
  }


  /// Keep the totalPickups counter on users/{userId} strictly in sync with the true count of pickups
  Future<void> syncUserPickupCount(String userId, int trueCount) async {
    final col = _usersCol;
    if (col == null || userId.isEmpty) return;
    try {
      await col.doc(userId).set({
        'totalPickups': trueCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Permanently delete a pickup request from Firestore and re-synchronize resident stats
  Future<void> deletePickup({
    required String pickupId,
    required String userId,
  }) async {
    final col = _pickupsCol;
    if (col == null || pickupId.isEmpty) return;

    try {
      await col.doc(pickupId).delete();
    } catch (e) {
      debugPrint('Error deleting pickup document $pickupId: $e');
    }

    if (userId.isNotEmpty) {
      try {
        final remainingSnap =
            await col.where('userId', isEqualTo: userId).get();
        final count = remainingSnap.docs.length;
        await syncUserPickupCount(userId, count);
      } catch (_) {}
    }
  }

  /// Stream pickups for a specific resident (sorted by pickup date descending)
  Stream<List<PickupModel>> streamUserPickups(String userId) {
    final col = _pickupsCol;
    if (col == null) return const Stream.empty();

    return col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final pickups = snapshot.docs
          .map((doc) => PickupModel.fromFirestore(doc))
          .toList();
      pickups.sort((a, b) => b.pickupDate.compareTo(a.pickupDate));

      // Auto-synchronize users/{userId}.totalPickups if count drifted
      if (_usersCol != null && userId.isNotEmpty) {
        _usersCol!.doc(userId).update({
          'totalPickups': pickups.length,
        }).catchError((_) {});
      }

      return pickups;
    });
  }

  /// Stream all pickups centrally for the community collection team
  Stream<List<PickupModel>> streamAllPickups() {
    final col = _pickupsCol;
    if (col == null) return const Stream.empty();

    return col.snapshots().map((snapshot) {
      final pickups = snapshot.docs
          .map((doc) => PickupModel.fromFirestore(doc))
          .toList();
      pickups.sort((a, b) => b.pickupDate.compareTo(a.pickupDate));
      return pickups;
    });
  }

  /// Get single pickup by document ID
  Future<PickupModel?> getPickupById(String pickupId) async {
    final col = _pickupsCol;
    if (col == null) return null;
    final doc = await col.doc(pickupId).get();
    if (!doc.exists) return null;
    return PickupModel.fromFirestore(doc);
  }

  /// Real-time stream of a single pickup document by ID
  Stream<PickupModel?> streamPickupById(String pickupId) {
    final col = _pickupsCol;
    if (col == null || pickupId.isEmpty) return const Stream.empty();

    return col.doc(pickupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PickupModel.fromFirestore(doc);
    });
  }

  /// Update pickup status (e.g. to "Collected")
  Future<void> updatePickupStatus({
    required String pickupId,
    required PickupStatus status,
    String? assignedTeam,
  }) async {
    final col = _pickupsCol;
    if (col == null) return;

    final Map<String, dynamic> updates = {
      'status': status.firestoreValue, // "Scheduled", "In Transit", "Collected"
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (assignedTeam != null) {
      updates['assignedTeam'] = assignedTeam;
    }

    try {
      await col.doc(pickupId).update(updates);
    } catch (_) {
      try {
        await col.doc(pickupId).set(updates, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to set pickup status: $e');
      }
    }

    // Always attempt notification generation for the resident
    try {
      final prefsService = PreferencesService();
      final statusUpdatesEnabled = await prefsService.getStatusUpdates();

      final pickup = await getPickupById(pickupId);
      final targetUserId = pickup?.userId.isNotEmpty == true
          ? pickup!.userId
          : AuthService().currentUser?.uid;

      if (targetUserId != null && targetUserId.isNotEmpty) {
        if (statusUpdatesEnabled) {
          final notifTitle = status == PickupStatus.collected
              ? 'Pickup Completed'
              : status == PickupStatus.inTransit
                  ? 'Collection Crew En Route'
                  : 'Pickup Status Updated';
          final wasteCat = pickup?.wasteCategory ?? 'Recycling';
          final notifMessage = status == PickupStatus.collected
              ? 'Your $wasteCat recycling batch was successfully collected and transported to the recovery center.'
              : status == PickupStatus.inTransit
                  ? '${assignedTeam ?? 'Collection Crew'} is heading towards your location for the scheduled $wasteCat collection.'
                  : 'Your pickup status is now ${status.displayName}.';

          // Avoid duplicate notification if already sent for same pickup and title
          bool alreadyExists = false;
          if (_notificationsCol != null && pickupId.isNotEmpty) {
            try {
              final existing = await _notificationsCol!
                  .where('userId', isEqualTo: targetUserId)
                  .where('pickupId', isEqualTo: pickupId)
                  .where('title', isEqualTo: notifTitle)
                  .limit(1)
                  .get();
              if (existing.docs.isNotEmpty) {
                alreadyExists = true;
              }
            } catch (_) {}
          }

          if (!alreadyExists) {
            await createNotification(
              NotificationModel(
                id: '',
                userId: targetUserId,
                pickupId: pickupId,
                type: NotificationType.pickupStatusChanged,
                title: notifTitle,
                message: notifMessage,
                timestamp: DateTime.now(),
                isRead: false,
                category: wasteCat,
              ),
            );
            await prefsService.triggerFeedbackIfEnabled();
          }
        }

        // If completed/collected, evaluate milestone achievements
        if (status == PickupStatus.collected) {
          await checkAndGenerateMilestones(targetUserId);
        }
      }
    } catch (_) {
      // Safe fallback
    }
  }

  /// Mark a pickup as "Collected" and increment recycling statistics
  Future<void> markPickupCollected(String pickupId, {double weightKg = 4.5}) async {
    await updatePickupStatus(
      pickupId: pickupId,
      status: PickupStatus.collected,
    );

    try {
      final pickup = await getPickupById(pickupId);
      final targetUserId = pickup?.userId.isNotEmpty == true
          ? pickup!.userId
          : AuthService().currentUser?.uid;

      if (targetUserId != null && targetUserId.isNotEmpty && _usersCol != null) {
        await _usersCol!.doc(targetUserId).set({
          'totalPickups': FieldValue.increment(1),
          'kgRecycled': FieldValue.increment(weightKg),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Evaluate milestone awards
        await checkAndGenerateMilestones(targetUserId);
      }
    } catch (_) {
      // Safe fallback
    }
  }

  /// Cancel a scheduled pickup request
  Future<void> cancelPickup(String pickupId, {String? reason}) async {
    final col = _pickupsCol;
    if (col == null) return;
    await col.doc(pickupId).update({
      'status': PickupStatus.cancelled.firestoreValue,
      if (reason != null && reason.isNotEmpty) 'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create real-time notification for the cancellation if user enabled status updates
    try {
      final prefsService = PreferencesService();
      final statusUpdatesEnabled = await prefsService.getStatusUpdates();
      if (statusUpdatesEnabled) {
        final pickup = await getPickupById(pickupId);
        if (pickup != null && pickup.userId.isNotEmpty) {
          await createNotification(
            NotificationModel(
              id: '',
              userId: pickup.userId,
              pickupId: pickupId,
              type: NotificationType.pickupStatusChanged,
              title: 'Pickup Cancelled',
              message:
                  'Your ${pickup.wasteCategory} pickup has been cancelled${reason != null && reason.isNotEmpty ? ': $reason' : '.'}',
              timestamp: DateTime.now(),
              isRead: false,
              category: pickup.wasteCategory,
            ),
          );
          await prefsService.triggerFeedbackIfEnabled();
        }
      }
    } catch (_) {
      // Safe fallback
    }
  }

  // ==========================================
  // NOTIFICATION OPERATIONS
  // ==========================================

  /// Stream notifications for a specific resident (sorted by timestamp descending,
  /// delivering only notifications whose scheduled event time has arrived,
  /// with strict deduplication and excluding unwanted diverted notifications)
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    final col = _notificationsCol;
    if (col == null) return const Stream.empty();

    return col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final notifs = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((n) => !n.timestamp.isAfter(now))
          // 1. Exclude any unwanted diverted notifications
          .where((n) =>
              !n.title.toLowerCase().contains('diverted') &&
              !n.message.toLowerCase().contains('diverted'))
          .toList();
      notifs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 2. Strict deduplication so identical notifications never appear twice
      final seenKeys = <String>{};
      final uniqueNotifs = <NotificationModel>[];
      for (final n in notifs) {
        final key = '${n.type.name}|${n.title.trim().toLowerCase()}|${n.pickupId ?? ''}';
        if (seenKeys.add(key)) {
          uniqueNotifs.add(n);
        }
      }
      return uniqueNotifs;
    });
  }

  /// Cleans up any unwanted "diverted" notifications and deletes duplicate notifications
  /// from the user's Firestore notifications collection.
  Future<void> cleanDivertedAndDuplicateNotifications(String userId) async {
    final notifsCol = _notificationsCol;
    if (notifsCol == null || userId.isEmpty) return;

    try {
      final snap = await notifsCol.where('userId', isEqualTo: userId).get();
      final seenKeys = <String>{};

      for (final doc in snap.docs) {
        final data = doc.data();
        final title = (data['title'] as String? ?? '').trim().toLowerCase();
        final message = (data['message'] as String? ?? '').trim().toLowerCase();
        final pickupId = data['pickupId'] as String? ?? '';
        final type = data['type'] as String? ?? '';

        // 1. Delete any notifications with "diverted" in title or message
        if (title.contains('diverted') || message.contains('diverted')) {
          await doc.reference.delete();
          continue;
        }

        // 2. Deduplicate: if duplicate document exists in Firestore, keep the first and delete extras
        final key = '$type|$title|$pickupId';
        if (!seenKeys.add(key)) {
          await doc.reference.delete();
        }
      }
    } catch (_) {
      // Safe fallback
    }
  }

  /// Mark a single notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final col = _notificationsCol;
    if (col == null) return;
    await col.doc(notificationId).update({'isRead': true});
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    final col = _notificationsCol;
    if (col == null) return;
    final snapshot = await col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore?.batch();
    if (batch == null) return;
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final col = _notificationsCol;
    if (col == null) return;
    await col.doc(notificationId).delete();
  }

  /// Create a notification
  Future<String> createNotification(NotificationModel notification) async {
    final col = _notificationsCol;
    if (col == null) return 'local-notif-id';
    final docRef =
        notification.id.isEmpty ? col.doc() : col.doc(notification.id);
    final notifWithId = notification.copyWith(id: docRef.id);
    await docRef.set(notifWithId.toMap());
    return docRef.id;
  }

  // ==========================================
  // SUPPORT INQUIRIES & TICKETS (support_tickets)
  // ==========================================

  /// Submit an Eco Support inquiry / ticket and generate confirmation notification
  Future<String> submitSupportTicket({
    required String userId,
    required String userEmail,
    required String subject,
    required String message,
    String category = 'General Support',
  }) async {
    final ticketNumber =
        'GB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final col = _supportTicketsCol;
    final docRef = col?.doc();

    if (docRef != null) {
      await docRef.set({
        'id': docRef.id,
        'ticketNumber': ticketNumber,
        'userId': userId,
        'userEmail': userEmail,
        'subject': subject,
        'message': message,
        'category': category,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Automatically generate a real-time confirmation notification for the user
    if (userId.isNotEmpty) {
      await createNotification(NotificationModel(
        id: '',
        userId: userId,
        title: 'Support Inquiry Received (#$ticketNumber)',
        message:
            'We received your inquiry regarding "$subject". Our Eco Support team will review and reply within 24 hours.',
        type: NotificationType.pickupStatusChanged,
        timestamp: DateTime.now(),
        isRead: false,
        category: category,
      ));
    }

    return ticketNumber;
  }

  // ==========================================
  // REAL-TIME NOTIFICATIONS & LIFECYCLE ENGINE
  // ==========================================

  static final Set<String> _activeReminderSyncs = <String>{};
  static final Set<String> _activeMilestoneSyncs = <String>{};

  /// Check user's scheduled pickups and synchronize real-time lifecycle notifications:
  /// 1. Pickup Reminders (stamped with the exact morning reminder time, never app-open time)
  /// 2. Live Collection Updates (triggered when pickup window opens, stamped with start time)
  /// 3. Completed Pickup Notifications (triggered when pickup window closes, stamped with end time)
  /// 4. Auto-repairs any past notifications previously stamped with app-launch times or generic titles.
  Future<int> checkAndGenerateUpcomingReminders(String userId) async {
    final col = _pickupsCol;
    final notifsCol = _notificationsCol;
    if (col == null || notifsCol == null || userId.isEmpty) return 0;

    // Concurrency lock: prevent parallel runs that can produce duplicate notifications
    if (_activeReminderSyncs.contains(userId)) return 0;
    _activeReminderSyncs.add(userId);

    try {
      // First clean up any unwanted diverted notifications and database duplicates
      await cleanDivertedAndDuplicateNotifications(userId);

      final prefsService = PreferencesService();
      final remindersEnabled = await prefsService.getPickupReminders();
      final statusUpdatesEnabled = await prefsService.getStatusUpdates();
      final now = DateTime.now();

      // Query all pickups for this user so reminders and arrival notifications
      // are accurately generated and repaired regardless of lifecycle stage
      final snapshot = await col
          .where('userId', isEqualTo: userId)
          .get();

      int notificationsCreated = 0;

      for (final doc in snapshot.docs) {
        final pickup = PickupModel.fromFirestore(doc);
        final (pickupStart, pickupEnd) =
            PreferencesService.parseSlotWindowStatic(
          pickup.pickupDate,
          pickup.timeSlot,
        );

        // Morning reminder is anchored strictly to the morning of collection (e.g. 8:00 AM)
        final morningReminderTime = pickupStart;

        // ---------------------------------------------------------------------
        // 1. MORNING REMINDER: SOMEONE COMING TO PICKUP
        // ---------------------------------------------------------------------
        final existingReminderSnap = await notifsCol
            .where('userId', isEqualTo: userId)
            .where('pickupId', isEqualTo: pickup.id)
            .get();

        final reminderDocs = existingReminderSnap.docs.where((d) {
          final typeStr = d.data()['type'] as String? ?? '';
          final titleStr = d.data()['title'] as String? ?? '';
          return typeStr == NotificationType.pickupReminder.name ||
              titleStr.contains('Reminder') ||
              titleStr.contains('Coming to Pickup');
        }).toList();

        if (reminderDocs.isNotEmpty) {
          // If a reminder notification was previously stamped with app-open time,
          // night time, or had an old title, repair it to the true morning reminder!
          for (final existingDoc in reminderDocs) {
            final data = existingDoc.data();
            final existingTs =
                (data['timestamp'] as Timestamp?)?.toDate();
            final existingTitle = data['title'] as String? ?? '';
            final existingMsg = data['message'] as String? ?? '';

            final needsTitleFix =
                existingTitle != 'Reminder: Someone Coming to Pickup';
            final needsMsgFix = !existingMsg.contains('Someone Coming to Pickup') &&
                !existingMsg.contains('is coming to pick up');
            // If stamped after pickup start (e.g. when app was opened later at night):
            final needsTsRepair = existingTs != null &&
                (existingTs.isAfter(pickupStart) || existingTs.isBefore(morningReminderTime));

            if (needsTitleFix || needsMsgFix || needsTsRepair) {
              await notifsCol.doc(existingDoc.id).update({
                'title': 'Reminder: Someone Coming to Pickup',
                'message':
                    'Reminder: An Eco Collector is coming to pick up your ${pickup.wasteCategory} recyclables this morning (${pickup.timeSlot}). Please ensure your bins are placed outside and accessible.',
                'timestamp': Timestamp.fromDate(morningReminderTime),
                'type': NotificationType.pickupReminder.name,
              });
            }
          }
        } else if (remindersEnabled) {
          // Deliver the morning reminder for someone coming to pickup
          await createNotification(
            NotificationModel(
              id: '',
              userId: userId,
              pickupId: pickup.id,
              type: NotificationType.pickupReminder,
              title: 'Reminder: Someone Coming to Pickup',
              message:
                  'Reminder: An Eco Collector is coming to pick up your ${pickup.wasteCategory} recyclables this morning (${pickup.timeSlot}). Please ensure your bins are placed outside and accessible.',
              timestamp: morningReminderTime,
              isRead: false,
              category: pickup.wasteCategory,
            ),
          );
          notificationsCreated++;
        }

        // ---------------------------------------------------------------------
        // 2. LIVE IN-PROGRESS NOTIFICATION: COLLECTOR ON THE WAY / EN ROUTE
        // ---------------------------------------------------------------------
        if (statusUpdatesEnabled &&
            (now.isAfter(pickupStart) ||
                pickup.status == PickupStatus.inTransit ||
                pickup.status == PickupStatus.collected)) {
          final existingTransitSnap = await notifsCol
              .where('userId', isEqualTo: userId)
              .where('pickupId', isEqualTo: pickup.id)
              .where('title', isEqualTo: 'Collection Crew En Route')
              .limit(1)
              .get();

          if (existingTransitSnap.docs.isEmpty) {
            await createNotification(
              NotificationModel(
                id: '',
                userId: userId,
                pickupId: pickup.id,
                type: NotificationType.pickupStatusChanged,
                title: 'Collection Crew En Route',
                message:
                    'Our collection team (North Eco Crew #4) is heading to your address for your scheduled ${pickup.wasteCategory} pickup (${pickup.timeSlot}).',
                timestamp: pickupStart,
                isRead: false,
                category: pickup.wasteCategory,
              ),
            );
            notificationsCreated++;
          }
        }

        // ---------------------------------------------------------------------
        // 3. COMPLETED COLLECTION NOTIFICATION (After window concludes)
        // ---------------------------------------------------------------------
        if (statusUpdatesEnabled &&
            (now.isAfter(pickupEnd) ||
                pickup.status == PickupStatus.collected)) {
          final existingCollectedSnap = await notifsCol
              .where('userId', isEqualTo: userId)
              .where('pickupId', isEqualTo: pickup.id)
              .where('title', isEqualTo: 'Pickup Completed')
              .limit(1)
              .get();

          if (existingCollectedSnap.docs.isEmpty) {
            await createNotification(
              NotificationModel(
                id: '',
                userId: userId,
                pickupId: pickup.id,
                type: NotificationType.pickupStatusChanged,
                title: 'Pickup Completed',
                message:
                    'Your ${pickup.wasteCategory} recycling batch (${pickup.timeSlot}) was successfully collected and transported to the local recovery facility.',
                timestamp: pickupEnd,
                isRead: false,
                category: pickup.wasteCategory,
              ),
            );
            notificationsCreated++;
          }
        }
      }

      return notificationsCreated;
    } catch (_) {
      return 0;
    } finally {
      _activeReminderSyncs.remove(userId);
    }
  }

  // ==========================================
  // REAL-TIME MILESTONE CELEBRATION ENGINE
  // ==========================================

  /// Check user's total recycling accomplishments and generate milestone notifications
  /// if milestone alerts are enabled and new milestones are reached.
  Future<int> checkAndGenerateMilestones(String userId) async {
    final col = _pickupsCol;
    final notifsCol = _notificationsCol;
    if (col == null || notifsCol == null || userId.isEmpty) return 0;

    // Concurrency lock: prevent duplicate milestone creation from simultaneous triggers
    if (_activeMilestoneSyncs.contains(userId)) return 0;
    _activeMilestoneSyncs.add(userId);

    try {
      // First clean up any unwanted diverted notifications and database duplicates
      await cleanDivertedAndDuplicateNotifications(userId);

      final prefsService = PreferencesService();
      final milestoneAlertsEnabled = await prefsService.getMilestoneAlerts();
      if (!milestoneAlertsEnabled) return 0;

      // Count collected pickups
      final collectedSnap = await col
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Collected')
          .get();
      final collectedCount = collectedSnap.docs.length;

      // Existing notifications for this user to prevent duplicate milestone creation
      final existingNotifs =
          await notifsCol.where('userId', isEqualTo: userId).get();
      final existingTitles = existingNotifs.docs
          .map((d) => (d.data()['title'] as String? ?? '').trim().toLowerCase())
          .toSet();

      int milestonesCreated = 0;

      final potentialMilestones = <Map<String, String>>[];

      if (collectedCount >= 1) {
        potentialMilestones.add({
          'title': 'Milestone: First Pickup Completed!',
          'message':
              'Congratulations on completing your first GreenBin recyclable pickup! You are taking real action towards a zero-waste neighborhood.',
        });
      }
      if (collectedCount >= 5) {
        potentialMilestones.add({
          'title': 'Milestone: 5 Collections Completed!',
          'message':
              'High five! You have completed 5 doorstep collections and earned the Bronze GreenBin badge.',
        });
      }
      if (collectedCount >= 10) {
        potentialMilestones.add({
          'title': 'Milestone: 10 Collections Completed!',
          'message':
              'Incredible dedication! You have successfully completed 10 doorstep collections.',
        });
      }

      for (final m in potentialMilestones) {
        final title = m['title']!;
        final lowerTitle = title.trim().toLowerCase();
        if (!existingTitles.contains(lowerTitle)) {
          existingTitles.add(lowerTitle);
          await createNotification(
            NotificationModel(
              id: '',
              userId: userId,
              type: NotificationType.milestone,
              title: title,
              message: m['message']!,
              timestamp: DateTime.now(),
              isRead: false,
              category: 'Eco Milestone',
            ),
          );
          milestonesCreated++;
        }
      }

      // Silent background sync without buzzing device on startup
      return milestonesCreated;
    } catch (_) {
      return 0;
    } finally {
      _activeMilestoneSyncs.remove(userId);
    }
  }
}

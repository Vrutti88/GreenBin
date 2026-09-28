import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../models/pickup_model.dart';
import '../models/notification_model.dart';

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

    return docRef.id;
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
      'status': status.firestoreValue, // "Scheduled" or "Collected"
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (assignedTeam != null) {
      updates['assignedTeam'] = assignedTeam;
    }

    await col.doc(pickupId).update(updates);
  }

  /// Mark a pickup as "Collected"
  Future<void> markPickupCollected(String pickupId) async {
    await updatePickupStatus(
      pickupId: pickupId,
      status: PickupStatus.collected,
    );
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
  }

  // ==========================================
  // NOTIFICATION OPERATIONS
  // ==========================================

  /// Stream notifications for a specific resident (sorted by timestamp descending)
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    final col = _notificationsCol;
    if (col == null) return const Stream.empty();

    return col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifs = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      notifs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifs;
    });
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
}

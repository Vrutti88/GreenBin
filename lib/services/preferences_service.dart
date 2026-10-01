import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing resident settings and reminder preferences with local
/// SharedPreferences caching and Cloud Firestore synchronization.
class PreferencesService {
  static const String keyPickupReminders = 'pref_pickup_reminders';
  static const String keyStatusUpdates = 'pref_status_updates';
  static const String keyMilestoneAlerts = 'pref_milestone_alerts';
  static const String keySoundAndVibrate = 'pref_sound_and_vibrate';
  static const String keyReminderWindow = 'pref_reminder_window';

  static const String defaultReminderWindow = '1 day before';
  static const bool defaultPickupReminders = true;
  static const bool defaultStatusUpdates = true;
  static const bool defaultMilestoneAlerts = true;
  static const bool defaultSoundAndVibrate = true;

  final SharedPreferences? _customPrefs;
  final FirebaseFirestore? _customFirestore;

  PreferencesService({
    SharedPreferences? prefs,
    FirebaseFirestore? firestore,
  })  : _customPrefs = prefs,
        _customFirestore = firestore;

  Future<SharedPreferences> get _prefs async {
    if (_customPrefs != null) return _customPrefs;
    return await SharedPreferences.getInstance();
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    return null;
  }

  // =========================================================================
  // GETTERS
  // =========================================================================

  Future<bool> getPickupReminders() async {
    final prefs = await _prefs;
    return prefs.getBool(keyPickupReminders) ?? defaultPickupReminders;
  }

  Future<bool> getStatusUpdates() async {
    final prefs = await _prefs;
    return prefs.getBool(keyStatusUpdates) ?? defaultStatusUpdates;
  }

  Future<bool> getMilestoneAlerts() async {
    final prefs = await _prefs;
    return prefs.getBool(keyMilestoneAlerts) ?? defaultMilestoneAlerts;
  }

  Future<bool> getSoundAndVibrate() async {
    final prefs = await _prefs;
    return prefs.getBool(keySoundAndVibrate) ?? defaultSoundAndVibrate;
  }

  Future<String> getReminderWindow() async {
    final prefs = await _prefs;
    return prefs.getString(keyReminderWindow) ?? defaultReminderWindow;
  }

  // =========================================================================
  // SETTERS
  // =========================================================================

  Future<void> setPickupReminders(bool value, {String? userId}) async {
    final prefs = await _prefs;
    await prefs.setBool(keyPickupReminders, value);
    if (userId != null && userId.isNotEmpty) {
      await _syncSingleToFirestore(userId, 'pickupReminders', value);
    }
  }

  Future<void> setStatusUpdates(bool value, {String? userId}) async {
    final prefs = await _prefs;
    await prefs.setBool(keyStatusUpdates, value);
    if (userId != null && userId.isNotEmpty) {
      await _syncSingleToFirestore(userId, 'statusUpdates', value);
    }
  }

  Future<void> setMilestoneAlerts(bool value, {String? userId}) async {
    final prefs = await _prefs;
    await prefs.setBool(keyMilestoneAlerts, value);
    if (userId != null && userId.isNotEmpty) {
      await _syncSingleToFirestore(userId, 'milestoneAlerts', value);
    }
  }

  Future<void> setSoundAndVibrate(bool value, {String? userId}) async {
    final prefs = await _prefs;
    await prefs.setBool(keySoundAndVibrate, value);
    if (userId != null && userId.isNotEmpty) {
      await _syncSingleToFirestore(userId, 'soundAndVibrate', value);
    }
  }

  Future<void> setReminderWindow(String window, {String? userId}) async {
    final prefs = await _prefs;
    await prefs.setString(keyReminderWindow, window);
    if (userId != null && userId.isNotEmpty) {
      await _syncSingleToFirestore(userId, 'reminderWindow', window);
    }
  }

  // =========================================================================
  // SOUND & HAPTIC FEEDBACK TRIGGER
  // =========================================================================

  /// Triggers haptic feedback and system click sound if user enabled Sound & Vibration
  Future<void> triggerFeedbackIfEnabled() async {
    final enabled = await getSoundAndVibrate();
    if (enabled) {
      try {
        HapticFeedback.mediumImpact().ignore();
        SystemSound.play(SystemSoundType.click).ignore();
      } catch (_) {
        // Safe fallback in test environments or unsupported devices
      }
    }
  }

  // =========================================================================
  // DURATION PARSING & CALCULATIONS
  // =========================================================================

  /// Convert reminder window string to Duration before pickup
  Duration getReminderDuration(String window) {
    switch (window.trim().toLowerCase()) {
      case '2 hours before':
        return const Duration(hours: 2);
      case '2 days before':
        return const Duration(days: 2);
      case '1 day before':
      default:
        return const Duration(days: 1);
    }
  }

  /// Calculates the exact DateTime when a reminder is due for a scheduled pickup
  DateTime calculateReminderDateTime({
    required DateTime pickupDate,
    required String timeSlot,
    required String window,
  }) {
    // Parse start hour from timeSlot if available (e.g. '09:00 AM - 11:00 AM')
    int hour = 9;
    int minute = 0;
    try {
      final slotLower = timeSlot.toLowerCase();
      final timeParts = slotLower.split('-').first.trim();
      final isPm = timeParts.contains('pm');
      final rawTime = timeParts.replaceAll(RegExp(r'[^0-9:]'), '');
      if (rawTime.contains(':')) {
        final parts = rawTime.split(':');
        hour = int.tryParse(parts[0]) ?? 9;
        minute = int.tryParse(parts[1]) ?? 0;
        if (isPm && hour < 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
      }
    } catch (_) {
      // Default to 9:00 AM on pickup date
      hour = 9;
      minute = 0;
    }

    final pickupExactTime = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      hour,
      minute,
    );

    final duration = getReminderDuration(window);
    return pickupExactTime.subtract(duration);
  }

  // =========================================================================
  // FIRESTORE SYNC HELPERS
  // =========================================================================

  Future<void> _syncSingleToFirestore(
    String userId,
    String field,
    dynamic value,
  ) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('users').doc(userId).set({
        'preferences': {
          field: value,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (_) {
      // Safe fallback if offline or restricted
    }
  }

  /// Sync all local preferences to user profile in Firestore
  Future<void> syncAllToFirestore(String userId) async {
    final firestore = _firestore;
    if (firestore == null || userId.isEmpty) return;
    final prefs = await _prefs;
    try {
      await firestore.collection('users').doc(userId).set({
        'preferences': {
          'pickupReminders':
              prefs.getBool(keyPickupReminders) ?? defaultPickupReminders,
          'statusUpdates':
              prefs.getBool(keyStatusUpdates) ?? defaultStatusUpdates,
          'milestoneAlerts':
              prefs.getBool(keyMilestoneAlerts) ?? defaultMilestoneAlerts,
          'soundAndVibrate':
              prefs.getBool(keySoundAndVibrate) ?? defaultSoundAndVibrate,
          'reminderWindow':
              prefs.getString(keyReminderWindow) ?? defaultReminderWindow,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (_) {
      // Safe fallback
    }
  }

  /// Load user profile preferences from Firestore into local cache
  Future<void> loadFromFirestore(String userId) async {
    final firestore = _firestore;
    if (firestore == null || userId.isEmpty) return;
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) return;
      final data = doc.data();
      final prefsData = data?['preferences'] as Map<String, dynamic>?;
      if (prefsData == null) return;

      final prefs = await _prefs;
      if (prefsData['pickupReminders'] != null) {
        await prefs.setBool(
            keyPickupReminders, prefsData['pickupReminders'] as bool);
      }
      if (prefsData['statusUpdates'] != null) {
        await prefs.setBool(
            keyStatusUpdates, prefsData['statusUpdates'] as bool);
      }
      if (prefsData['milestoneAlerts'] != null) {
        await prefs.setBool(
            keyMilestoneAlerts, prefsData['milestoneAlerts'] as bool);
      }
      if (prefsData['soundAndVibrate'] != null) {
        await prefs.setBool(
            keySoundAndVibrate, prefsData['soundAndVibrate'] as bool);
      }
      if (prefsData['reminderWindow'] != null) {
        await prefs.setString(
            keyReminderWindow, prefsData['reminderWindow'] as String);
      }
    } catch (_) {
      // Safe fallback
    }
  }
}

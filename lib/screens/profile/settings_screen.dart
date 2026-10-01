import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Screen managing resident preferences, notification toggles, and security settings.
///
/// Responsive Behavior:
/// - MOBILE (<600px): Single-column settings list.
/// - TABLET / DESKTOP (>=600px): Constrained centered settings panel (max-width: 680px).
///   Avoids stretching settings rows unnecessarily across wide screens.
class SettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefsService = PreferencesService();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // Notification preferences
  bool _pickupReminders = PreferencesService.defaultPickupReminders;
  bool _statusUpdates = PreferencesService.defaultStatusUpdates;
  bool _milestoneAlerts = PreferencesService.defaultMilestoneAlerts;

  // App preferences
  bool _soundAndVibrate = PreferencesService.defaultSoundAndVibrate;
  String _reminderWindow = PreferencesService.defaultReminderWindow;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      await _prefsService.loadFromFirestore(userId);
    }
    final pickupReminders = await _prefsService.getPickupReminders();
    final statusUpdates = await _prefsService.getStatusUpdates();
    final milestoneAlerts = await _prefsService.getMilestoneAlerts();
    final soundAndVibrate = await _prefsService.getSoundAndVibrate();
    final reminderWindow = await _prefsService.getReminderWindow();

    if (mounted) {
      setState(() {
        _pickupReminders = pickupReminders;
        _statusUpdates = statusUpdates;
        _milestoneAlerts = milestoneAlerts;
        _soundAndVibrate = soundAndVibrate;
        _reminderWindow = reminderWindow;
      });
    }
  }

  Future<void> _onReminderWindowChanged(String? val) async {
    if (val == null) return;
    setState(() => _reminderWindow = val);
    final userId = _authService.currentUser?.uid;
    await _prefsService.setReminderWindow(val, userId: userId);
    await _prefsService.triggerFeedbackIfEnabled();

    if (userId != null && userId.isNotEmpty && _pickupReminders) {
      await _firestoreService.checkAndGenerateUpcomingReminders(userId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder timing set to $val'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onPickupRemindersChanged(bool val) async {
    setState(() => _pickupReminders = val);
    final userId = _authService.currentUser?.uid;
    await _prefsService.setPickupReminders(val, userId: userId);

    if (val) {
      await _prefsService.triggerFeedbackIfEnabled();
      if (userId != null && userId.isNotEmpty) {
        await _firestoreService.checkAndGenerateUpcomingReminders(userId);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              val ? 'Pickup reminders enabled' : 'Pickup reminders disabled'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onStatusUpdatesChanged(bool val) async {
    setState(() => _statusUpdates = val);
    final userId = _authService.currentUser?.uid;
    await _prefsService.setStatusUpdates(val, userId: userId);
    if (val) {
      await _prefsService.triggerFeedbackIfEnabled();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              val ? 'Status updates enabled' : 'Status updates disabled'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onMilestoneAlertsChanged(bool val) async {
    setState(() => _milestoneAlerts = val);
    final userId = _authService.currentUser?.uid;
    await _prefsService.setMilestoneAlerts(val, userId: userId);

    if (val) {
      await _prefsService.triggerFeedbackIfEnabled();
      if (userId != null && userId.isNotEmpty) {
        await _firestoreService.checkAndGenerateMilestones(userId);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              val ? 'Milestone alerts enabled' : 'Milestone alerts disabled'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onSoundAndVibrateChanged(bool val) async {
    setState(() => _soundAndVibrate = val);
    final userId = _authService.currentUser?.uid;
    await _prefsService.setSoundAndVibrate(val, userId: userId);

    if (val) {
      await _prefsService.triggerFeedbackIfEnabled();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              val ? 'Sound & vibration enabled' : 'Sound & vibration disabled'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'GreenBin is committed to protecting your personal data. We collect pickup scheduling information, addresses, and waste diverted statistics exclusively to coordinate community recycling collections and report collective environmental impact. Your address is only shared with verified collection crews during active collection windows.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using GreenBin, you agree to place only acceptable, pre-sorted, and cleaned recyclable materials into designated collection receptacles. Hazardous or contaminated materials may result in collection refusal to protect crew safety and processing facilities.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 28.0 : 16.0,
                    vertical: 20.0,
                  ),
                  children: [
                    // Section 1: Notifications
                    _buildSectionHeader('Pickup Notifications'),
                    _buildSettingsCard(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Pickup Reminders',
                          subtitle: 'Receive alerts prior to your collection window',
                          value: _pickupReminders,
                          onChanged: _onPickupRemindersChanged,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          icon: Icons.sync_rounded,
                          title: 'Status Updates',
                          subtitle: 'Alerts when collection crew is en route',
                          value: _statusUpdates,
                          onChanged: _onStatusUpdatesChanged,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          icon: Icons.eco_outlined,
                          title: 'Milestone Alerts',
                          subtitle: 'Celebrate diverted waste milestones and badges',
                          value: _milestoneAlerts,
                          onChanged: _onMilestoneAlertsChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Preferences
                    _buildSectionHeader('Preferences'),
                    _buildSettingsCard(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.access_time_rounded,
                              color: AppColors.primary),
                          title: Text(
                            'Reminder Timing',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _reminderWindow,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: DropdownButton<String>(
                            value: _reminderWindow,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                value: '2 hours before',
                                child: Text('2 hours before'),
                              ),
                              DropdownMenuItem(
                                value: '1 day before',
                                child: Text('1 day before'),
                              ),
                              DropdownMenuItem(
                                value: '2 days before',
                                child: Text('2 days before'),
                              ),
                            ],
                            onChanged: _onReminderWindowChanged,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          icon: Icons.volume_up_outlined,
                          title: 'Sound & Vibration',
                          subtitle: 'Play sound for critical pickup notifications',
                          value: _soundAndVibrate,
                          onChanged: _onSoundAndVibrateChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Security & Account
                    _buildSectionHeader('Security & Account'),
                    _buildSettingsCard(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.primary),
                          title: Text(
                            'Change Password',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Update your GreenBin account security password',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.changePassword);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined,
                              color: AppColors.primary),
                          title: Text(
                            'Privacy Policy',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                          onTap: _showPrivacyPolicy,
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.description_outlined,
                              color: AppColors.primary),
                          title: Text(
                            'Terms of Service',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                          onTap: _showTermsOfService,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Support & About
                    _buildSectionHeader('Support & About'),
                    _buildSettingsCard(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.help_outline_rounded,
                              color: AppColors.primary),
                          title: Text(
                            'Help & FAQ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Guides, recycling tips, and answers to common questions',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.helpFaq);
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded,
                              color: AppColors.primary),
                          title: Text(
                            'GreenBin Version',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            'v1.0.0 (Build 2026.1)',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          },
        );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surfaceLight,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        elevation: 0,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primaryContainer,
      thumbColor: const WidgetStatePropertyAll(AppColors.primary),
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

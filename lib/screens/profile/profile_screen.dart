import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/interactive_animations.dart';
import '../../widgets/stat_illustration.dart';

/// Screen displaying the resident's profile, environmental impact metrics,
/// account information, and navigation to settings, edit profile, and support.
///
/// Responsive Behavior:
/// - MOBILE (<700px): Single-column profile layout.
/// - TABLET (700px - 999px): Centered profile content with constrained maximum width (max-width: 680px).
/// - DESKTOP (>=1000px): Centered maximum width container (max-width: 960px) with balanced 2-column layout.
class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;
  final UserModel? initialUser;
  final Stream<UserModel?>? userStream;

  const ProfileScreen({
    super.key,
    this.isEmbedded = false,
    this.initialUser,
    this.userStream,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  UserModel? _localUser;

  @override
  void initState() {
    super.initState();
    _localUser = widget.initialUser;
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of GreenBin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = _authService.currentUser;
    final userId = _localUser?.id ?? authUser?.uid ?? '';

    // 1. Unauthenticated State
    if (userId.isEmpty && widget.userStream == null && _localUser == null) {
      return _wrapScaffold(
        context,
        _buildUnauthenticatedState(context),
      );
    }

    final effectiveStream = widget.userStream ??
        (_localUser != null
            ? Stream.value(_localUser)
            : _firestoreService.streamUserProfile(userId));

    return StreamBuilder<UserModel?>(
      stream: effectiveStream,
      initialData: _localUser,
      builder: (context, snapshot) {
        // 2. Loading State
        if (snapshot.connectionState == ConnectionState.waiting && _localUser == null) {
          return _wrapScaffold(
            context,
            const LoadingState(
              message: 'Loading your profile from Cloud Firestore...',
              size: 36,
            ),
          );
        }

        // 3. Error State
        if (snapshot.hasError) {
          return _wrapScaffold(
            context,
            _buildErrorState(context, snapshot.error!),
          );
        }

        final profile = snapshot.data ?? _localUser;

        // 4. Empty State
        if (profile == null) {
          return _wrapScaffold(
            context,
            _buildEmptyProfileState(context),
          );
        }

        // 5. Success State
        final displayName = profile.name.isNotEmpty
            ? profile.name
            : (authUser?.displayName ?? 'Community Resident');
        final email = profile.email.isNotEmpty
            ? profile.email
            : (authUser?.email ?? 'No email');
        final phone = profile.phone.isNotEmpty
            ? profile.phone
            : 'Not set';
        final address = profile.fullAddress;

        final content = LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width >= 1000) {
              return _buildDesktopLayout(
                profile: profile,
                displayName: displayName,
                email: email,
                phone: phone,
                address: address,
              );
            } else if (width >= 700) {
              return _buildTabletLayout(
                profile: profile,
                displayName: displayName,
                email: email,
                phone: phone,
                address: address,
              );
            } else {
              return _buildMobileLayout(
                profile: profile,
                displayName: displayName,
                email: email,
                phone: phone,
                address: address,
              );
            }
          },
        );

        return _wrapScaffold(context, content);
      },
    );
  }

  Widget _wrapScaffold(BuildContext context, Widget body) {
    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: body),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ResponsiveContainer(
            maxWidth: AppBreakpoints.maxFormWidth,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sign In to View Profile',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please log in to your GreenBin account to view your environmental footprint, manage personal settings, and track collection history.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
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
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
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
                'Unable to Load Profile',
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

  Widget _buildEmptyProfileState(BuildContext context) {
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
                  Icons.person_add_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Not Set Up',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your profile details have not been saved to Cloud Firestore yet.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: PrimaryButton(
                  text: 'Complete Profile',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profileSetup);
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
  // MOBILE LAYOUT (<700px): Single-Column Profile Layout
  // ===========================================================================
  Widget _buildMobileLayout({
    required UserModel? profile,
    required String displayName,
    required String email,
    required String phone,
    required String address,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFadeSlide(
            duration: const Duration(milliseconds: 220),
            offsetDistance: 6,
            child: _buildAvatarCard(profile, displayName, email),
          ),
          const SizedBox(height: 16),
          AppFadeSlide(
            duration: const Duration(milliseconds: 260),
            offsetDistance: 6,
            child: _buildEnvironmentalImpactCard(profile),
          ),
          const SizedBox(height: 16),
          AppFadeSlide(
            duration: const Duration(milliseconds: 300),
            offsetDistance: 6,
            child: _buildContactDetailsCard(phone, address),
          ),
          const SizedBox(height: 20),
          AppFadeSlide(
            duration: const Duration(milliseconds: 340),
            offsetDistance: 6,
            child: _buildActionList(),
          ),
          const SizedBox(height: 24),
          _buildSignOutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // TABLET LAYOUT (700px-999px): Centered Constrained Profile Content
  // ===========================================================================
  Widget _buildTabletLayout({
    required UserModel? profile,
    required String displayName,
    required String email,
    required String phone,
    required String address,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFadeSlide(
                duration: const Duration(milliseconds: 220),
                offsetDistance: 6,
                child: _buildAvatarCard(profile, displayName, email),
              ),
              const SizedBox(height: 18),
              AppFadeSlide(
                duration: const Duration(milliseconds: 260),
                offsetDistance: 6,
                child: _buildEnvironmentalImpactCard(profile),
              ),
              const SizedBox(height: 18),
              AppFadeSlide(
                duration: const Duration(milliseconds: 300),
                offsetDistance: 6,
                child: _buildContactDetailsCard(phone, address),
              ),
              const SizedBox(height: 24),
              AppFadeSlide(
                duration: const Duration(milliseconds: 340),
                offsetDistance: 6,
                child: _buildActionList(),
              ),
              const SizedBox(height: 24),
              _buildSignOutButton(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP LAYOUT (>=1000px): Centered Maximum-Width Balanced 2-Column Layout
  // ===========================================================================
  Widget _buildDesktopLayout({
    required UserModel? profile,
    required String displayName,
    required String email,
    required String phone,
    required String address,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Avatar & Basic Info, Environmental Impact
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    AppFadeSlide(
                      duration: const Duration(milliseconds: 220),
                      offsetDistance: 6,
                      child: _buildAvatarCard(profile, displayName, email),
                    ),
                    const SizedBox(height: 20),
                    AppFadeSlide(
                      duration: const Duration(milliseconds: 280),
                      offsetDistance: 6,
                      child: _buildEnvironmentalImpactCard(profile),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Contact Details, Actions & Settings, Sign Out
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    AppFadeSlide(
                      duration: const Duration(milliseconds: 260),
                      offsetDistance: 6,
                      child: _buildContactDetailsCard(phone, address),
                    ),
                    const SizedBox(height: 20),
                    AppFadeSlide(
                      duration: const Duration(milliseconds: 320),
                      offsetDistance: 6,
                      child: _buildActionList(),
                    ),
                    const SizedBox(height: 24),
                    _buildSignOutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-COMPONENTS: AVATAR CARD, IMPACT CARD, CONTACT CARD, ACTIONS
  // ===========================================================================

  Widget _buildAvatarCard(
      UserModel? profile, String displayName, String email) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.borderLight,
          width: 1.0,
        ),
      ),
      color: AppColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'G',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verified Resident Member',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.dividerLight),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editProfile,
                      arguments: profile,
                    ).then((updated) {
                      if (updated is UserModel) {
                        setState(() => _localUser = updated);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(UserModel? profile) {
    final totalPickups = profile?.totalPickups ?? 0;
    final zeroWasteLevel = (totalPickups ~/ 3) + 1;
    final zeroWasteRank = totalPickups >= 10
        ? 'Eco Master'
        : totalPickups >= 5
            ? 'Eco Champion'
            : 'Eco Explorer';
    final pickupsInLevel = totalPickups % 3;
    final pickupsNeeded = 3 - pickupsInLevel;
    final levelProgress = (pickupsInLevel / 3.0).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.borderLight,
          width: 1.0,
        ),
      ),
      color: AppColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                color: AppColors.primary,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your Environmental Footprint',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              label: 'Recycling Pickups',
                              value: '$totalPickups',
                              icon: Icons.local_shipping_outlined,
                              illustrationType: StatIllustrationType.pickups,
                              subtitle: 'Completed',
                              accentColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              label: 'Zero-Waste Rank',
                              value: 'Level $zeroWasteLevel',
                              icon: Icons.military_tech_rounded,
                              illustrationType:
                                  StatIllustrationType.zeroWasteRank,
                              subtitle: zeroWasteRank,
                              accentColor: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Next: Level ${zeroWasteLevel + 1}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$pickupsNeeded to level up',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: levelProgress,
                              minHeight: 6,
                              backgroundColor: AppColors.borderLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetailsCard(String phone, String address) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      color: AppColors.surfaceLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account & Contact Details',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              value: phone,
            ),
            const Divider(height: 24, color: AppColors.dividerLight),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              title: 'Default Address',
              value: address,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionList() {
    return Material(
      color: AppColors.surfaceLight,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      elevation: 0,
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.edit_note_rounded,
            title: 'Edit Profile Information',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
          const Divider(height: 1, indent: 52),
          _buildNavigationTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          const Divider(height: 1, indent: 52),
          _buildNavigationTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changePassword);
            },
          ),
          const Divider(height: 1, indent: 52),
          _buildNavigationTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & FAQ',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.helpFaq);
            },
          ),
          const Divider(height: 1, indent: 52),
          _buildNavigationTile(
            icon: Icons.palette_outlined,
            title: 'Design System Showcase',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.designSystem);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton() {
    return SecondaryButton(
      text: 'Log Out',
      icon: Icons.logout_rounded,
      textColor: AppColors.statusCancelled,
      borderColor: AppColors.statusCancelled,
      onPressed: _handleSignOut,
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    StatIllustrationType? illustrationType,
    String? subtitle,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.primary;
    return InteractiveBounce(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.16),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: color),
                if (illustrationType != null)
                  StatIllustration(
                    type: illustrationType,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
    );
  }
}

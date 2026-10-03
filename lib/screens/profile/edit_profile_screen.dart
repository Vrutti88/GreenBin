import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Screen allowing residents to edit their personal information and default address.
///
/// Responsive Behavior:
/// - MOBILE (<600px): Single-column full-width form.
/// - TABLET / DESKTOP (>=600px): Centered constrained form with 2-column fields where appropriate.
class EditProfileScreen extends StatefulWidget {
  final UserModel? initialUser;

  const EditProfileScreen({super.key, this.initialUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _landmarkController;

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.initialUser;

    _nameController = TextEditingController(text: _currentUser?.fullName ?? '');
    _phoneController =
        TextEditingController(text: _currentUser?.phoneNumber ?? '');
    _streetController = TextEditingController(text: _currentUser?.street ?? '');
    _cityController = TextEditingController(text: _currentUser?.city ?? '');
    _postalCodeController =
        TextEditingController(text: _currentUser?.postalCode ?? '');
    _landmarkController =
        TextEditingController(text: _currentUser?.landmark ?? '');

    if (_currentUser == null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final user = await _firestoreService.getUserProfile(uid);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.fullName;
          _phoneController.text = user.phoneNumber;
          _streetController.text = user.street;
          _cityController.text = user.city;
          _postalCodeController.text = user.postalCode;
          _landmarkController.text = user.landmark;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final uid = _currentUser?.id ?? _authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to update your profile.'),
            backgroundColor: AppColors.statusCancelled,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final email = _currentUser?.email ?? _authService.currentUser?.email ?? '';

    final updatedUser = UserModel(
      id: uid,
      email: email,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      landmark: _landmarkController.text.trim(),
      totalPickups: _currentUser?.totalPickups ?? 0,
      kgRecycled: _currentUser?.kgRecycled ?? 0.0,
      createdAt: _currentUser?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _firestoreService.saveUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.statusCompleted,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.statusCancelled,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = _authService.currentUser;
    final uid = _currentUser?.id ?? authUser?.uid;

    if (uid == null || uid.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
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
                      'Sign In Required',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please log in to your GreenBin account to view and update your personal profile details.',
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
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: SecondaryButton(
                        text: 'Back',
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32.0 : 20.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section: Personal Details
                        Text(
                          'Personal Details',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Phone Number',
                          hint: 'e.g. +1 (555) 019-2834',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Section: Default Collection Address
                        Text(
                          'Default Collection Address',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Street Address',
                          hint: 'e.g. 100 Green View Road',
                          controller: _streetController,
                          prefixIcon: Icons.location_on_outlined,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your street address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Landmark (Optional)',
                          hint: 'e.g. Near Solar Park Gate / Apt 4B',
                          controller: _landmarkController,
                          prefixIcon: Icons.near_me_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Two-column fields on Tablet/Desktop, Single-column on Mobile
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: AppTextField(
                                  label: 'City / Municipality',
                                  hint: 'e.g. Metro City / Ward',
                                  controller: _cityController,
                                  prefixIcon: Icons.location_city_outlined,
                                  isRequired: true,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your city';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: AppTextField(
                                  label: 'Postal Code',
                                  hint: 'e.g. 10001',
                                  controller: _postalCodeController,
                                  prefixIcon: Icons.markunread_mailbox_outlined,
                                  isRequired: true,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          )
                        else ...[
                          AppTextField(
                            label: 'City / Municipality',
                            hint: 'e.g. Metro City / Ward',
                            controller: _cityController,
                            prefixIcon: Icons.location_city_outlined,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Postal Code',
                            hint: 'e.g. 10001',
                            controller: _postalCodeController,
                            prefixIcon: Icons.markunread_mailbox_outlined,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your postal code';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 36),

                        // Action Buttons
                        PrimaryButton(
                          text: 'Save Changes',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleSave,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

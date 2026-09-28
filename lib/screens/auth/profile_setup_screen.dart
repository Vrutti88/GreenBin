import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/widgets.dart';

/// Screen 8: Profile Setup
/// Allows resident to configure their community address and pickup instructions.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _unitController = TextEditingController();
  final _cityController = TextEditingController(text: 'Springfield');
  final _postalCodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  String _housingType = 'Apartment';
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _housingTypes = [
    {'type': 'Apartment', 'icon': Icons.apartment_rounded},
    {'type': 'House', 'icon': Icons.home_rounded},
    {'type': 'Villa', 'icon': Icons.villa_rounded},
    {'type': 'Gated Community', 'icon': Icons.holiday_village_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _unitController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      if (_nameController.text.isEmpty && user.displayName != null) {
        _nameController.text = user.displayName!;
      }
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          if (profile.fullName.isNotEmpty) _nameController.text = profile.fullName;
          if (profile.phoneNumber.isNotEmpty) _phoneController.text = profile.phoneNumber;
          if (profile.street.isNotEmpty) _streetController.text = profile.street;
          if (profile.city.isNotEmpty) _cityController.text = profile.city;
          if (profile.postalCode.isNotEmpty) _postalCodeController.text = profile.postalCode;
          if (profile.landmark.isNotEmpty) _landmarkController.text = profile.landmark;
        });
      }
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'No authenticated user found. Please log in.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final existing = await _firestoreService.getUserProfile(user.uid);

      final combinedStreet = _unitController.text.trim().isNotEmpty
          ? '${_unitController.text.trim()}, ${_streetController.text.trim()}'
          : _streetController.text.trim();

      final updated = (existing ?? UserModel(
        id: user.uid,
        email: user.email ?? '',
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        street: combinedStreet,
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        landmark: '$_housingType • ${_landmarkController.text.trim()}',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveUserProfile(updated);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ResponsiveContainer(
              maxWidth: 780,
              child: Card(
                elevation: context.isMobile ? 0 : 1,
                color: context.isMobile
                    ? Colors.transparent
                    : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: context.isMobile
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.isMobile ? 8.0 : 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_pin_circle_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Complete Profile Setup',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Set your community address for seamless doorstep pickups',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (_errorMessage != null) ...[
                          ErrorState(message: _errorMessage!, isCard: true),
                          const SizedBox(height: 20),
                        ],

                        // Responsive Grid: 2-column on desktop/tablet, single-column on mobile
                        ResponsiveBuilder(
                          builder: (context, constraints, deviceType) {
                            final isDesktopOrTablet =
                                deviceType != DeviceScreenType.mobile;

                            if (isDesktopOrTablet) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column: Identity & Housing Type
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildContactSection(),
                                        const SizedBox(height: 20),
                                        _buildHousingTypeSection(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  // Right Column: Address Details
                                  Expanded(
                                    child: _buildAddressSection(),
                                  ),
                                ],
                              );
                            }

                            // Mobile Single Column
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildContactSection(),
                                const SizedBox(height: 20),
                                _buildHousingTypeSection(),
                                const SizedBox(height: 20),
                                _buildAddressSection(),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        PrimaryButton(
                          text: 'Save & Enter GreenBin',
                          icon: Icons.check_circle_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleSaveProfile,
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.home);
                            },
                            child: Text(
                              'Skip for now (I will configure this later)',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Resident Information',
          subtitle: 'Your primary contact details for pickup updates',
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _nameController,
          label: 'Full Name',
          isRequired: true,
          hint: 'e.g. Eleanor Vance',
          prefixIcon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your full name.' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _phoneController,
          label: 'Contact Phone Number',
          isRequired: true,
          hint: 'e.g. +1 555-0192',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your phone number.' : null,
        ),
      ],
    );
  }

  Widget _buildHousingTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Residence Type',
          subtitle: 'Helps our crew plan collection access',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _housingTypes.map((item) {
            final type = item['type'] as String;
            final icon = item['icon'] as IconData;
            final isSelected = _housingType == type;

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(type),
                ],
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _housingType = type);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Pickup Address',
          subtitle: 'Where should recyclables be picked up?',
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _streetController,
          label: 'Street Address',
          isRequired: true,
          hint: 'e.g. 742 Evergreen Terrace',
          prefixIcon: Icons.home_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your street address.' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _unitController,
          label: 'Apartment, Suite or Unit # (Optional)',
          hint: 'e.g. Apt 4B / Block C',
          prefixIcon: Icons.tag_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: _cityController,
                label: 'City / Community',
                isRequired: true,
                hint: 'Springfield',
                prefixIcon: Icons.location_city_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'City required.' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _postalCodeController,
                label: 'ZIP Code',
                hint: '12345',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _landmarkController,
          label: 'Landmark / Gate Instructions',
          hint: 'e.g. Opposite Community Park / Yellow Gate',
          prefixIcon: Icons.flag_outlined,
        ),
      ],
    );
  }
}

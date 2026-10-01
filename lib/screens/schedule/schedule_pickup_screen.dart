import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/time_slot_selector.dart';
import '../../widgets/interactive_animations.dart';

/// Responsive Schedule Pickup Screen utilizing Flutter Form, field validators,
/// adaptive LayoutBuilder layouts (mobile single-column, tablet/desktop balanced two-column),
/// touch-friendly date & time controls, and Cloud Firestore persistence.
class SchedulePickupScreen extends StatefulWidget {
  final String? initialCategory;
  final bool isEmbedded;

  const SchedulePickupScreen({
    super.key,
    this.initialCategory,
    this.isEmbedded = false,
  });

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  static const List<String> requiredTimeSlots = [
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
  ];

  late String _selectedCategory;
  final List<String> _selectedSubcategories = [];
  DateTime? _selectedDate;
  String _selectedTimeSlot = requiredTimeSlots.first;

  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final matchedCat = WasteCategoryItem.findByNameOrId(widget.initialCategory);
    _selectedCategory = matchedCat?.name ??
        WasteCategoryItem.defaultCategories.first.name;
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _loadUserProfileAddress();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfileAddress() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final user = await _firestoreService.getUserProfile(uid);
    if (user != null && mounted) {
      setState(() {
        if (_streetController.text.isEmpty && user.street.isNotEmpty) {
          _streetController.text = user.street;
        }
        if (_landmarkController.text.isEmpty && user.landmark.isNotEmpty) {
          _landmarkController.text = user.landmark;
        }
        if (_cityController.text.isEmpty && user.city.isNotEmpty) {
          _cityController.text = user.city;
        }
      });
    }
  }

  WasteCategoryItem get _activeCategoryItem {
    return WasteCategoryItem.defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCategory.toLowerCase(),
      orElse: () => WasteCategoryItem.defaultCategories.first,
    );
  }

  bool _isDateInPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(date.year, date.month, date.day);
    return candidate.isBefore(today);
  }

  bool _isSlotInPast(DateTime? date, String slot) {
    if (date == null) return false;
    final now = DateTime.now();
    final candidateDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (candidateDay.isBefore(today)) return true;
    if (candidateDay.isAfter(today)) return false;

    // Today: evaluate start time of the slot window
    final (start, _) = PreferencesService().parseSlotWindow(date, slot);
    return now.isAfter(start);
  }

  bool _areAllSlotsInPast(DateTime? date) {
    if (date == null) return false;
    return requiredTimeSlots.every((s) => _isSlotInPast(date, s));
  }

  DateTime get _earliestSelectableDate {
    final now = DateTime.now();
    if (_areAllSlotsInPast(now)) {
      return now.add(const Duration(days: 1));
    }
    return now;
  }

  Future<void> _handleSchedulePickup() async {
    // Validate all form fields
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please complete all required fields correctly.';
      });
      return;
    }

    // Additional strict validation: Date must not be in past
    if (_selectedDate == null) {
      setState(() => _errorMessage = 'Please select a preferred pickup date.');
      return;
    }

    if (_isDateInPast(_selectedDate!)) {
      setState(() => _errorMessage = 'Pickup date cannot be in the past.');
      return;
    }

    // Additional strict validation: Time slot required and not in past
    if (_selectedTimeSlot.isEmpty ||
        !requiredTimeSlots.contains(_selectedTimeSlot)) {
      setState(() => _errorMessage = 'Please select a valid time slot.');
      return;
    }

    if (_isSlotInPast(_selectedDate, _selectedTimeSlot)) {
      setState(() => _errorMessage =
          'The selected collection window has already passed. Please choose an upcoming slot or date.');
      return;
    }

    // Additional strict validation: Address required
    if (_streetController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your street address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      final userId = user?.uid ?? 'guest-resident';
      final userProfile = user != null
          ? await _firestoreService.getUserProfile(user.uid)
          : null;

      final pickup = PickupModel(
        id: '', // Generated by Firestore
        userId: userId,
        residentName:
            userProfile?.fullName ?? user?.displayName ?? 'Community Resident',
        residentPhone: userProfile?.phoneNumber ?? '',
        category: _selectedCategory,
        subCategories: _selectedSubcategories,
        pickupDate: _selectedDate!,
        timeSlot: _selectedTimeSlot,
        street: _streetController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : 'Community Area',
        landmark: _landmarkController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        status: PickupStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createPickup(pickup);

      if (!mounted) return;
      _showSuccessDialog(pickup);
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

  Future<void> _handleReviewPickup() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please complete all required fields correctly.');
      return;
    }
    if (_isSlotInPast(_selectedDate, _selectedTimeSlot)) {
      setState(() => _errorMessage =
          'The selected collection window has already passed. Please choose an upcoming slot or date.');
      return;
    }
    if (_streetController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your street address.');
      return;
    }

    final user = _authService.currentUser;
    final userId = user?.uid ?? 'guest-resident';
    final userProfile = user != null
        ? await _firestoreService.getUserProfile(user.uid)
        : null;

    final pickup = PickupModel(
      id: '',
      userId: userId,
      residentName:
          userProfile?.fullName ?? user?.displayName ?? 'Community Resident',
      residentPhone: userProfile?.phoneNumber ?? '',
      category: _selectedCategory,
      wasteCategory: _selectedCategory,
      subCategories: _selectedSubcategories,
      pickupDate: _selectedDate!,
      timeSlot: _selectedTimeSlot,
      street: _streetController.text.trim(),
      address: _streetController.text.trim(),
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : 'Community Area',
      landmark: _landmarkController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      status: PickupStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.reviewPickup, arguments: pickup);
  }

  void _showSuccessDialog(PickupModel pickup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formattedDate =
            DateFormat('EEEE, MMM d, yyyy').format(pickup.pickupDate);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pickup Scheduled!',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recyclable waste collection request has been saved and dispatched to the community collection team.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        Icons.recycling_rounded,
                        'Category',
                        pickup.category,
                      ),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        Icons.calendar_month_rounded,
                        'Date',
                        formattedDate,
                      ),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        Icons.access_time_rounded,
                        'Time',
                        pickup.timeSlot,
                      ),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        Icons.location_on_outlined,
                        'Address',
                        pickup.street,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'View in My Pickups',
                  icon: Icons.inventory_2_outlined,
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  text: 'Schedule Another Pickup',
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSubcategories.clear();
                      _notesController.clear();
                      _selectedDate =
                          DateTime.now().add(const Duration(days: 1));
                    });
                  },
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text('View Full Confirmation Details'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.pickupConfirmation,
                      arguments: pickup,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ResponsiveContainer(
            maxWidth: AppBreakpoints.maxContentWidth,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusCancelledBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.statusCancelled
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.statusCancelled,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.statusCancelled,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Adaptive Form Layout using LayoutBuilder
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      // =======================================================
                      // DESKTOP (width >= 1000): Balanced Two-Column Constrained
                      // =======================================================
                      if (width >= 1000) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Section (flex 3): Category, Items & Date/Time
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCategoryFormField(),
                                  const SizedBox(height: 24),
                                  _buildSubcategoriesSelector(),
                                  const SizedBox(height: 24),
                                  _buildDateTimeFormFields(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),

                            // Right Section (flex 2): Address, Notes & Summary Action Card
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAddressSection(),
                                  const SizedBox(height: 24),
                                  _buildNotesSection(),
                                  const SizedBox(height: 24),
                                  _buildDesktopLiveSummaryCard(),
                                  const SizedBox(height: 24),
                                  PrimaryButton(
                                    text: 'Confirm & Schedule Pickup',
                                    icon: Icons.calendar_month_rounded,
                                    isLoading: _isLoading,
                                    onPressed: _handleSchedulePickup,
                                  ),
                                  const SizedBox(height: 12),
                                  SecondaryButton(
                                    text: 'Review Pickup Details',
                                    icon: Icons.rate_review_outlined,
                                    onPressed: _handleReviewPickup,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // =======================================================
                      // TABLET (750 <= width < 1000): Centered Two-Column
                      // =======================================================
                      if (width >= 750) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column 1: Categories & Timing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCategoryFormField(),
                                  const SizedBox(height: 20),
                                  _buildSubcategoriesSelector(),
                                  const SizedBox(height: 20),
                                  _buildDateTimeFormFields(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Column 2: Address, Notes & Submit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAddressSection(),
                                  const SizedBox(height: 20),
                                  _buildNotesSection(),
                                  const SizedBox(height: 28),
                                  PrimaryButton(
                                    text: 'Confirm & Schedule Pickup',
                                    icon: Icons.calendar_month_rounded,
                                    isLoading: _isLoading,
                                    onPressed: _handleSchedulePickup,
                                  ),
                                  const SizedBox(height: 12),
                                  SecondaryButton(
                                    text: 'Review Pickup Details',
                                    icon: Icons.rate_review_outlined,
                                    onPressed: _handleReviewPickup,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // =======================================================
                      // MOBILE & COMPACT TABLET (< 750): Single-Column Full-Width Flow
                      // =======================================================
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryFormField(),
                          const SizedBox(height: 22),
                          _buildSubcategoriesSelector(),
                          const SizedBox(height: 22),
                          _buildDateTimeFormFields(),
                          const SizedBox(height: 22),
                          _buildAddressSection(),
                          const SizedBox(height: 22),
                          _buildNotesSection(),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            text: 'Confirm & Schedule Pickup',
                            icon: Icons.calendar_month_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleSchedulePickup,
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            text: 'Review Pickup Details',
                            icon: Icons.rate_review_outlined,
                            onPressed: _handleReviewPickup,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );

    if (widget.isEmbedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Waste Pickup'),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: content),
    );
  }

  // =========================================================================
  // FORM FIELD 1: WASTE CATEGORY SELECTOR WITH VALIDATION
  // =========================================================================
  Widget _buildCategoryFormField() {
    return FormField<String>(
      initialValue: _selectedCategory,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a waste category.';
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    '1. Select Recyclable Category',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WasteCategoryItem.defaultCategories.map((cat) {
                final isSelected =
                    _selectedCategory.toLowerCase() == cat.name.toLowerCase();
                return InteractiveBounce(
                  child: ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 18,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: cat.color,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? cat.color : AppColors.borderLight,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat.name;
                          _selectedSubcategories.clear();
                        });
                        state.didChange(cat.name);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // =========================================================================
  // HELPER: ITEMS / SUBCATEGORIES CHECKLIST
  // =========================================================================
  Widget _buildSubcategoriesSelector() {
    final active = _activeCategoryItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Accepted Items in Batch (Optional)',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the specific items you are placing for collection:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: active.acceptedItems.map((item) {
            final isSelected = _selectedSubcategories.contains(item);
            return InteractiveBounce(
              child: FilterChip(
                label: Text(item),
                selected: isSelected,
                selectedColor: active.color.withValues(alpha: 0.15),
                checkmarkColor: active.color,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? active.color : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSubcategories.add(item);
                    } else {
                      _selectedSubcategories.remove(item);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =========================================================================
  // FORM FIELDS 2 & 3: DATE & TIME WINDOW WITH VALIDATION
  // =========================================================================
  Widget _buildDateTimeFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Pickup Date FormField
        FormField<DateTime>(
          initialValue: _selectedDate,
          validator: (date) {
            if (date == null) {
              return 'Please select a preferred pickup date.';
            }
            if (_isDateInPast(date)) {
              return 'Pickup date cannot be in the past.';
            }
            return null;
          },
          builder: (dateState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '3. Pickup Date',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                DateSelector(
                  label: null,
                  selectedDate: _selectedDate,
                  firstDate: _earliestSelectableDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      if (_isSlotInPast(date, _selectedTimeSlot)) {
                        final available = requiredTimeSlots
                            .where((s) => !_isSlotInPast(date, s))
                            .toList();
                        _selectedTimeSlot =
                            available.isNotEmpty ? available.first : '';
                      }
                    });
                    dateState.didChange(date);
                  },
                ),
                if (dateState.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    dateState.errorText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // 3. Time Slot FormField
        FormField<String>(
          initialValue: _selectedTimeSlot,
          validator: (slot) {
            if (slot == null || slot.trim().isEmpty) {
              return 'Please select a collection time window.';
            }
            if (!requiredTimeSlots.contains(slot)) {
              return 'Please choose one of the available time windows.';
            }
            if (_isSlotInPast(_selectedDate, slot)) {
              return 'This time slot has already passed. Please select an upcoming slot.';
            }
            return null;
          },
          builder: (slotState) {
            final allPassed = _selectedDate != null &&
                _areAllSlotsInPast(_selectedDate!);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Preferred Time Slot',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TimeSlotSelector(
                  label: null,
                  availableSlots: requiredTimeSlots,
                  selectedSlot: _selectedTimeSlot,
                  isSlotDisabled: (slot) =>
                      _isSlotInPast(_selectedDate, slot),
                  onSlotSelected: (slot) {
                    setState(() => _selectedTimeSlot = slot);
                    slotState.didChange(slot);
                  },
                ),
                if (allPassed) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'All collection windows for today have ended. Please choose tomorrow or an upcoming date.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (slotState.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    slotState.errorText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // =========================================================================
  // FORM FIELD 4: ADDRESS SECTION WITH REQUIRED VALIDATION
  // =========================================================================
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '4. Pickup Address',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _streetController,
          label: 'Street Address, House / Unit #',
          hint: 'e.g. Flat 402, Green Valley Apartments, Oak Street',
          prefixIcon: Icons.home_outlined,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter your pickup street address.';
            }
            if (v.trim().length < 5) {
              return 'Please enter a complete street address.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _landmarkController,
          label: 'Landmark / Building Name (Optional)',
          hint: 'e.g. Near Community Center, Gate 2',
          prefixIcon: Icons.flag_outlined,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _cityController,
          label: 'City / Neighborhood',
          hint: 'e.g. Springfield',
          prefixIcon: Icons.location_city_outlined,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter your city or neighborhood.';
            }
            return null;
          },
        ),
      ],
    );
  }

  // =========================================================================
  // FORM FIELD 5: NOTES SECTION (OPTIONAL)
  // =========================================================================
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5. Notes for Collection Crew (Optional)',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide any gate code or collection placement notes:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: _notesController,
          hint:
              'e.g. Left in green bin near front porch; please buzz flat 402 on arrival.',
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // =========================================================================
  // DESKTOP LIVE SUMMARY CARD
  // =========================================================================
  Widget _buildDesktopLiveSummaryCard() {
    final active = _activeCategoryItem;
    final dateString = _selectedDate != null
        ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!)
        : 'Not selected';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              width: double.infinity,
              color: active.color,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pickup Summary',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSummaryRow(
                    active.icon,
                    'Category',
                    active.name,
                  ),
                  const Divider(height: 14),
                  _buildSummaryRow(
                    Icons.calendar_month_rounded,
                    'Date',
                    dateString,
                  ),
                  const Divider(height: 14),
                  _buildSummaryRow(
                    Icons.access_time_rounded,
                    'Time Window',
                    _selectedTimeSlot,
                  ),
                  const Divider(height: 14),
                  _buildSummaryRow(
                    Icons.volunteer_activism_rounded,
                    'Service Fee',
                    'Free Community Pickup',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

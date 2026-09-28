import 'package:flutter/material.dart';
import '../../models/pickup_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/widgets.dart';

/// Interactive showcase screen displaying all 16 GreenBin design system components
/// and verifying responsive layout behavior across all screen sizes.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  DateTime? _demoDate = DateTime.now().add(const Duration(days: 2));
  String _demoSlot = '09:00 AM - 12:00 PM';
  String _selectedCategory = 'Plastic';
  bool _isLoadingButton = false;

  final _textController = TextEditingController(text: '123 Green Valley Way');
  final _passwordController = TextEditingController(text: 'secretPassword123');

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System & Widgets'),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ResponsiveContainer(
            maxWidth: AppBreakpoints.maxContentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBanner(context),
                const SizedBox(height: 32),

                // 1. Theme & Color Palette
                _buildColorPaletteSection(),
                const SizedBox(height: 36),

                // 2. Typography Scale
                _buildTypographySection(),
                const SizedBox(height: 36),

                // 3 & 4. Primary & Secondary Buttons
                _buildButtonsSection(),
                const SizedBox(height: 36),

                // 5. Text Fields
                _buildTextFieldsSection(),
                const SizedBox(height: 36),

                // 6. Waste Category Cards
                _buildCategoryCardsSection(),
                const SizedBox(height: 36),

                // 7. Pickup Cards
                _buildPickupCardsSection(),
                const SizedBox(height: 36),

                // 8. Status Chips
                _buildStatusChipsSection(),
                const SizedBox(height: 36),

                // 9 & 10. Date & Time Slot Selectors
                _buildDateTimeSelectorsSection(),
                const SizedBox(height: 36),

                // 11. Section Header
                _buildSectionHeaderDemo(),
                const SizedBox(height: 36),

                // 12. Loading State
                _buildLoadingStateSection(),
                const SizedBox(height: 36),

                // 13. Empty State
                _buildEmptyStateSection(),
                const SizedBox(height: 36),

                // 14. Error State
                _buildErrorStateSection(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'GreenBin Design System',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Complete Material 3 component library built with adaptive responsiveness. '
            'Currently rendering for: ${context.deviceType.name.toUpperCase()} viewport '
            '(${context.screenWidth.toInt()} x ${context.screenHeight.toInt()}).',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '1. Brand & Semantic Colors',
          subtitle: 'Harmonious eco-green palette with contrast-tested status tokens.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorSwatch('Primary', AppColors.primary, '#1B5E20'),
            _buildColorSwatch('Primary Light', AppColors.primaryLight, '#2E7D32'),
            _buildColorSwatch('Soft Mint', AppColors.primaryContainer, '#E8F5E9', darkText: true),
            _buildColorSwatch('Secondary Teal', AppColors.secondary, '#00796B'),
            _buildColorSwatch('Amber Earth', AppColors.tertiary, '#D97706'),
            _buildColorSwatch('Pending', AppColors.statusPending, '#EA580C'),
            _buildColorSwatch('Confirmed', AppColors.statusConfirmed, '#0284C7'),
            _buildColorSwatch('In Transit', AppColors.statusInTransit, '#7C3AED'),
            _buildColorSwatch('Completed', AppColors.statusCompleted, '#16A34A'),
            _buildColorSwatch('Cancelled', AppColors.statusCancelled, '#DC2626'),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color color, String hex, {bool darkText = false}) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: darkText ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hex,
            style: AppTextStyles.labelSmall.copyWith(
              color: darkText
                  ? AppColors.textSecondary
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '2. Typography Hierarchy',
          subtitle: 'Proportional typescale ensuring readability on mobile and desktop.',
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large — 32pt Bold', style: AppTextStyles.displayLarge),
                SizedBox(height: 8),
                Text('Headline Medium — 20pt Semibold', style: AppTextStyles.headlineMedium),
                SizedBox(height: 8),
                Text('Title Large — 16pt Semibold', style: AppTextStyles.titleLarge),
                SizedBox(height: 8),
                Text('Body Medium — 14pt Regular for paragraphs and readable guidance',
                    style: AppTextStyles.bodyMedium),
                SizedBox(height: 8),
                Text('Label Small — 11pt Bold for metadata & status badges',
                    style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '3 & 4. Primary & Secondary Buttons',
          subtitle: 'Adaptive buttons with accessible targets, loading states, and overflow safety.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: PrimaryButton(
                text: 'Schedule Pickup',
                icon: Icons.calendar_today_rounded,
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                text: 'Loading Action',
                isLoading: _isLoadingButton,
                onPressed: () {
                  setState(() => _isLoadingButton = !_isLoadingButton);
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SecondaryButton(
                text: 'Cancel Pickup',
                icon: Icons.close_rounded,
                textColor: AppColors.statusCancelled,
                borderColor: AppColors.statusCancelled,
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: 180,
              child: SecondaryButton(
                text: 'Back to Home',
                icon: Icons.arrow_back_rounded,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '5. Text Fields',
          subtitle: 'Mobile-friendly inputs with keyboard scrolling, password toggle, and validation.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AppTextField(
                  controller: _textController,
                  label: 'Pickup Address',
                  isRequired: true,
                  hint: 'Enter your street address',
                  prefixIcon: Icons.home_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Security Password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  label: 'Special Notes',
                  hint: 'Optional notes for collection crew...',
                  maxLines: 2,
                  prefixIcon: Icons.notes_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '6. Waste Category Cards',
          subtitle: 'Interactive cards supporting selection states and responsive grid layouts.',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            childAspectRatio: 1.15,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final cat = WasteCategoryItem.defaultCategories[index];
            return CategoryCard(
              category: cat,
              isSelected: cat.name == _selectedCategory,
              onTap: () {
                setState(() => _selectedCategory = cat.name);
              },
            );
          },
        ),
        const SizedBox(height: 14),
        CategoryCard(
          category: WasteCategoryItem.defaultCategories[4], // E-waste
          isHorizontal: true,
          isSelected: _selectedCategory == 'E-Waste',
          onTap: () => setState(() => _selectedCategory = 'E-Waste'),
        ),
      ],
    );
  }

  Widget _buildPickupCardsSection() {
    final demoPending = PickupModel(
      id: 'demo-1',
      userId: 'user-1',
      residentName: 'Sarah Jenkins',
      residentPhone: '+1 555-0199',
      category: 'Plastic',
      subCategories: ['PET Bottles', 'Milk Jugs'],
      pickupDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '09:00 AM - 12:00 PM',
      street: '404 Evergreen Terrace',
      city: 'Springfield',
      status: PickupStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final demoConfirmed = demoPending.copyWith(
      id: 'demo-2',
      category: 'Paper & Cardboard',
      subCategories: ['Flattened Cartons'],
      status: PickupStatus.confirmed,
    );

    final demoCompleted = demoPending.copyWith(
      id: 'demo-3',
      category: 'Glass',
      subCategories: ['Clean Jars & Bottles'],
      status: PickupStatus.completed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '7. Pickup Cards',
          subtitle: 'Responsive card layouts adapting between single columns and multi-column grids.',
        ),
        const SizedBox(height: 12),
        ResponsiveBuilder(
          builder: (context, constraints, deviceType) {
            final isDesktop = deviceType == DeviceScreenType.desktop;
            if (isDesktop) {
              return Row(
                children: [
                  Expanded(child: PickupCard(pickup: demoPending)),
                  const SizedBox(width: 14),
                  Expanded(child: PickupCard(pickup: demoConfirmed)),
                  const SizedBox(width: 14),
                  Expanded(child: PickupCard(pickup: demoCompleted)),
                ],
              );
            }
            return Column(
              children: [
                PickupCard(pickup: demoPending),
                const SizedBox(height: 12),
                PickupCard(pickup: demoConfirmed),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusChipsSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '8. Status Chips',
          subtitle: 'Semantic badges representing every stage in the recycling pickup lifecycle.',
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            StatusChip(status: PickupStatus.pending),
            StatusChip(status: PickupStatus.confirmed),
            StatusChip(status: PickupStatus.inTransit),
            StatusChip(status: PickupStatus.completed),
            StatusChip(status: PickupStatus.cancelled),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '9 & 10. Date & Time-Slot Selectors',
          subtitle: 'Touch-optimized Material 3 calendar trigger and responsive chip wrap.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateSelector(
                  label: 'Select Date',
                  selectedDate: _demoDate,
                  onDateSelected: (date) => setState(() => _demoDate = date),
                ),
                const SizedBox(height: 16),
                TimeSlotSelector(
                  label: 'Select Preferred Window',
                  selectedSlot: _demoSlot,
                  onSlotSelected: (slot) => setState(() => _demoSlot = slot),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '11. Section Header',
          subtitle: 'Component used for standard section dividing with action shortcuts.',
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SectionHeader(
              title: 'Community Recycling News',
              subtitle: 'Stay updated with local drop-off dates and zero-waste initiatives.',
              actionText: 'Read More',
              onActionTap: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStateSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '12. Loading State',
          subtitle: 'Centered circular indicator with eco-color palette and helpful status messages.',
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: LoadingState(
              message: 'Syncing recyclable requests with Cloud Firestore...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '13. Empty State',
          subtitle: 'Engaging zero-data states with helpful guidance and call-to-action buttons.',
        ),
        const SizedBox(height: 12),
        Card(
          child: EmptyState(
            icon: Icons.recycling_rounded,
            title: 'No Pickups Scheduled',
            message: 'You currently have no pending recycling pickups. Tap below to schedule one.',
            actionText: 'Schedule First Pickup',
            actionIcon: Icons.add_rounded,
            onActionPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '14. Error State',
          subtitle: 'Graceful failure feedback with error diagnostics and retry options.',
        ),
        const SizedBox(height: 12),
        ErrorState(
          isCard: true,
          title: 'Unable to Connect to Firestore',
          message: 'Please check your internet connection and try reloading the pickups queue.',
          onRetry: () {},
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/pickup_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/waste_category_card.dart';

/// Waste Category Guide Screen: provides comprehensive recycling guidelines,
/// searchable materials, and responsive multi-view adaptations.
///
/// Responsive Behavior:
/// - Mobile: Single-column category cards (ListView)
/// - Tablet: 2-column category grid (GridView)
/// - Desktop: 3-column (or wider) responsive category grid (GridView)
///
/// Navigation Flow:
/// Guide → Category Details → Schedule Pickup (via named route arguments)
class WasteGuideScreen extends StatefulWidget {
  final bool isEmbedded;

  const WasteGuideScreen({super.key, this.isEmbedded = false});

  @override
  State<WasteGuideScreen> createState() => _WasteGuideScreenState();
}

class _WasteGuideScreenState extends State<WasteGuideScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterId = 'all';

  final List<Map<String, String>> _filterOptions = [
    {'id': 'all', 'label': 'All Materials'},
    {'id': 'plastic', 'label': 'Plastic'},
    {'id': 'paper', 'label': 'Paper & Cardboard'},
    {'id': 'glass', 'label': 'Glass'},
    {'id': 'metal', 'label': 'Metal'},
    {'id': 'ewaste', 'label': 'E-Waste'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WasteCategoryItem> get _filteredCategories {
    List<WasteCategoryItem> list = WasteCategoryItem.defaultCategories;

    // Filter by quick filter chip
    if (_selectedFilterId != 'all') {
      list = list.where((c) {
        if (_selectedFilterId == 'metal') {
          return c.id == 'metal' || c.name.toLowerCase().contains('metal');
        }
        return c.id.toLowerCase() == _selectedFilterId ||
            c.name.toLowerCase().contains(_selectedFilterId);
      }).toList();
    }

    // Filter by search query across name, description, and accepted items
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((c) {
        final nameMatch = c.name.toLowerCase().contains(q);
        final descMatch = c.description.toLowerCase().contains(q);
        final acceptedMatch =
            c.acceptedItems.any((item) => item.toLowerCase().contains(q));
        final rejectedMatch =
            c.rejectedItems.any((item) => item.toLowerCase().contains(q));
        return nameMatch || descMatch || acceptedMatch || rejectedMatch;
      }).toList();
    }

    return list;
  }

  void _navigateToCategoryDetails(WasteCategoryItem category) {
    Navigator.pushNamed(
      context,
      AppRoutes.categoryDetails,
      arguments: category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactHeight = screenHeight < 500;

    final content = ResponsiveContainer(
      maxWidth: AppBreakpoints.maxContentWidth,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveValue(
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
        vertical: isCompactHeight ? 6.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Introduction
          Text(
            'Recycling Category Guide',
            style: (isCompactHeight
                    ? AppTextStyles.titleMedium
                    : AppTextStyles.headlineSmall)
                .copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (!isCompactHeight) ...[
            const SizedBox(height: 4),
            Text(
              'Understand what items are accepted and how to prepare them for community collection.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: isCompactHeight ? 8 : 16),

          // Search Materials Text Field
          AppTextField(
            controller: _searchController,
            hint: 'Search materials (e.g. plastic bottle, cardboard box, aluminum can, battery)...',
            prefixIcon: Icons.search_rounded,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
          ),
          SizedBox(height: isCompactHeight ? 6 : 14),

          // Quick Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((opt) {
                final isSelected = _selectedFilterId == opt['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilterId = opt['id']!);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: isCompactHeight ? 8 : 20),

          // Main Responsive Categories Layout
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final categories = _filteredCategories;

                if (categories.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No recyclable materials found',
                    message:
                        'No category matches "$_searchQuery". Try another keyword or clear the search filter.',
                    actionText: 'Clear Search',
                    onActionPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedFilterId = 'all';
                      });
                    },
                  );
                }

                final width = constraints.maxWidth;

                // =======================================================
                // MOBILE (< 600): Single-Column Category Cards (ListView)
                // =======================================================
                if (width < 600) {
                  return ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return WasteCategoryCard(
                        category: category,
                        isSingleColumn: true,
                        onTap: () => _navigateToCategoryDetails(category),
                      );
                    },
                  );
                }

                // =======================================================
                // TABLET (600 - 999): 2-Column Responsive Category Grid
                // DESKTOP (>= 1000): 3-Column Responsive Category Grid
                final int crossAxisCount = width >= 1000 ? 3 : 2;
                final double aspectRatio = width >= 1000 ? 1.45 : 1.30;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return WasteCategoryCard(
                      category: category,
                      isSingleColumn: false,
                      onTap: () => _navigateToCategoryDetails(category),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Category Guide'),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: content),
    );
  }
}

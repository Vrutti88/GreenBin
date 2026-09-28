import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

/// Screen displaying searchable and categorized recycling and app FAQs.
///
/// Responsive Behavior:
/// - MOBILE (<600px): Single-column FAQ list with safe margins.
/// - TABLET / DESKTOP (>=600px): Centered maximum-width FAQ content (max-width: 760px).
class HelpFaqScreen extends StatefulWidget {
  final bool isEmbedded;
  const HelpFaqScreen({super.key, this.isEmbedded = false});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;
  final List<String> _categories = const [
    'All',
    'Scheduling',
    'Recycling',
    'Collection',
    'Account',
  ];

  static const List<FaqItem> _allFaqs = [
    FaqItem(
      category: 'Scheduling',
      question: 'How do I schedule a recyclable waste pickup?',
      answer:
          'Tap the "Schedule Pickup" button on your Home dashboard or Guide screen. Choose your recyclable waste category, select an available date and time slot, verify your address, and confirm the request.',
    ),
    FaqItem(
      category: 'Scheduling',
      question: 'Can I reschedule or cancel an existing pickup?',
      answer:
          'Yes! Open "My Pickups", tap on any scheduled collection, and select "Cancel Pickup Request". You can then book a new time slot that fits your schedule.',
    ),
    FaqItem(
      category: 'Recycling',
      question: 'What recyclable waste categories are accepted?',
      answer:
          'GreenBin collects five primary categories: Plastic (bottles, containers), Paper & Cardboard (boxes, newspapers), Glass (bottles, jars), Metal (aluminum cans, tins), and small E-Waste (gadgets, cables).',
    ),
    FaqItem(
      category: 'Recycling',
      question: 'Do I need to wash containers before collection?',
      answer:
          'Yes, please rinse all food and beverage containers before placing them out for collection. Clean materials prevent contamination and ensure efficient municipal processing.',
    ),
    FaqItem(
      category: 'Collection',
      question: 'Do I need to be home when the collection crew arrives?',
      answer:
          'Not necessarily. As long as your recyclable bins or bags are accessible at your designated collection point (e.g. doorstep or driveway), our crew can complete the pickup.',
    ),
    FaqItem(
      category: 'Collection',
      question: 'What happens to the collected recyclables?',
      answer:
          'All collected materials are transported to local municipal recovery centers where they are weighed, sorted, and routed to verified recycling plants, diverting thousands of kilograms from landfills.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How do I update my collection address or contact info?',
      answer:
          'Go to your Profile tab and tap "Edit Profile". You can update your street address, city, landmark, postal code, and phone number anytime.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How is my environmental impact calculated?',
      answer:
          'Every time our collection team verifies a completed pickup, the diverted weight in kilograms is added to your personal and community environmental milestones.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategory = _categories[_selectedCategoryIndex];

    return _allFaqs.where((faq) {
      final matchesCategory =
          selectedCategory == 'All' || faq.category == selectedCategory;
      final matchesQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Eco Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our community recycling coordinators are available Monday to Saturday, 8:00 AM – 6:00 PM.',
              style: TextStyle(height: 1.35),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('support@greenbin.eco',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Text('+1 (800) 555-GREEN',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
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
    final faqs = _filteredFaqs;

    final content = LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 28.0 : 16.0,
                    vertical: 20.0,
                  ),
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search FAQ questions & topics...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_categories.length, (index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_categories[index]),
                              selected: isSelected,
                              selectedColor: AppColors.primaryContainer,
                              labelStyle: AppTextStyles.labelMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
                                  setState(
                                      () => _selectedCategoryIndex = index);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // FAQ Accordion List
                    if (faqs.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No matching questions found',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching with different keywords or clear the category filter.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ...faqs.map((faq) => _buildFaqTile(faq)),
                    ],

                    const SizedBox(height: 28),

                    // Still need help card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.support_agent_rounded,
                                  color: AppColors.primary, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Still have questions?',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'Our Eco Support team is here to assist you.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                size: 18),
                            label: const Text('Contact Eco Support'),
                            onPressed: _showContactSupportDialog,
                          ),
                        ],
                      ),
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
        title: const Text('Help & FAQ'),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildFaqTile(FaqItem faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceLight,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        elevation: 0,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          childrenPadding:
              const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          title: Text(
            faq.question,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Text(
              faq.answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

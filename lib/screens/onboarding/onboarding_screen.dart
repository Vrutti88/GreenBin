import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/widgets.dart';

/// Screen 2, 3, 4: Onboarding Flow
/// - Slide 1: Recycle Smarter
/// - Slide 2: Schedule Easy Pickups
/// - Slide 3: Track Your Recycling
///
/// Fully responsive across small phones, tablets, landscape orientations, and wide desktops.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Recycle Smarter',
      'tagline': 'ZERO-WASTE COMMUNITY SORTING',
      'subtitle':
          'Access verified community recycling guidelines for plastics, paper, glass, metals, and electronics. Know exactly what goes into each bin to prevent contamination.',
      'icon': Icons.eco_rounded,
      'badge': 'Verified Guide',
      'highlights': [
        'Detailed accepted & prohibited lists',
        'Contamination prevention tips',
        'Material preparation guidelines',
      ],
    },
    {
      'title': 'Schedule Easy Pickups',
      'tagline': 'CONVENIENT DOORSTEP COLLECTION',
      'subtitle':
          'Select your recyclable categories, choose your preferred collection date and time window, and our community crew collects everything at your doorstep.',
      'icon': Icons.local_shipping_rounded,
      'badge': 'Doorstep Service',
      'highlights': [
        'Flexible morning, afternoon & evening slots',
        'Doorstep apartment & home collection',
        'Instant pickup confirmation & status tracking',
      ],
    },
    {
      'title': 'Track Your Recycling',
      'tagline': 'MEASURE COMMUNITY ENVIRONMENTAL IMPACT',
      'subtitle':
          'Watch your environmental footprint shrink. Monitor total kilograms diverted from landfills, celebrate zero-waste milestones, and keep our neighborhood clean.',
      'icon': Icons.public_rounded,
      'badge': 'Impact Metrics',
      'highlights': [
        'Real-time weight diverted tracking',
        'Community zero-waste milestones',
        'Personal eco-impact statistics',
      ],
    },
  ];

  Future<void> _completeOnboardingAndNavigate(String route) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, constraints, deviceType) {
            final isDesktop = deviceType == DeviceScreenType.desktop;

            return Center(
              child: ResponsiveContainer(
                maxWidth: isDesktop ? 900.0 : AppBreakpoints.maxFormWidth,
                child: isDesktop
                    ? _buildDesktopLayout(context)
                    : _buildMobileLayout(context, constraints),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Mobile and Tablet portrait/landscape layout
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final isCompactHeight = constraints.maxHeight < 560;

    return Column(
      children: [
        // Top App Bar row with Skip action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GreenBin',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _completeOnboardingAndNavigate(AppRoutes.login),
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Carousel Slider
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: isCompactHeight ? 6.0 : 12.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isCompactHeight ? 4 : 12),
                    // Centered Large Icon / Emblem
                    Container(
                      width: isCompactHeight ? 64 : 110,
                      height: isCompactHeight ? 64 : 110,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: isCompactHeight ? 10 : 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        slide['icon'] as IconData,
                        size: isCompactHeight ? 32 : 54,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 10 : 24),

                    // Tagline badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slide['tagline'] as String,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 8 : 14),

                    // Headline Title
                    Text(
                      slide['title'] as String,
                      textAlign: TextAlign.center,
                      style: (isCompactHeight
                              ? AppTextStyles.headlineSmall
                              : AppTextStyles.displaySmall)
                          .copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 6 : 12),

                    // Subtitle Body
                    Text(
                      slide['subtitle'] as String,
                      textAlign: TextAlign.center,
                      style: (isCompactHeight
                              ? AppTextStyles.bodySmall
                              : AppTextStyles.bodyMedium)
                          .copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    if (!isCompactHeight) ...[
                      const SizedBox(height: 20),
                      // Feature highlights list
                      Column(
                        children: (slide['highlights'] as List<String>).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Controls: Page Indicator & Action Buttons
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: isCompactHeight ? 6.0 : 12.0,
          ),
          child: Column(
            children: [
              // Animated Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompactHeight ? 10 : 20),

              // Action Buttons: side-by-side on wide compact landscape, stacked on normal portrait
              if (isCompactHeight && constraints.maxWidth > 380)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        text: _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        icon: _currentPage == _slides.length - 1
                            ? Icons.arrow_forward_rounded
                            : null,
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboardingAndNavigate(AppRoutes.register);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SecondaryButton(
                        text: 'Log In',
                        onPressed: () =>
                            _completeOnboardingAndNavigate(AppRoutes.login),
                      ),
                    ),
                  ],
                )
              else ...[
                PrimaryButton(
                  text: _currentPage == _slides.length - 1
                      ? 'Get Started with GreenBin'
                      : 'Next: ${_slides[_currentPage + 1]['title']}',
                  icon: _currentPage == _slides.length - 1
                      ? Icons.arrow_forward_rounded
                      : null,
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboardingAndNavigate(AppRoutes.register);
                    }
                  },
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  text: 'Already have an account? Log In',
                  onPressed: () =>
                      _completeOnboardingAndNavigate(AppRoutes.login),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Desktop split layout
  Widget _buildDesktopLayout(BuildContext context) {
    final activeSlide = _slides[_currentPage];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Row(
          children: [
            // Left Hero Column: Brand Visuals & Indicators
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        activeSlide['icon'] as IconData,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      activeSlide['tagline'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      (activeSlide['highlights'] as List<String>).length,
                      (index) {
                        final highlight =
                            (activeSlide['highlights'] as List<String>)[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  highlight,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 48),

            // Right Action Column: Copy & Actions
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP ${_currentPage + 1} OF ${_slides.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _completeOnboardingAndNavigate(AppRoutes.login),
                        child: const Text('Skip to Login'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeSlide['title'] as String,
                    style: AppTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeSlide['subtitle'] as String,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dot indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        onTap: () => setState(() => _currentPage = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 28 : 10,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Primary & Secondary Buttons
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: _currentPage == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: () {
                            if (_currentPage < _slides.length - 1) {
                              setState(() => _currentPage++);
                            } else {
                              _completeOnboardingAndNavigate(AppRoutes.register);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Log In',
                          onPressed: () =>
                              _completeOnboardingAndNavigate(AppRoutes.login),
                        ),
                      ),
                    ],
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

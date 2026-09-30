import 'package:flutter/material.dart';

/// Illustrated graphical badge for recyclable waste category cards.
/// Replaces plain whitespace with custom visual artwork tailored to each category.
class CategoryIllustration extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final double size;

  const CategoryIllustration({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('plastic')) {
      return _buildPlasticIllustration();
    } else if (lower.contains('paper') || lower.contains('cardboard')) {
      return _buildPaperIllustration();
    } else if (lower.contains('glass')) {
      return _buildGlassIllustration();
    } else if (lower.contains('metal')) {
      return _buildMetalIllustration();
    } else if (lower.contains('e-waste') || lower.contains('electronic')) {
      return _buildEWasteIllustration();
    }
    // Fallback default eco graphic
    return _buildGenericEcoIllustration();
  }

  /// 1. Plastic: Bottle & recycling loop with water droplet accent
  Widget _buildPlasticIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F2FE),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Icon(
            Icons.recycling_rounded,
            size: size * 0.50,
            color: const Color(0xFF0284C7),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.2),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.water_drop_rounded,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Paper & Cardboard: Packaging box with leaf and warm amber tones
  Widget _buildPaperIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF3C7),
              border: Border.all(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Icon(
            Icons.inventory_2_rounded,
            size: size * 0.48,
            color: const Color(0xFFD97706),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.2),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.eco_rounded,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Glass: Bottle / Glassware with diamond sparkle
  Widget _buildGlassIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDCFCE7),
              border: Border.all(
                color: const Color(0xFF4ADE80).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Icon(
            Icons.wine_bar_rounded,
            size: size * 0.48,
            color: const Color(0xFF16A34A),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.2),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Metal: Clean can / tin with shiny metallic star
  Widget _buildMetalIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF475569).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Icon(
            Icons.takeout_dining_rounded,
            size: size * 0.48,
            color: const Color(0xFF475569),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.2),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.star_rounded,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. E-Waste: Tech device with lightning energy spark
  Widget _buildEWasteIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3E8FF),
              border: Border.all(
                color: const Color(0xFFC084FC).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Icon(
            Icons.devices_other_rounded,
            size: size * 0.48,
            color: const Color(0xFF7C3AED),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.2),
              decoration: BoxDecoration(
                color: const Color(0xFF9333EA),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.bolt_rounded,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericEcoIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: categoryColor.withValues(alpha: 0.15),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
          ),
          Icon(
            Icons.eco_rounded,
            size: size * 0.50,
            color: categoryColor,
          ),
        ],
      ),
    );
  }
}

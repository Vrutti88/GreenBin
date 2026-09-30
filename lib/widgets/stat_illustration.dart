import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Types of statistics illustrations featured on the GreenBin dashboard.
enum StatIllustrationType {
  pickups,
  divertedKg,
  activePickups,
  zeroWasteRank,
}

/// Rich, decorative 3D-styled illustrated badge widget for dashboard metric cards.
/// Replaces plain whitespace with vibrant, modern eco-themed graphics.
class StatIllustration extends StatelessWidget {
  final StatIllustrationType type;
  final double size;

  const StatIllustration({
    super.key,
    required this.type,
    this.size = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case StatIllustrationType.pickups:
        return _buildPickupsIllustration();
      case StatIllustrationType.divertedKg:
        return _buildDivertedKgIllustration();
      case StatIllustrationType.activePickups:
        return _buildActivePickupsIllustration();
      case StatIllustrationType.zeroWasteRank:
        return _buildZeroWasteRankIllustration();
    }
  }

  /// 1. Total Pickups: Eco Delivery Truck with floating leaf and speed trail
  Widget _buildPickupsIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow & decorative gradient disc
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDCFCE7),
              border: Border.all(
                color: const Color(0xFF86EFAC).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // Subtle inner dashed/circular track
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Main Icon: Eco Delivery Truck
          Icon(
            Icons.local_shipping_rounded,
            size: size * 0.48,
            color: AppColors.primary,
          ),
          // Floating eco leaf badge in top-right
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.eco_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
          // Tiny sparkle in bottom-left
          Positioned(
            bottom: 4,
            left: 4,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: const Color(0xFF22C55E).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Diverted (kg): Precision Environmental Scale with recycling loop
  Widget _buildDivertedKgIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow & decorative gradient disc
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCCFBF1),
              border: Border.all(
                color: const Color(0xFF5EEAD4).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // Inner circular highlight
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Main Icon: Eco scale / recycling balance
          Icon(
            Icons.scale_rounded,
            size: size * 0.48,
            color: AppColors.secondary,
          ),
          // Floating recycling badge in top-right
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.recycling_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
          // Sparkling star in bottom-right
          Positioned(
            bottom: 4,
            right: 5,
            child: Icon(
              Icons.star_rounded,
              size: size * 0.20,
              color: const Color(0xFF14B8A6).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Active Pickups: Real-time dispatch clipboard with glowing live pulse
  Widget _buildActivePickupsIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow & decorative gradient disc
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF3C7),
              border: Border.all(
                color: const Color(0xFFFCD34D).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.statusPending.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // Inner circular highlight
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Main Icon: Active clipboard with clock
          Icon(
            Icons.pending_actions_rounded,
            size: size * 0.48,
            color: const Color(0xFFD97706),
          ),
          // Floating Live Status Beacon (Pulsing Dot)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Clock speed lines
          Positioned(
            bottom: 4,
            left: 5,
            child: Icon(
              Icons.schedule_rounded,
              size: size * 0.20,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Zero-Waste Rank: Gamified Eco-Medal with golden star and laurel
  Widget _buildZeroWasteRankIllustration() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow & decorative gradient disc
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3E8FF),
              border: Border.all(
                color: const Color(0xFFD8B4FE).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // Inner circular highlight
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          // Main Icon: Eco Award Medal / Leaf Ribbon
          Icon(
            Icons.workspace_premium_rounded,
            size: size * 0.52,
            color: const Color(0xFF7C3AED),
          ),
          // Floating Gold Star badge in top-right
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
          // Sparkle in bottom-left
          Positioned(
            bottom: 4,
            left: 4,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

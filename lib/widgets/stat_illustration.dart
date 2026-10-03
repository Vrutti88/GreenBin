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

/// Modern, high-fidelity thematic scene illustration for dashboard stat cards.
/// Placed beside the metric value to enrich the card and eliminate empty whitespace.
class StatSceneGraphic extends StatelessWidget {
  final StatIllustrationType type;
  final double size;

  const StatSceneGraphic({
    super.key,
    required this.type,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case StatIllustrationType.pickups:
        return _buildPickupsScene();
      case StatIllustrationType.divertedKg:
        return _buildDivertedKgScene();
      case StatIllustrationType.activePickups:
        return _buildActivePickupsScene();
      case StatIllustrationType.zeroWasteRank:
        return _buildZeroWasteRankScene();
    }
  }

  /// 1. Total Pickups Scene:
  /// Multi-layered eco electric recycling van, doorstep container, green leaf and speed lines.
  Widget _buildPickupsScene() {
    return Container(
      width: size * 1.15,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft radial aura
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD1FAE5),
              ),
            ),
          ),
          // Road / baseline
          Positioned(
            bottom: size * 0.16,
            left: size * 0.1,
            right: size * 0.1,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Main Icon: Eco Delivery Van
          Positioned(
            left: size * 0.10,
            bottom: size * 0.18,
            child: Icon(
              Icons.local_shipping_rounded,
              size: size * 0.52,
              color: const Color(0xFF059669),
            ),
          ),
          // Doorstep Bin on the right
          Positioned(
            right: size * 0.10,
            bottom: size * 0.18,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
          // Floating Eco Leaf with sparkle
          Positioned(
            top: size * 0.10,
            right: size * 0.16,
            child: Container(
              padding: const EdgeInsets.all(2.5),
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
          // Sparkle star
          Positioned(
            top: size * 0.12,
            left: size * 0.14,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: const Color(0xFF34D399),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Diverted Kg Scene:
  /// Precision scale with green leaves and weight badge.
  Widget _buildDivertedKgScene() {
    return Container(
      width: size * 1.15,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.scale_rounded,
            size: size * 0.54,
            color: const Color(0xFF0D9488),
          ),
          Positioned(
            top: size * 0.10,
            right: size * 0.12,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.recycling_rounded,
                size: size * 0.20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Active Pickups Scene:
  /// Dispatch clipboard with checklist, live orange clock, and pulsing status badge.
  Widget _buildActivePickupsScene() {
    return Container(
      width: size * 1.15,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circle
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEF3C7),
              ),
            ),
          ),
          // Main Icon: Active Pending Actions / Dispatch Clipboard
          Positioned(
            left: size * 0.10,
            bottom: size * 0.14,
            child: Icon(
              Icons.pending_actions_rounded,
              size: size * 0.52,
              color: const Color(0xFFD97706),
            ),
          ),
          // Clock Badge on the right
          Positioned(
            right: size * 0.10,
            bottom: size * 0.16,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
          // Live Status Beacon on top-right
          Positioned(
            top: size * 0.10,
            right: size * 0.14,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: size * 0.16,
                color: Colors.white,
              ),
            ),
          ),
          // Transit radar lines in top-left
          Positioned(
            top: size * 0.12,
            left: size * 0.14,
            child: Icon(
              Icons.sensors_rounded,
              size: size * 0.20,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Zero-Waste Rank Scene:
  /// Gleaming Eco Trophy with emerald laurel, gold ribbon medal, and sparkle stars.
  Widget _buildZeroWasteRankScene() {
    return Container(
      width: size * 1.15,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE9D5FF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft radial aura
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3E8FF),
              ),
            ),
          ),
          // Main Icon: Eco Award Trophy Cup
          Positioned(
            left: size * 0.10,
            bottom: size * 0.14,
            child: Icon(
              Icons.emoji_events_rounded,
              size: size * 0.54,
              color: const Color(0xFF7C3AED),
            ),
          ),
          // Golden Star Ribbon badge on the right
          Positioned(
            right: size * 0.10,
            bottom: size * 0.16,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
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
          // Sprout badge on top-right
          Positioned(
            top: size * 0.10,
            right: size * 0.16,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Icon(
                Icons.eco_rounded,
                size: size * 0.18,
                color: Colors.white,
              ),
            ),
          ),
          // Diamond sparkle in top-left
          Positioned(
            top: size * 0.12,
            left: size * 0.14,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: const Color(0xFFA855F7),
            ),
          ),
        ],
      ),
    );
  }
}

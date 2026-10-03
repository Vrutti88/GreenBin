import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Interactive time slot selector using responsive Wrap chips with guaranteed
/// accessible touch targets.
class TimeSlotSelector extends StatelessWidget {
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;
  final List<String> availableSlots;
  final String? label;
  final bool Function(String slot)? isSlotDisabled;

  const TimeSlotSelector({
    super.key,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.availableSlots = const [
      '8:00 AM - 10:00 AM',
      '10:00 AM - 12:00 PM',
      '12:00 PM - 2:00 PM',
      '2:00 PM - 4:00 PM',
      '4:00 PM - 6:00 PM',
      '6:00 PM - 8:00 PM',
    ],
    this.label,
    this.isSlotDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSlots.map((slot) {
            final isSelected = selectedSlot == slot;
            final isDisabled = isSlotDisabled != null && isSlotDisabled!(slot);

            return Tooltip(
              message: isDisabled ? '$slot has already passed' : 'Select $slot',
              child: InkWell(
                mouseCursor: isDisabled
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                onTap: isDisabled ? null : () => onSlotSelected(slot),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  constraints: const BoxConstraints(minHeight: 44),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? AppColors.surfaceVariantLight.withValues(alpha: 0.35)
                        : (isSelected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariantLight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDisabled
                          ? AppColors.borderLight.withValues(alpha: 0.4)
                          : (isSelected
                              ? AppColors.primary
                              : AppColors.borderLight),
                      width: isSelected && !isDisabled ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDisabled
                            ? Icons.history_rounded
                            : (isSelected
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded),
                        size: 16,
                        color: isDisabled
                            ? AppColors.textMuted
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        slot,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDisabled
                              ? AppColors.textMuted
                              : (isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary),
                          fontWeight: isSelected && !isDisabled
                              ? FontWeight.w700
                              : FontWeight.w500,
                          decoration: isDisabled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (isDisabled) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.borderLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Passed',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

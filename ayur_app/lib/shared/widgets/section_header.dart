import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final String? viewAllLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.viewAllLabel = 'View All',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  viewAllLabel ?? 'View All',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

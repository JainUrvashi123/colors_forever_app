import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../providers/melee_provider.dart';

class MeleeSwatchSelector extends StatelessWidget {
  final MeleeProvider provider;

  const MeleeSwatchSelector({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'COLOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (provider.selectedColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warmGoldTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.champagneGold.withAlpha(140)),
                  ),
                  child: Text(
                    provider.selectedColor!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.richGold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DiamondSwatchGrid(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          colors: provider.colors.map((c) => c.name).toList(),
          selectedColors: provider.selectedColor != null ? {provider.selectedColor!} : {},
          onColorSelected: (col) {
            final isSelected = provider.selectedColor?.toLowerCase() == col.toLowerCase() ||
                (provider.selectedColor?.toLowerCase() == 'brown' && col.toLowerCase().contains('brown')) ||
                (provider.selectedColor?.toLowerCase() == 'white' && col.toLowerCase().contains('white'));
            provider.selectColor(isSelected ? null : col);
          },
        ),
      ],
    );
  }
}

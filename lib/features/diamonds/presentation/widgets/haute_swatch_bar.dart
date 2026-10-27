import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../providers/diamond_filter_provider.dart';

class HauteSwatchBar extends StatelessWidget {
  final DiamondFilterProvider filterProvider;
  final ValueChanged<String> onColorSelected;

  const HauteSwatchBar({
    super.key,
    required this.filterProvider,
    required this.onColorSelected,
  });

  static const List<String> hauteColors = [
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Red',
    'Orange',
    'Black',
    'Champagne/Brown',
    'White/Colorless',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DiamondSwatchGrid(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        colors: hauteColors,
        selectedColors: filterProvider.filter.selectedColors.toSet(),
        onColorSelected: onColorSelected,
      ),
    );
  }
}

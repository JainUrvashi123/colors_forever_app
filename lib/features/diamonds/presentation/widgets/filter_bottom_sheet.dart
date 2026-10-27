import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../providers/diamond_filter_provider.dart';
import '../providers/diamond_catalog_provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiamondFilterProvider>(
      builder: (context, filterProvider, _) {
        final filter = filterProvider.filter;
        final availableShades = filterProvider.availableShades;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title & Reset
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Refine Diamonds',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (filter.activeFilterCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${filter.activeFilterCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        filterProvider.resetFilters();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF1E6FBA)),
                      label: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: Color(0xFF1E6FBA),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),

              // Filter Scrollable Sections
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  children: [
                    // 1. COLOR SECTION
                    _buildSectionHeader('Color Tone'),
                    const SizedBox(height: 10),
                    DiamondSwatchGrid(
                      padding: EdgeInsets.zero,
                      colors: DiamondFilterProvider.availableColors,
                      selectedColors: filter.selectedColors.toSet(),
                      onColorSelected: (colorName) => filterProvider.toggleColor(colorName),
                    ),
                    const SizedBox(height: 22),

                    // 2. DYNAMIC SHADES
                    if (availableShades.isNotEmpty) ...[
                      _buildSectionHeader('Color Shades'),
                      const SizedBox(height: 10),
                      ShadeGrid(
                        shades: availableShades,
                        selectedShades: filter.selectedShades.toSet(),
                        onShadeSelected: (shade) => filterProvider.toggleShade(shade),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // 3. SHAPE SECTION
                    _buildSectionHeader('Diamond Shape'),
                    const SizedBox(height: 10),
                    DiamondShapeGrid(
                      padding: EdgeInsets.zero,
                      shapes: DiamondFilterProvider.availableShapes,
                      selectedShapes: filter.selectedShapes.toSet(),
                      onShapeSelected: (shape) => filterProvider.toggleShape(shape),
                    ),
                    const SizedBox(height: 22),

                    // 4. CLARITY SECTION
                    _buildSectionHeader('Clarity Grade'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: DiamondFilterProvider.availableClarities.map((clarity) {
                        final isSelected = filter.selectedClarities.contains(clarity);
                        return ChoiceChip(
                          label: Text(clarity),
                          selected: isSelected,
                          onSelected: (_) => filterProvider.toggleClarity(clarity),
                          selectedColor: AppColors.primary,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 5. CERTIFICATE LABS
                    _buildSectionHeader('Laboratory Certification'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLabCard('GIA', AppAssets.giaCert, filter.selectedLabs.contains('GIA'), () {
                          filterProvider.toggleLab('GIA');
                        }),
                        const SizedBox(width: 12),
                        _buildLabCard('IGI', AppAssets.igiCert, filter.selectedLabs.contains('IGI'), () {
                          filterProvider.toggleLab('IGI');
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 6. CARAT RANGE
                    _buildSectionHeader('Carat Weight'),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filter.minCarat.toStringAsFixed(2)} Ct',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E6FBA),
                          ),
                        ),
                        Text(
                          filter.maxCarat >= 25.0
                              ? '25+ Ct'
                              : '${filter.maxCarat.toStringAsFixed(2)} Ct',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E6FBA),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFF1E6FBA),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFF1E6FBA).withValues(alpha: 0.12),
                      ),
                      child: RangeSlider(
                        values: RangeValues(
                          filter.minCarat.clamp(0.0, 25.0),
                          filter.maxCarat.clamp(0.0, 25.0),
                        ),
                        min: 0.0,
                        max: 25.0,
                        activeColor: const Color(0xFF1E6FBA),
                        inactiveColor: const Color(0xFFE2E8F0),
                        labels: RangeLabels(
                          '${filter.minCarat.toStringAsFixed(2)} Ct',
                          filter.maxCarat >= 25.0
                              ? '25+ Ct'
                              : '${filter.maxCarat.toStringAsFixed(2)} Ct',
                        ),
                        onChanged: (vals) {
                          final start = (vals.start * 100).roundToDouble() / 100;
                          final end = (vals.end * 100).roundToDouble() / 100;
                          filterProvider.setCaratRange(start, end);
                        },
                      ),
                    ),
                    // Quick Carat Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: DiamondFilterProvider.caratPresets.map((preset) {
                          final label = preset['label'] as String;
                          final pMin = preset['min'] as double;
                          final pMax = preset['max'] as double;
                          final isPresetActive = (filter.minCarat == pMin && filter.maxCarat == pMax);

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(label),
                              backgroundColor: isPresetActive ? AppColors.primary : const Color(0xFFF1F5F9),
                              side: BorderSide(
                                color: isPresetActive ? AppColors.primary : AppColors.border,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: isPresetActive ? Colors.white : AppColors.textSecondary,
                                fontWeight: isPresetActive ? FontWeight.bold : FontWeight.normal,
                              ),
                              onPressed: () {
                                filterProvider.setCaratRange(pMin, pMax);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 7. TOTAL PRICE FILTER
                    _buildSectionHeader('Total Price (\$)'),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatCurrency(filter.minPrice, compact: true),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E6FBA),
                          ),
                        ),
                        Text(
                          filter.maxPrice >= 500000.0
                              ? r'$500,000+'
                              : Formatters.formatCurrency(filter.maxPrice, compact: true),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E6FBA),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFF1E6FBA),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFF1E6FBA).withValues(alpha: 0.12),
                      ),
                      child: RangeSlider(
                        values: RangeValues(
                          filter.minPrice.clamp(0.0, 500000.0),
                          filter.maxPrice.clamp(0.0, 500000.0),
                        ),
                        min: 0.0,
                        max: 500000.0,
                        activeColor: const Color(0xFF1E6FBA),
                        inactiveColor: const Color(0xFFE2E8F0),
                        labels: RangeLabels(
                          Formatters.formatCurrency(filter.minPrice, compact: true),
                          filter.maxPrice >= 500000.0
                              ? r'$500,000+'
                              : Formatters.formatCurrency(filter.maxPrice, compact: true),
                        ),
                        onChanged: (vals) {
                          final start = (vals.start / 500).roundToDouble() * 500;
                          final end = (vals.end / 500).roundToDouble() * 500;
                          filterProvider.setPriceRange(start, end);
                        },
                      ),
                    ),
                    // Quick Price Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: DiamondFilterProvider.pricePresets.map((preset) {
                          final label = preset['label'] as String;
                          final pMin = preset['min'] as double;
                          final pMax = preset['max'] as double;
                          final isPresetActive = (filter.minPrice == pMin && filter.maxPrice == pMax);

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(label),
                              backgroundColor: isPresetActive ? AppColors.primary : const Color(0xFFF1F5F9),
                              side: BorderSide(
                                color: isPresetActive ? AppColors.primary : AppColors.border,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12.0,
                                color: isPresetActive ? Colors.white : AppColors.textSecondary,
                                fontWeight: isPresetActive ? FontWeight.bold : FontWeight.normal,
                              ),
                              onPressed: () {
                                filterProvider.setPriceRange(pMin, pMax);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 8. LOCATION
                    _buildSectionHeader('Office Location'),
                    const SizedBox(height: 8),
                    Row(
                      children: ['All', 'NY', 'JP'].map((loc) {
                        final isSelected = (loc == 'All' && (filter.location == null || filter.location!.isEmpty)) ||
                            (filter.location == loc);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(loc == 'All' ? 'All Locations' : loc),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              filterProvider.setLocation(loc == 'All' ? null : loc);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Sticky Action Buttons: [ Reset Filter ] & [ Apply Filters ]
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ResetFilterButton(
                            height: 46,
                            onTap: () {
                              filterProvider.resetFilters();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E6FBA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 2,
                              shadowColor: const Color(0xFF1E6FBA).withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<DiamondCatalogProvider>().fetchDiamonds(filter, refresh: true);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filter.activeFilterCount > 0
                                      ? 'Apply (${filter.activeFilterCount})'
                                      : 'Apply Filters',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildLabCard(String name, String assetPath, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.champagneGold : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, height: 22, fit: BoxFit.contain),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF996515) : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

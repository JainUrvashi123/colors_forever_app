import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../../data/models/jewelry_index_model.dart';
import '../providers/jewelry_provider.dart';

class JewelryFilterSheet extends StatefulWidget {
  const JewelryFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JewelryFilterSheet(),
    );
  }

  @override
  State<JewelryFilterSheet> createState() => _JewelryFilterSheetState();
}

class _JewelryFilterSheetState extends State<JewelryFilterSheet> {
  late Set<String> _selectedDepartments;
  late Set<String> _selectedSec1List;
  late Set<String> _selectedGoldKarats;
  late Set<String> _selectedGoldColors;
  late Set<String> _selectedDiamondColors;
  late Set<String> _selectedStyleSettings;
  late Set<String> _selectedSizes;
  RangeValues _caratRange = const RangeValues(0.1, 20.0);
  RangeValues _priceRange = const RangeValues(1.0, 100000.0);

  @override
  void initState() {
    super.initState();
    final provider = context.read<JewelryProvider>();
    _selectedDepartments = Set.from(provider.selectedDepartments);
    _selectedSec1List = Set.from(provider.selectedSec1List);
    _selectedGoldKarats = Set.from(provider.selectedGoldKarats);
    _selectedGoldColors = Set.from(provider.selectedGoldColors);
    _selectedDiamondColors = Set.from(provider.selectedDiamondColors);
    _selectedStyleSettings = Set.from(provider.selectedStyleSettings);
    _selectedSizes = Set.from(provider.selectedSizes);

    if (provider.caratMin != null || provider.caratMax != null) {
      _caratRange = RangeValues(
        provider.caratMin ?? 0.1,
        provider.caratMax ?? 20.0,
      );
    }
    if (provider.priceMin != null || provider.priceMax != null) {
      _priceRange = RangeValues(
        provider.priceMin ?? 1.0,
        provider.priceMax ?? 100000.0,
      );
    }
  }

  void _resetAllLocalFilters() {
    setState(() {
      _selectedDepartments.clear();
      _selectedSec1List.clear();
      _selectedGoldKarats.clear();
      _selectedGoldColors.clear();
      _selectedDiamondColors.clear();
      _selectedStyleSettings.clear();
      _selectedSizes.clear();
      _caratRange = const RangeValues(0.1, 20.0);
      _priceRange = const RangeValues(1.0, 100000.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JewelryProvider>();
    final index = provider.indexData;

    // Find active sub categories for selected departments
    List<String> subCategories = [];
    if (_selectedDepartments.isNotEmpty) {
      final subs = <String>{};
      for (final dept in _selectedDepartments) {
        final deptObj = index.categories.firstWhere(
          (c) => c.department.toLowerCase() == dept.toLowerCase(),
          orElse: () => const JewelryDepartmentCategory(department: '', subCategories: []),
        );
        subs.addAll(deptObj.subCategories);
      }
      subCategories = subs.toList();
    } else {
      final allSubs = <String>{};
      for (final c in index.categories) {
        allSubs.addAll(c.subCategories);
      }
      subCategories = allSubs.toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header: Title & Reset All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Fine Jewelry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _resetAllLocalFilters,
                  icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF1E6FBA)),
                  label: Text(
                    'Reset All',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF1E6FBA),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Scrollable Filter Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Department Category
                _buildSectionHeader('Department Category'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', 'Ring', 'Pendant', 'Earring', 'Bracelet'].map((d) {
                    final isAll = d == 'All';
                    final isSelected = isAll
                        ? _selectedDepartments.isEmpty
                        : _selectedDepartments.contains(d);
                    return ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      selectedColor: AppColors.midnightOnyx,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (isAll) {
                            _selectedDepartments.clear();
                            _selectedSec1List.clear();
                          } else {
                            if (isSelected) {
                              _selectedDepartments.remove(d);
                            } else {
                              _selectedDepartments.add(d);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 2. Sub Category (sec_1)
                if (subCategories.isNotEmpty) ...[
                  _buildSectionHeader('Sub Category Style'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subCategories.map((s) {
                      final isSelected = _selectedSec1List.contains(s);
                      return FilterChip(
                        label: Text(s),
                        selected: isSelected,
                        selectedColor: AppColors.warmGoldTint,
                        checkmarkColor: AppColors.richGold,
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSec1List.add(s);
                            } else {
                              _selectedSec1List.remove(s);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // 3. Metal Karat
                _buildSectionHeader('Gold Karat'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['14K', '18K'].map((k) {
                    final isSelected = _selectedGoldKarats.contains(k);
                    return FilterChip(
                      label: Text(k),
                      selected: isSelected,
                      selectedColor: AppColors.warmGoldTint,
                      checkmarkColor: AppColors.richGold,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGoldKarats.add(k);
                          } else {
                            _selectedGoldKarats.remove(k);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. Gold Metal Color
                _buildSectionHeader('Gold Metal Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['White', 'Yellow', 'Rose', 'Multi-Color'].map((c) {
                    final isSelected = _selectedGoldColors.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: isSelected,
                      selectedColor: AppColors.warmGoldTint,
                      checkmarkColor: AppColors.richGold,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGoldColors.add(c);
                          } else {
                            _selectedGoldColors.remove(c);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 5. Diamond Color
                _buildSectionHeader('Diamond Color Shade'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Black',
                    'Blue',
                    'Canary Yellow',
                    'Cognac',
                    'Emerald Green',
                    'Forest Green',
                    'Golden Yellow',
                    'Green',
                    'Ice Green',
                    'Multi-Color',
                    'Orangish Cognac',
                    'Pine Green',
                    'Pink',
                    'Purple',
                    'Purplish Pink',
                    'Reddish Cognac',
                    'Rose Pink',
                    'Royal Blue',
                    'Sky Blue',
                    'White',
                    'Yellow',
                  ].map((dc) {
                    final isSelected = _selectedDiamondColors.contains(dc);
                    return FilterChip(
                      label: Text(dc),
                      selected: isSelected,
                      selectedColor: AppColors.warmGoldTint,
                      checkmarkColor: AppColors.richGold,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11.5,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDiamondColors.add(dc);
                          } else {
                            _selectedDiamondColors.remove(dc);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 6. Style Setting
                _buildSectionHeader('Style Setting'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Bezel', 'Channel', 'Cluster', 'Flush', 'Invisible', 'Pave', 'Prong'].map((st) {
                    final isSelected = _selectedStyleSettings.contains(st);
                    return FilterChip(
                      label: Text(st),
                      selected: isSelected,
                      selectedColor: AppColors.warmGoldTint,
                      checkmarkColor: AppColors.richGold,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedStyleSettings.add(st);
                          } else {
                            _selectedStyleSettings.remove(st);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 7. Size / Sub Item
                _buildSectionHeader('Ring Size / Sub Item'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['5', '6', '6.5', '7', '8', '8.5', 'Std', 'Std.'].map((sz) {
                    final isSelected = _selectedSizes.contains(sz);
                    return FilterChip(
                      label: Text(sz),
                      selected: isSelected,
                      selectedColor: AppColors.warmGoldTint,
                      checkmarkColor: AppColors.richGold,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSizes.add(sz);
                          } else {
                            _selectedSizes.remove(sz);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 8. Carat Weight Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Carat Weight'),
                    Text(
                      '${_caratRange.start.toStringAsFixed(1)} CT – ${_caratRange.end.toStringAsFixed(1)} CT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E6FBA),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _caratRange,
                  min: 0.1,
                  max: 20.0,
                  divisions: 199,
                  activeColor: const Color(0xFF1E6FBA),
                  labels: RangeLabels(
                    '${_caratRange.start.toStringAsFixed(1)} CT',
                    '${_caratRange.end.toStringAsFixed(1)} CT',
                  ),
                  onChanged: (vals) {
                    setState(() {
                      _caratRange = vals;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 9. Total Price Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Total Price (USD)'),
                    Text(
                      '\$${_priceRange.start.toStringAsFixed(0)} – \$${_priceRange.end.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E6FBA),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 1.0,
                  max: 100000.0,
                  divisions: 100,
                  activeColor: const Color(0xFF1E6FBA),
                  labels: RangeLabels(
                    '\$${_priceRange.start.toStringAsFixed(0)}',
                    '\$${_priceRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (vals) {
                    setState(() {
                      _priceRange = vals;
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Bottom Fixed Action Bar: [ Reset All ] & [ Apply Filters ]
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
                        label: 'Reset All',
                        onTap: _resetAllLocalFilters,
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
                          final p = context.read<JewelryProvider>();
                          p.applyAllFilters(
                            departments: _selectedDepartments,
                            sec1List: _selectedSec1List,
                            goldKarats: _selectedGoldKarats,
                            goldColors: _selectedGoldColors,
                            diamondColors: _selectedDiamondColors,
                            styleSettings: _selectedStyleSettings,
                            sizes: _selectedSizes,
                            caratMin: _caratRange.start == 0.1 && _caratRange.end == 20.0 ? null : _caratRange.start,
                            caratMax: _caratRange.start == 0.1 && _caratRange.end == 20.0 ? null : _caratRange.end,
                            priceMin: _priceRange.start == 1.0 && _priceRange.end == 100000.0 ? null : _priceRange.start,
                            priceMax: _priceRange.start == 1.0 && _priceRange.end == 100000.0 ? null : _priceRange.end,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Apply Filters',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/jewelry_provider.dart';
import '../widgets/jewelry_grid_card.dart';

class JewelryScreen extends StatelessWidget {
  const JewelryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<JewelryProvider>();
      return const _JewelryScreenView();
    } catch (_) {
      return ChangeNotifierProvider(
        create: (_) => JewelryProvider(),
        child: const _JewelryScreenView(),
      );
    }
  }
}

class _JewelryScreenView extends StatefulWidget {
  const _JewelryScreenView();

  @override
  State<_JewelryScreenView> createState() => _JewelryScreenViewState();
}

class _JewelryScreenViewState extends State<_JewelryScreenView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      final provider = context.read<JewelryProvider>();
      if (provider.hasNextPage) {
        provider.loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final authProvider = context.watch<AuthProvider>();
      final currentUserId = authProvider.currentUser?.userId;
      final jewelryProvider = context.read<JewelryProvider>();
      if (jewelryProvider.userId != currentUserId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          jewelryProvider.updateUserId(currentUserId);
        });
      }
    } catch (_) {}

    return Consumer<JewelryProvider>(
      builder: (context, provider, _) {
        final isWide = MediaQuery.of(context).size.width >= 850;
        final crossAxisCount = isWide ? 4 : 2;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Fine Color Jewelry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 24),
                tooltip: 'WhatsApp Inquiry',
                onPressed: () => WhatsAppHelper.launchWhatsApp(
                  context,
                  'Hello Colors Forever, I am inquiring about Fine Color Jewelry collection.',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 24),
                tooltip: 'Refresh Jewelry Catalog',
                onPressed: () => provider.refresh(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Web-Style Filter Header Section (Matching colorsforever.com/color-jewelry)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Department Cards Bar: RINGS | PENDANTS | EARRINGS | BRACELETS (Multi-Select Supported)
                        _buildTopCategoryCards(context, provider),
                        const SizedBox(height: 12),

                        // Subcategory Grouped Rows (RING, PENDANT, EARRING, BRACELET) matching web layout
                        _buildSubcategorySectionsGrouped(context, provider),
                        const SizedBox(height: 12),

                        // Carat & Total Price Sliders + Min/Max Input Boxes
                        _buildCaratAndPriceSliders(context, provider),
                        const SizedBox(height: 12),

                        // Dropdown Quick Filters Bar: Diamond Color ▾ | Metal Color ▾ | Setting Style ▾ | Advance Search | Reset Filter
                        _buildQuickFiltersRow(context, provider),
                      ],
                    ),
                  ),
                ),

                // 2. Total Records Counter Bar & Sort By Dropdown
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${provider.totalRecords} Jewelry Designs',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          initialValue: provider.sortBy,
                          tooltip: 'Sort Jewelry Catalog',
                          onSelected: (val) => provider.setSortBy(val),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'random',
                              child: Text('Random (Default)'),
                            ),
                            PopupMenuItem(
                              value: 'price_l',
                              child: Text('Price: Low to High'),
                            ),
                            PopupMenuItem(
                              value: 'price_h',
                              child: Text('Price: High to Low'),
                            ),
                            PopupMenuItem(
                              value: 'd_color_l',
                              child: Text('Diamond Color: Ascending'),
                            ),
                            PopupMenuItem(
                              value: 'd_color_h',
                              child: Text('Diamond Color: Descending'),
                            ),
                            PopupMenuItem(
                              value: 'color_l',
                              child: Text('Metal Color: Ascending'),
                            ),
                            PopupMenuItem(
                              value: 'color_h',
                              child: Text('Metal Color: Descending'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sort_rounded, size: 15, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _getSortLabel(provider.sortBy),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        if (provider.activeFilterCount > 0) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              provider.resetFilters();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 3. Grid / Loading / Empty Content
                if (provider.isLoading && provider.items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('Loading Fine Color Jewelry...'),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (provider.errorMessage != null && provider.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
                            const SizedBox(height: 12),
                            Text(provider.errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (provider.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond_outlined, size: 48, color: AppColors.champagneGold),
                            const SizedBox(height: 8),
                            Text(
                              'No Jewelry Items Found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your department or style filters.',
                              style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                provider.resetFilters();
                              },
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: isWide ? 0.8 : 0.70,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = provider.items[index];
                          return JewelryGridCard(item: item);
                        },
                        childCount: provider.items.length,
                      ),
                    ),
                  ),

                // 4. Infinite Scroll Loading Indicator
                if (provider.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. Top Web-Style Category Cards (RINGS, PENDANTS, EARRINGS, BRACELETS)
  Widget _buildTopCategoryCards(BuildContext context, JewelryProvider provider) {
    final categories = [
      {'key': 'Ring', 'label': 'RINGS', 'svg': 'assets/images/ring.svg'},
      {'key': 'Pendant', 'label': 'PENDANTS', 'svg': 'assets/images/pendant.svg'},
      {'key': 'Earring', 'label': 'EARRINGS', 'svg': 'assets/images/earrings.svg'},
      {'key': 'Bracelet', 'label': 'BRACELETS', 'svg': 'assets/images/bracelet.svg'},
    ];

    return Row(
      children: categories.map((cat) {
        final deptKey = cat['key'] as String;
        final label = cat['label'] as String;
        final svgPath = cat['svg'] as String;
        final isSelected = provider.selectedDepartments.contains(deptKey);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => provider.toggleDepartment(deptKey),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEBF5FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFFDCDFE6),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0x1F1E6FBA) : const Color(0x0A000000),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      svgPath,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF4A5568),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF2D3748),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 2. Subcategory Grouped Rows (RING, PENDANT, EARRING, BRACELET) matching web layout
  Widget _buildSubcategorySectionsGrouped(BuildContext context, JewelryProvider provider) {
    final Map<String, List<Map<String, dynamic>>> deptSubMap = {
      'RING': [
        {'name': 'Bands', 'image': 'assets/images/Bands.png'},
        {'name': 'Cocktail', 'image': 'assets/images/Cocktail.png'},
        {'name': 'Cross Over', 'image': 'assets/images/Cross Over.png'},
        {'name': 'Engagement', 'image': 'assets/images/Engagement.png'},
        {'name': 'Eternity', 'image': 'assets/images/Eternity.png'},
        {'name': 'Fashion', 'image': 'assets/images/Fashion.png'},
        {'name': 'Flower', 'image': 'assets/images/Flower.png'},
        {'name': 'Halo', 'image': 'assets/images/Halo.png'},
        {'name': 'Semi Mount', 'image': 'assets/images/Semi Mount.png'},
        {'name': 'Solitaire', 'image': 'assets/images/Solitaire.png'},
        {'name': 'Stackable', 'image': 'assets/images/Stackable.png'},
      ],
      'PENDANT': [
        {'name': 'Circle', 'image': 'assets/images/pendant/Circle.png'},
        {'name': 'Cluster', 'image': 'assets/images/pendant/Cluster.png'},
        {'name': 'Cocktail', 'image': 'assets/images/pendant/Cocktail.png'},
        {'name': 'Cross', 'image': 'assets/images/pendant/Cross.png'},
        {'name': 'Dangling', 'image': 'assets/images/pendant/Dangling.png'},
        {'name': 'Drop', 'image': 'assets/images/pendant/Drop.png'},
        {'name': 'Fashion', 'image': 'assets/images/pendant/Fashion.png'},
        {'name': 'Flower', 'image': 'assets/images/pendant/Flower.png'},
        {'name': 'Halo', 'image': 'assets/images/pendant/Halo.png'},
        {'name': 'Heart', 'image': 'assets/images/pendant/Heart.png'},
        {'name': 'Slider', 'image': 'assets/images/pendant/Slider.png'},
      ],
      'EARRING': [
        {'name': 'Cocktail', 'image': 'assets/images/earring/Cocktail.png'},
        {'name': 'Dangling', 'image': 'assets/images/earring/Dangling.png'},
        {'name': 'Drop', 'image': 'assets/images/earring/Drop.png'},
        {'name': 'Fashion', 'image': 'assets/images/earring/Fashion.png'},
        {'name': 'Hoop', 'image': 'assets/images/earring/Hoop.png'},
        {'name': 'Jacket', 'image': 'assets/images/earring/Jacket.png'},
        {'name': 'Solitaire', 'image': 'assets/images/earring/Solitaire.png'},
        {'name': 'Studs', 'image': 'assets/images/earring/Studs.png'},
      ],
      'BRACELET': [
        {'name': 'Bangle', 'image': 'assets/images/Bangle.png'},
        {'name': 'Link', 'image': 'assets/images/Link.png'},
        {'name': 'Tennis', 'image': 'assets/images/Tennis.png'},
      ],
    };

    final selectedDepts = provider.selectedDepartments;

    final activeEntries = deptSubMap.entries.where((entry) {
      if (selectedDepts.isEmpty) {
        return false;
      }
      return selectedDepts.any((d) => d.toUpperCase() == entry.key);
    }).toList();

    if (activeEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeEntries.map((entry) {
        final deptName = entry.key;
        final subList = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6FBA),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deptName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E6FBA),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: subList.map((item) {
                  final subName = item['name'] as String;
                  final imagePath = item['image'] as String?;
                  final scopedKey = '$deptName:$subName';
                  final isSelected = provider.selectedSec1List.contains(scopedKey) ||
                      (provider.selectedSec1List.contains(subName) && provider.selectedDepartments.length == 1);

                  return GestureDetector(
                    onTap: () => provider.toggleSec1(scopedKey),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEBF5FF) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFFDCDFE6),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? const [BoxShadow(color: Color(0x1F1E6FBA), blurRadius: 4, offset: Offset(0, 1))]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imagePath != null) ...[
                            Image.asset(
                              imagePath,
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            subName.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF333333),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 3. Carat & Total Price Sliders + Min/Max Editable Boxes
  Widget _buildCaratAndPriceSliders(BuildContext context, JewelryProvider provider) {
    final caratStart = provider.caratMin ?? 0.1;
    final caratEnd = provider.caratMax ?? 20.0;
    final priceStart = provider.priceMin ?? 1.0;
    final priceEnd = provider.priceMax ?? 100000.0;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;

            final caratSection = _SliderWithInputs(
              title: 'CARAT',
              minValue: 0.1,
              maxValue: 20.0,
              currentStart: caratStart,
              currentEnd: caratEnd,
              divisions: 199,
              isDecimal: true,
              prefix: '',
              onChanged: (start, end) {
                provider.setCaratRange(
                  start <= 0.1 && end >= 20.0 ? null : start,
                  start <= 0.1 && end >= 20.0 ? null : end,
                );
              },
            );

            final priceSection = _SliderWithInputs(
              title: 'TOTAL PRICE',
              minValue: 1.0,
              maxValue: 100000.0,
              currentStart: priceStart,
              currentEnd: priceEnd,
              divisions: 100,
              isDecimal: false,
              prefix: '\$',
              onChanged: (start, end) {
                provider.setPriceRange(
                  start <= 1.0 && end >= 100000.0 ? null : start,
                  start <= 1.0 && end >= 100000.0 ? null : end,
                );
              },
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: caratSection),
                  const SizedBox(width: 16),
                  Expanded(child: priceSection),
                ],
              );
            }
            return Column(
              children: [
                caratSection,
                const SizedBox(height: 6),
                priceSection,
              ],
            );
          },
        ),
      ],
    );
  }

  // 4. Dropdown Quick Filters Bar: Diamond Color ▾ | Metal Color ▾ | Setting Style ▾ | Reset Filter ↺
  Widget _buildQuickFiltersRow(BuildContext context, JewelryProvider provider) {
    final dColorCount = provider.selectedDiamondColors.length;
    final mColorCount = provider.selectedGoldColors.length;
    final styleCount = provider.selectedStyleSettings.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdownPill(
            label: dColorCount > 0
                ? 'Diamond Color ($dColorCount)'
                : 'Diamond Color',
            isSelected: dColorCount > 0,
            onTap: () => _showMultiOptionPicker(
              context,
              title: 'Diamond Color',
              options: [
                'Black', 'Blue', 'Canary Yellow', 'Cognac',
                'Emerald Green', 'Forest Green', 'Golden Yellow', 'Green',
                'Ice Green', 'Multi-Color', 'Orangish Cognac', 'Pine Green',
                'Pink', 'Purple', 'Purplish Pink', 'Reddish Cognac', 'Rose Pink',
                'Royal Blue', 'Sky Blue', 'White', 'Yellow'
              ],
              currentValues: provider.selectedDiamondColors,
              onSelectionChanged: (selected) => provider.setDiamondColors(selected),
            ),
          ),
          const SizedBox(width: 6),
          _buildFilterDropdownPill(
            label: mColorCount > 0
                ? 'Metal Color ($mColorCount)'
                : 'Metal Color',
            isSelected: mColorCount > 0,
            onTap: () => _showMultiOptionPicker(
              context,
              title: 'Metal Color',
              options: ['White', 'Yellow', 'Rose', 'Multi-Color'],
              currentValues: provider.selectedGoldColors,
              onSelectionChanged: (selected) => provider.setGoldColors(selected),
            ),
          ),
          const SizedBox(width: 6),
          _buildFilterDropdownPill(
            label: styleCount > 0
                ? 'Setting Style ($styleCount)'
                : 'Setting Style',
            isSelected: styleCount > 0,
            onTap: () => _showMultiOptionPicker(
              context,
              title: 'Setting Style',
              options: ['Bezel', 'Channel', 'Cluster', 'Flush', 'Invisible', 'Pave', 'Prong'],
              currentValues: provider.selectedStyleSettings,
              onSelectionChanged: (selected) => provider.setStyleSettings(selected),
            ),
          ),
          if (provider.activeFilterCount > 0) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                provider.resetFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E6FBA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reset Filter ↺',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdownPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF5FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFFCCCCCC),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiOptionPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required Set<String> currentValues,
    required ValueChanged<Set<String>> onSelectionChanged,
  }) {
    final tempSelected = Set<String>.from(currentValues);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    if (tempSelected.length == options.length) {
                                      tempSelected.clear();
                                    } else {
                                      tempSelected.addAll(options);
                                    }
                                  });
                                },
                                child: Text(tempSelected.length == options.length ? 'Clear All' : 'Select All'),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E6FBA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                ),
                                onPressed: () {
                                  onSelectionChanged(tempSelected);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final opt = options[index];
                            final isChecked = tempSelected.contains(opt);
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  if (isChecked) {
                                    tempSelected.remove(opt);
                                  } else {
                                    tempSelected.add(opt);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isChecked ? const Color(0xFFEBF5FF) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isChecked ? const Color(0xFF1E6FBA) : const Color(0xFFE2E8F0),
                                    width: isChecked ? 1.6 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                      size: 18,
                                      color: isChecked ? const Color(0xFF1E6FBA) : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        opt,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                                          color: isChecked ? const Color(0xFF1E6FBA) : const Color(0xFF334155),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getSortLabel(String key) {
    switch (key) {
      case 'random':
      case '':
        return 'Random';
      case 'color_l':
        return 'Metal Color ↑';
      case 'color_h':
        return 'Metal Color ↓';
      case 'price_l':
        return 'Price Low–High';
      case 'price_h':
        return 'Price High–Low';
      case 'd_color_l':
        return 'Diamond Color ↑';
      case 'd_color_h':
        return 'Diamond Color ↓';
      default:
        return 'Random';
    }
  }
}

/// An interactive RangeSlider row flanked by editable text input boxes
/// Allows typing numbers manually OR dragging the range slider.
class _SliderWithInputs extends StatefulWidget {
  final String title;
  final double minValue;
  final double maxValue;
  final double currentStart;
  final double currentEnd;
  final int divisions;
  final bool isDecimal;
  final String prefix;
  final void Function(double start, double end) onChanged;

  const _SliderWithInputs({
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.currentStart,
    required this.currentEnd,
    required this.divisions,
    required this.isDecimal,
    required this.prefix,
    required this.onChanged,
  });

  @override
  State<_SliderWithInputs> createState() => _SliderWithInputsState();
}

class _SliderWithInputsState extends State<_SliderWithInputs> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  final FocusNode _minFocusNode = FocusNode();
  final FocusNode _maxFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(text: _formatValue(widget.currentStart));
    _maxController = TextEditingController(text: _formatValue(widget.currentEnd));

    _minFocusNode.addListener(() {
      if (!_minFocusNode.hasFocus) {
        _applyManualInput();
      }
    });

    _maxFocusNode.addListener(() {
      if (!_maxFocusNode.hasFocus) {
        _applyManualInput();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SliderWithInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller text if not currently focused by the user
    if (!_minFocusNode.hasFocus &&
        (oldWidget.currentStart != widget.currentStart ||
            _minController.text.isEmpty)) {
      _minController.text = _formatValue(widget.currentStart);
    }
    if (!_maxFocusNode.hasFocus &&
        (oldWidget.currentEnd != widget.currentEnd ||
            _maxController.text.isEmpty)) {
      _maxController.text = _formatValue(widget.currentEnd);
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.isDecimal) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(0);
  }

  void _applyManualInput() {
    final rawMin = _minController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final rawMax = _maxController.text.replaceAll(RegExp(r'[^0-9.]'), '');

    double? parsedMin = double.tryParse(rawMin);
    double? parsedMax = double.tryParse(rawMax);

    parsedMin ??= widget.minValue;
    parsedMax ??= widget.maxValue;

    parsedMin = parsedMin.clamp(widget.minValue, widget.maxValue);
    parsedMax = parsedMax.clamp(widget.minValue, widget.maxValue);

    if (parsedMin > parsedMax) {
      final tmp = parsedMin;
      parsedMin = parsedMax;
      parsedMax = tmp;
    }

    _minController.text = _formatValue(parsedMin);
    _maxController.text = _formatValue(parsedMax);

    widget.onChanged(parsedMin, parsedMax);
  }

  @override
  Widget build(BuildContext context) {
    final startClamped = widget.currentStart.clamp(widget.minValue, widget.maxValue);
    final endClamped = widget.currentEnd.clamp(widget.minValue, widget.maxValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            widget.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: const Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _buildEditableBox(
              controller: _minController,
              focusNode: _minFocusNode,
              prefix: widget.prefix,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: RangeSlider(
                  values: RangeValues(startClamped, endClamped),
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: widget.divisions,
                  activeColor: const Color(0xFF1E6FBA),
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (vals) {
                    _minController.text = _formatValue(vals.start);
                    _maxController.text = _formatValue(vals.end);
                    widget.onChanged(vals.start, vals.end);
                  },
                ),
              ),
            ),
            _buildEditableBox(
              controller: _maxController,
              focusNode: _maxFocusNode,
              prefix: widget.prefix,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditableBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String prefix,
  }) {
    return Container(
      width: widget.prefix.isNotEmpty ? 68 : 56,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: focusNode.hasFocus ? const Color(0xFF1E6FBA) : const Color(0xFFCCCCCC),
          width: focusNode.hasFocus ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                prefix,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDecimal,
                signed: false,
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF222222),
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _applyManualInput(),
            ),
          ),
        ],
      ),
    );
  }
}

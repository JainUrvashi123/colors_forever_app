import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/diamond_catalog_provider.dart';
import '../providers/diamond_filter_provider.dart';
import '../widgets/diamond_grid_card.dart';
import '../widgets/diamond_list_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/whatsapp_share_dialog.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../../../auth/presentation/views/login_screen.dart';
import 'solitaire_cart_screen.dart';


class SolitaireCatalogScreen extends StatefulWidget {
  const SolitaireCatalogScreen({super.key});

  @override
  State<SolitaireCatalogScreen> createState() => _SolitaireCatalogScreenState();
}

class _SolitaireCatalogScreenState extends State<SolitaireCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedSerialNos = {};
  bool _isColorPaletteExpanded = false;

  void _toggleSelectAll(List<dynamic> diamonds) {
    setState(() {
      if (_selectedSerialNos.length == diamonds.length && diamonds.isNotEmpty) {
        _selectedSerialNos.clear();
      } else {
        _selectedSerialNos.clear();
        for (final d in diamonds) {
          _selectedSerialNos.add(d.serialNo.toString());
        }
      }
    });
  }

  void _toggleSelectDiamond(String serialNo) {
    setState(() {
      if (_selectedSerialNos.contains(serialNo)) {
        _selectedSerialNos.remove(serialNo);
      } else {
        _selectedSerialNos.add(serialNo);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final catalogProvider = context.read<DiamondCatalogProvider>();
      final filterProvider = context.read<DiamondFilterProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final indexData = await catalogProvider.loadSolitaireIndex();
      filterProvider.setSolitaireIndex(indexData);

      if (filterProvider.filter.searchQuery.isNotEmpty) {
        _searchController.text = filterProvider.filter.searchQuery;
      }
      catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
      if (authProvider.isAuthenticated) {
        catalogProvider.fetchCart();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      final catalogProvider = context.read<DiamondCatalogProvider>();
      final filter = context.read<DiamondFilterProvider>().filter;
      if (catalogProvider.canLoadMore) {
        catalogProvider.loadMore(filter);
      }
    }
  }

  void _openFilterSheet() {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
            child: const FilterBottomSheet(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.90,
          child: const FilterBottomSheet(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = context.watch<DiamondCatalogProvider>();
    final filterProvider = context.watch<DiamondFilterProvider>();
    final filter = filterProvider.filter;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
              // 1. Corrected Luxury Search Pill matching Home Screen & User Reference
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 22, color: AppColors.richGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search Color, Shape, Weight, Lab, Item#...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (val) {
                          filterProvider.setSearchQuery(val);
                          catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _searchController.clear();
                          filterProvider.setSearchQuery('');
                          catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
                        },
                      ),
                    const SizedBox(width: 6),

                    // Filter Button with Badge
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.midnightOnyx, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(50),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tune, size: 16, color: AppColors.champagneGold),
                            const SizedBox(width: 4),
                            Text(
                              'Filter',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            if (filter.activeFilterCount > 0) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.champagneGold,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${filter.activeFilterCount}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.black,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Pinned Quick-Color Swatch Carousel
            // _buildQuickColorBar(filterProvider, catalogProvider),

            // 3. Active Filters Chips
            if (filter.hasActiveFilters) _buildActiveFilterChips(filterProvider, catalogProvider),

            // 4. Controls Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.champagneGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${catalogProvider.totalRecords} Solitaire Diamonds Available',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                    Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
                          final showBadge = isAuthenticated && catalogProvider.cartCount > 0;
                          return IconButton(
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 28),
                                if (showBadge)
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.champagneGold,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${catalogProvider.cartCount}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            tooltip: showBadge ? 'View Cart (${catalogProvider.cartCount})' : 'View Cart',
                            onPressed: () async {
                              final auth = context.read<AuthProvider>();
                              if (!auth.isAuthenticated) {
                                GuestGuard.requireLogin(
                                  context,
                                  actionLabel: 'view your cart',
                                );
                                return;
                              }
                              await SolitaireCartScreen.show(context);
                              if (context.mounted && context.read<AuthProvider>().isAuthenticated) {
                                context.read<DiamondCatalogProvider>().fetchCart();
                              }
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 26),
                        tooltip: 'Share via WhatsApp',
                        onPressed: () {
                          if (_selectedSerialNos.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select at least one diamond first.',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.midnightOnyx,
                              ),
                            );
                            return;
                          }

                          final selectedDiamonds = catalogProvider.diamonds
                              .where((d) => _selectedSerialNos.contains(d.serialNo))
                              .toList();

                          if (selectedDiamonds.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (_) => WhatsAppShareDialog(
                                diamonds: selectedDiamonds,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select at least one diamond first.',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.midnightOnyx,
                              ),
                            );
                          }
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.swap_vert, color: AppColors.midnightOnyx, size: 25),
                        tooltip: 'Sort by',
                        initialValue: filter.sortBy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          filterProvider.setSortBy(val);
                          catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: '', child: Text('Default Order')),
                          const PopupMenuItem(value: 'weight_l', child: Text('Carat: Low to High')),
                          const PopupMenuItem(value: 'weight_h', child: Text('Carat: High to Low')),
                          const PopupMenuItem(value: 'shape_l', child: Text('Shape: Ascending')),
                          const PopupMenuItem(value: 'shape_h', child: Text('Shape: Descending')),
                          const PopupMenuItem(value: 'color_l', child: Text('Color: Ascending')),
                          const PopupMenuItem(value: 'color_h', child: Text('Color: Descending')),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          catalogProvider.isGridView ? Icons.view_agenda_outlined : Icons.grid_view,
                          color: AppColors.midnightOnyx,
                          size: 25,
                        ),
                        tooltip: catalogProvider.isGridView ? 'Dossier View' : 'Grid View',
                        onPressed: catalogProvider.toggleViewMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Guest notification banner: informing user that prices require login
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isAuthenticated) return const SizedBox.shrink();
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.warmGoldTint,
                      border: Border(
                        bottom: BorderSide(color: AppColors.champagneGold.withAlpha(80)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.richGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Wholesale B2B prices require account login. Tap to Sign In.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.richGold,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.richGold),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Select All Checkbox & Batch Actions Bar
            if (catalogProvider.diamonds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight),
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: catalogProvider.diamonds.isNotEmpty &&
                            _selectedSerialNos.length == catalogProvider.diamonds.length,
                        onChanged: (_) => _toggleSelectAll(catalogProvider.diamonds),
                        activeColor: AppColors.richGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select All (${_selectedSerialNos.length}/${catalogProvider.diamonds.length})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedSerialNos.isNotEmpty) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whatsapp,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 13, color: Colors.white),
                        label: Text(
                          'Share (${_selectedSerialNos.length})',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          final selectedDiamonds = catalogProvider.diamonds
                              .where((d) => _selectedSerialNos.contains(d.serialNo))
                              .toList();
                          showDialog(
                            context: context,
                            builder: (_) => WhatsAppShareDialog(diamonds: selectedDiamonds),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: Text(
                          'Add (${_selectedSerialNos.length})',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isAuthenticated) {
                            GuestGuard.requireLogin(
                              context,
                              actionLabel: 'add diamonds to your cart',
                            );
                            return;
                          }
                          final res = await catalogProvider.addToCart(_selectedSerialNos.toList());
                          if (context.mounted) {
                            final msg = res['message']?.toString() ?? 'Added selected to cart!';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),

            if (catalogProvider.isUsingFallback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: AppColors.warmGoldTint,
                child: Row(
                  children: [
                    const Icon(Icons.diamond_outlined, size: 14, color: AppColors.textGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Displaying cached Colors Forever inventory',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Diamonds List / Grid Body
            Expanded(
              child: catalogProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.champagneGold),
                    )
                  : catalogProvider.diamonds.isEmpty
                      ? _buildEmptyState(filterProvider, catalogProvider)
                      : _buildResponsiveCatalog(catalogProvider, filterProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildQuickColorBar(
    DiamondFilterProvider filterProvider,
    DiamondCatalogProvider catalogProvider,
  ) {
    final selectedCount = filterProvider.filter.selectedColors.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isColorPaletteExpanded = !_isColorPaletteExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.palette_outlined, size: 16, color: AppColors.richGold),
                  const SizedBox(width: 8),
                  Text(
                    'Color Palette',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warmGoldTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.champagneGold.withAlpha(140)),
                      ),
                      child: Text(
                        '$selectedCount selected',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.richGold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _isColorPaletteExpanded ? 'Collapse' : 'Show Colors',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.richGold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isColorPaletteExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.richGold,
                  ),
                ],
              ),
            ),
          ),
          if (_isColorPaletteExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: DiamondSwatchGrid(
                padding: EdgeInsets.zero,
                colors: DiamondFilterProvider.availableColors,
                selectedColors: filterProvider.filter.selectedColors.toSet(),
                onColorSelected: (col) {
                  filterProvider.toggleColor(col);
                  catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(
    DiamondFilterProvider filterProvider,
    DiamondCatalogProvider catalogProvider,
  ) {
    final filter = filterProvider.filter;
    final chips = <Widget>[];

    void addChip(String label, VoidCallback onRemove, {String? diamondImage}) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Chip(
            avatar: diamondImage != null
                ? Image.asset(diamondImage, width: 18, height: 18, fit: BoxFit.contain)
                : null,
            label: Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5, fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.warmGoldTint,
            side: BorderSide(color: AppColors.champagneGold.withAlpha(100)),
            deleteIcon:
                const Icon(Icons.close, size: 12, color: AppColors.textGold),
            onDeleted: () {
              onRemove();
              catalogProvider.fetchDiamonds(filterProvider.filter,
                  refresh: true);
            },
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    for (final c in filter.selectedColors) {
      addChip(c, () => filterProvider.toggleColor(c),
          diamondImage: AppAssets.getDiamondImageForShade(c));
    }
    for (final s in filter.selectedShades) {
      addChip(s, () => filterProvider.toggleShade(s),
          diamondImage: AppAssets.getDiamondImageForShade(s));
    }
    for (final sh in filter.selectedShapes) {
      addChip(sh, () => filterProvider.toggleShape(sh));
    }
    for (final cl in filter.selectedClarities) {
      addChip(cl, () => filterProvider.toggleClarity(cl));
    }
    for (final l in filter.selectedLabs) {
      addChip(l, () => filterProvider.toggleLab(l));
    }
    if (filter.location != null && filter.location!.isNotEmpty) {
      addChip('Loc: ${filter.location}', () => filterProvider.setLocation(null));
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _buildEmptyState(
    DiamondFilterProvider filterProvider,
    DiamondCatalogProvider catalogProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmGoldTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.champagneGold.withAlpha(100)),
            ),
            child: Image.asset(
              AppAssets.getDiamondImageForShade(
                      filterProvider.filter.selectedColors.isNotEmpty
                          ? filterProvider.filter.selectedColors.first
                          : null) ??
                  AppAssets.solitaireDiamonds,
              height: 54,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Rare Diamonds Found',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No diamonds match your search criteria.\nPlease email requests@colorsforever.com for special custom requests.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset All Criteria'),
            onPressed: () {
              _searchController.clear();
              filterProvider.resetFilters();
              catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCatalog(
    DiamondCatalogProvider catalogProvider,
    DiamondFilterProvider filterProvider,
  ) {
    final diamonds = catalogProvider.diamonds;
    final isGrid = catalogProvider.isGridView;

    final Widget childView = isGrid
        ? LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int crossAxisCount = 2;
              double aspectRatio = 0.65;

              if (width < 360) {
                crossAxisCount = 2;
                aspectRatio = 0.58;
              } else if (width <= 550) {
                crossAxisCount = 2;
                aspectRatio = 0.63;
              } else if (width <= 850) {
                crossAxisCount = 3;
                aspectRatio = 0.68;
              } else if (width <= 1200) {
                crossAxisCount = 4;
                aspectRatio = 0.72;
              } else {
                crossAxisCount = 5;
                aspectRatio = 0.75;
              }

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final diamond = diamonds[index];
                          final isSelected = _selectedSerialNos.contains(diamond.serialNo);
                          return DiamondGridCard(
                            diamond: diamond,
                            isFavorite: catalogProvider.isFavorite(diamond.serialNo),
                            onToggleFavorite: () => catalogProvider.toggleFavorite(diamond.serialNo),
                            isSelected: isSelected,
                            onToggleSelect: (_) => _toggleSelectDiamond(diamond.serialNo),
                          );
                        },
                        childCount: diamonds.length,
                      ),
                    ),
                  ),
                  if (catalogProvider.canLoadMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Center(
                          child: catalogProvider.isLoadingMore
                              ? const CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagneGold)
                              : OutlinedButton(
                                  onPressed: () => catalogProvider.loadMore(filterProvider.filter),
                                  child: const Text('Discover More Rare Diamonds...'),
                                ),
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        : ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: diamonds.length + (catalogProvider.canLoadMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == diamonds.length) {
                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: catalogProvider.isLoadingMore
                        ? const CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagneGold)
                        : OutlinedButton(
                            onPressed: () => catalogProvider.loadMore(filterProvider.filter),
                            child: const Text('Discover More Rare Diamonds...'),
                          ),
                  ),
                );
              }
              final diamond = diamonds[index];
              final isSelected = _selectedSerialNos.contains(diamond.serialNo);
              return DiamondListCard(
                diamond: diamond,
                isFavorite: catalogProvider.isFavorite(diamond.serialNo),
                onToggleFavorite: () => catalogProvider.toggleFavorite(diamond.serialNo),
                isSelected: isSelected,
                onToggleSelect: (_) => _toggleSelectDiamond(diamond.serialNo),
              );
            },
          );

    return RefreshIndicator(
      color: AppColors.champagneGold,
      onRefresh: () => catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true),
      child: childView,
    );
  }
}

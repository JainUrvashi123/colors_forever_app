// ignore_for_file: unused_element, unused_field, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/widgets/app_background.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/views/login_screen.dart';
import '../../auth/presentation/views/profile_edit_screen.dart';
import '../../auth/presentation/widgets/user_profile_modal.dart';
import '../../diamonds/domain/entities/diamond.dart';
import '../../diamonds/presentation/providers/diamond_catalog_provider.dart';
import '../../diamonds/presentation/providers/diamond_filter_provider.dart';
import '../../diamonds/presentation/views/solitaire_catalog_screen.dart';
import '../../diamonds/presentation/widgets/diamond_grid_card.dart';
import '../../melee/presentation/views/melee_screen.dart';
// import '../../melee/presentation/widgets/melee_cart_sheet.dart';
import '../../auth/presentation/widgets/markup_toggle_dialog.dart';
import '../../auth/presentation/widgets/markup_toggle_switch.dart';
import '../../auth/presentation/widgets/logout_confirmation_dialog.dart';
import '../../jewelry/presentation/views/jewelry_screen.dart';
import '../../contact/presentation/views/contact_screen.dart';
import 'haute_bottom_nav_bar.dart';

class _HeroBannerData {
  final String title;
  final String category;
  final String imageAsset;
  final int targetIndex;
  final String badgeText;
  final String ctaText;

  const _HeroBannerData({
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.targetIndex,
    required this.badgeText,
    required this.ctaText,
  });
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0; // 0: Home | 1: Melee | 2: Solitaire | 3: Jewelry | 4: Contact Us
  late final PageController _bannerController;
  int _currentBannerIndex = 0;

  static const List<_HeroBannerData> _heroBanners = [
    _HeroBannerData(
      title: 'Melee Diamonds',
      category: 'CALIBRATED PARCELS',
      imageAsset: AppAssets.meleeDiamonds,
      targetIndex: 1,
      badgeText: '0.005 - 0.20 CARAT',
      ctaText: 'Shop Melee Diamonds',
    ),
    _HeroBannerData(
      title: 'Solitaire Diamonds',
      category: 'CERTIFIED NATURAL FANCY',
      imageAsset: AppAssets.solitaireDiamonds,
      targetIndex: 2,
      badgeText: 'GIA & IGI CERTIFIED',
      ctaText: 'Shop Solitaire Diamonds',
    ),
    _HeroBannerData(
      title: 'Color Jewelry',
      category: 'BESPOKE FINE JEWELRY',
      imageAsset: AppAssets.colorJewelry,
      targetIndex: 3,
      badgeText: '18K & PLATINUM',
      ctaText: 'Discover Color Jewelry',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.90);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (context.read<AuthProvider>().isAuthenticated) {
          context.read<DiamondCatalogProvider>().fetchCart();
        }
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (isWide) _buildWebHeaderBar(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildBoutiqueHomeScreen(),    // 0: HOME
                    const MeleeScreen(),           // 1: MELEE (https://colorsforever.com/melle-diamond)
                    const SolitaireCatalogScreen(), // 2: SOLITAIRE (https://colorsforever.com/color-diamond)
                    const JewelryScreen(),          // 3: JEWELRY (https://colorsforever.com/color-jewelry)
                    const ContactScreen(),          // 4: CONTACT US (https://colorsforever.com/contact-us)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : HauteBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }

  Widget _buildWebHeaderBar() {
    final authProvider = context.watch<AuthProvider>();
    // final meleeProvider = context.watch<MeleeProvider>();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(120), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Brand Logo
          InkWell(
            onTap: () => setState(() => _currentIndex = 0),
            child: Image.asset(
              AppAssets.logo,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'Colors Forever',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.richGold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const Spacer(),

          // Navigation Links: HOME | MELEE | SOLITAIRE | JEWELRY | CONTACT US
          _buildWebNavItem(0, 'HOME'),
          const SizedBox(width: 20),
          _buildWebNavItem(1, 'MELEE'),
          const SizedBox(width: 20),
          _buildWebNavItem(2, 'SOLITAIRE'),
          const SizedBox(width: 20),
          _buildWebNavItem(3, 'JEWELRY'),
          const SizedBox(width: 20),
          _buildWebNavItem(4, 'CONTACT US'),
          const SizedBox(width: 24),

          // MY ACCOUNT ▾ (or SIGN IN)
          if (authProvider.isAuthenticated)
            PopupMenuButton<String>(
              tooltip: 'My Account',
              onSelected: (val) async {
                if (val == 'profile') {
                  ProfileEditScreen.show(context);
                } else if (val == 'markup') {
                  MarkupToggleDialog.show(context);
                } else if (val == 'logout') {
                  LogoutConfirmationDialog.show(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppColors.richGold),
                      const SizedBox(width: 10),
                      Text(authProvider.currentUser!.fullName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'markup',
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 18, color: AppColors.richGold),
                      const SizedBox(width: 10),
                      Text('Dealer Markup Settings', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: Color(0xFFE53935)),
                      const SizedBox(width: 10),
                      Text('Log Out', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE53935), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 17, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'MY ACCOUNT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textPrimary),
                ],
              ),
            )
          else
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 17, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'SIGN IN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 16),

          // Green Toggle Switch [ON / OFF]
          const MarkupToggleSwitch(),
          const SizedBox(width: 16),

          /*
          // 🛒 Cart with Item Count
          InkWell(
            onTap: () => MeleeCartSheet.show(context, meleeProvider),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    '${meleeProvider.cartCount}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildWebNavItem(int index, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.richGold : AppColors.textPrimary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 0: HOME (OFFICIAL COLORS FOREVER BOUTIQUE DESIGN)
  // -------------------------------------------------------------
  Widget _buildBoutiqueHomeScreen() {
    final authProvider = context.watch<AuthProvider>();
    final catalogProvider = context.watch<DiamondCatalogProvider>();
    final filterProvider = context.watch<DiamondFilterProvider>();
    final diamonds = catalogProvider.diamonds;

    final String welcomeName;
    if (authProvider.currentUser != null && authProvider.currentUser!.fullName.trim().isNotEmpty) {
      final raw = authProvider.currentUser!.fullName.trim();
      welcomeName = raw.isNotEmpty ? (raw[0].toUpperCase() + raw.substring(1)) : 'User';
    } else if (authProvider.savedUsername != null && authProvider.savedUsername!.trim().isNotEmpty) {
      final uname = authProvider.savedUsername!.trim();
      final part = uname.contains('@') ? uname.split('@').first : uname;
      welcomeName = part.isNotEmpty ? (part[0].toUpperCase() + part.substring(1)) : 'Guest';
    } else if (authProvider.isAuthenticated) {
      welcomeName = 'Member';
    } else {
      welcomeName = 'Guest';
    }

    return RefreshIndicator(
      color: AppColors.champagneGold,
      onRefresh: () => catalogProvider.fetchDiamonds(filterProvider.filter, refresh: true),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. Boutique Brand Header: Welcome Greeting + Profile / Sign In
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Welcome Greeting (Replaces Brand Logo & ON/OFF Toggle)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome, $welcomeName',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authProvider.isAuthenticated
                              ? 'Colors Forever Boutique'
                              : 'Explore Natural Fancy Diamonds',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Wholesale Member Indicator Badge (if logged in)
                  if (authProvider.isAuthenticated) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warmGoldTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 12, color: AppColors.richGold),
                          const SizedBox(width: 3),
                          Text(
                            'Wholesale',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.richGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // User Avatar / Sign In Action
                  authProvider.isAuthenticated
                      ? InkWell(
                          onTap: () => UserProfileModal.show(context, authProvider),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.midnightOnyx, AppColors.primary],
                              ),
                              border: Border.all(color: AppColors.champagneGold, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                authProvider.currentUser!.fullName.isNotEmpty
                                    ? authProvider.currentUser!.fullName[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.champagneGold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warmGoldTint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.login, size: 14, color: AppColors.richGold),
                                const SizedBox(width: 4),
                                Text(
                                  'Sign In',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.richGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  /*
                  // Cart Icon Button
                  Consumer<MeleeProvider>(
                    builder: (context, melee, _) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () => MeleeCartSheet.show(context, melee),
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.shopping_cart_outlined, size: 21, color: AppColors.textPrimary),
                              ),
                              if (melee.cartCount > 0)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.richGold,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                    child: Center(
                                      child: Text(
                                        '${melee.cartCount}',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  */
                ],
              ),
            ),
            const SizedBox(height: 14),

            /*
            // 2. Search Bar Pill with Circular Gold Search Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: AppColors.richGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search diamonds by shape, color, clarity...',
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
                          setState(() => _currentIndex = 2); // Jump to Solitaire catalog
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _currentIndex = 2),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.champagneGold, AppColors.richGold],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.search, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Quick Department Category Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickCategoryChip(
                    icon: Icons.grain,
                    label: 'Melee Diamonds',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickCategoryChip(
                    icon: Icons.diamond_outlined,
                    label: 'Solitaire Catalog',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickCategoryChip(
                    icon: Icons.auto_awesome,
                    label: 'Fine Jewelry',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickCategoryChip(
                    icon: Icons.chat_bubble_outline,
                    label: 'Concierge',
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4. Headline / Welcome Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.isAuthenticated
                        ? 'Welcome, ${authProvider.currentUser!.fullName}'
                        : 'Discover Colors Forever',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.isAuthenticated
                        ? '${authProvider.currentUser!.company} • Wholesale Member'
                        : 'Natural Color Enhanced Fine Diamonds & Jewelry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Hero Banner Carousel with Official Website Banners
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _heroBanners.length,
                onPageChanged: (index) {
                  setState(() => _currentBannerIndex = index);
                },
                itemBuilder: (context, index) {
                  final banner = _heroBanners[index];
                  return _buildHeroBannerCard(banner);
                },
              ),
            ),
            const SizedBox(height: 10),

            // 6. Luxury Banner Dots Indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_heroBanners.length, (index) {
                  final isSelected = _currentBannerIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.richGold : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            */

            // 7. Curated Collections Showcase (Website Three Pillars)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Our Collections',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentIndex = 2),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Tap to explore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.richGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildCollectionBoutiqueCard(
                    title: 'Melee Diamonds',
                    badge: 'CALIBRATED SIZES',
                    subtitle: 'Full cuts from 0.005 to 0.20 Carat in round brilliant calibrated parcels and 10+ vivid fancy color shades.',
                    imageAsset: AppAssets.meleeDiamonds,
                    ctaText: 'Shop Melee Parcels',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildCollectionBoutiqueCard(
                    title: 'Solitaire Diamonds',
                    badge: 'GIA & IGI CERTIFIED',
                    subtitle: 'Certified natural fancy color diamonds in Round, Cushion, Pear, Oval, Princess & Heart cuts with live inventory.',
                    imageAsset: AppAssets.solitaireDiamonds,
                    ctaText: 'Browse Solitaires',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  const SizedBox(height: 12),
                  _buildCollectionBoutiqueCard(
                    title: 'Fine Color Jewelry',
                    badge: 'HANDCRAFTED 18K & PLATINUM',
                    subtitle: 'Eternity bands, tennis bracelets, halo solitaire rings, and custom diamond pendants handcrafted to perfection.',
                    imageAsset: AppAssets.colorJewelry,
                    ctaText: 'Explore Jewelry',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 9. Live Solitaire Inventory Slider (if available)
            if (diamonds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Featured Solitaires',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Text(
                        'View All (${catalogProvider.totalRecords > 0 ? catalogProvider.totalRecords : catalogProvider.diamonds.length}) →',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.richGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: diamonds.length > 8 ? 8 : diamonds.length,
                  itemBuilder: (context, idx) {
                    final diamond = diamonds[idx];
                    return _buildFeaturedDiamondCard(diamond, authProvider);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 10. Wholesale Trust & Guarantee Highlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.goldBorder.withAlpha(160)),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.warmGoldTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium_outlined,
                            size: 20,
                            color: AppColors.richGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Colors Forever Distinction',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Lotus Colors, Inc. — Premier Manufacturer of Natural Color Enhanced Diamonds',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: AppColors.border.withAlpha(120)),
                    const SizedBox(height: 14),
                    _buildTrustRow(
                      Icons.diamond_outlined,
                      '100% Natural Diamonds',
                      'Permanent color enhancement on natural mined diamonds only.',
                    ),
                    const SizedBox(height: 12),
                    _buildTrustRow(
                      Icons.verified_outlined,
                      'GIA & IGI Certifications',
                      'Independent lab grading reports and digital report verification.',
                    ),
                    const SizedBox(height: 12),
                    _buildTrustRow(
                      Icons.local_shipping_outlined,
                      'Fully Insured Global Delivery',
                      'Express door-to-door insured transit for all wholesale orders.',
                    ),
                    const SizedBox(height: 12),
                    _buildTrustRow(
                      Icons.chat_bubble_outline,
                      'Dedicated B2B Concierge',
                      'Instant quotes, custom parcel layouts & memo requests.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBannerCard(_HeroBannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.goldBorder.withAlpha(180), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => setState(() => _currentIndex = banner.targetIndex),
          child: Stack(
            children: [
              // 1. Official Banner Image - covers complete card edge-to-edge
              Positioned.fill(
                child: Image.asset(
                  banner.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),

              // 4. Interactive Call to Action Bar at Bottom
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.midnightOnyx, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.champagneGold, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.ctaText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.champagneGold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.champagneGold),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategoryChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.richGold),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionBoutiqueCard({
    required String title,
    required String badge,
    required String subtitle,
    required String imageAsset,
    required String ctaText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 98,
                  decoration: BoxDecoration(
                    color: AppColors.warmGoldTint.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.champagneGold.withAlpha(80)),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.warmGoldTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.richGold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            ctaText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.richGold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 12, color: AppColors.richGold),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedDiamondCard(Diamond diamond, AuthProvider authProvider) {
    final catalogProvider = Provider.of<DiamondCatalogProvider>(context, listen: false);
    return Container(
      width: 175,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: DiamondGridCard(
        diamond: diamond,
        isFavorite: catalogProvider.isFavorite(diamond.serialNo),
        onToggleFavorite: () => catalogProvider.toggleFavorite(diamond.serialNo),
      ),
    );
  }

  Widget _buildTrustRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.warmGoldTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.champagneGold.withAlpha(80)),
          ),
          child: Icon(icon, size: 17, color: AppColors.richGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  // -------------------------------------------------------------
  // TAB 3: COLOR JEWELRY (https://colorsforever.com/color-jewelry)
  // -------------------------------------------------------------
  
  Widget _buildJewelryScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Color Jewelry',
          style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 22),
            onPressed: () => _launchWhatsApp('Inquiring about Colors Forever Fine Color Jewelry collection.'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.goldBorder),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.colorJewelry),
                  fit: BoxFit.contain,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fine Jewelry with Color Diamonds',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bespoke eternity bands, halo rings, tennis bracelets, and diamond pendants handcrafted with certified natural color enhanced diamonds.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildJewelryItem('Fancy Blue Halo Solitaire Ring', '18K White Gold • 1.50 Carat Total', '\$ 8,450.00'),
            const SizedBox(height: 10),
            _buildJewelryItem('Canary Yellow Diamond Eternity Band', 'Platinum • 2.20 Carat Total', '\$ 12,900.00'),
            const SizedBox(height: 10),
            _buildJewelryItem('Multi-Color Diamond Tennis Bracelet', '18K Rose Gold • 5.00 Carat Total', '\$ 19,500.00'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightOnyx,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.champagneGold),
                ),
                child: Text(
                  'Explore Custom Jewelry Commissions',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _launchWhatsApp('Custom jewelry design inquiry'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelryItem(String title, String subtitle, String price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price, style: AppTheme.priceStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.richGold)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: CONTACT US (https://colorsforever.com/contact-us)
  // -------------------------------------------------------------
  Widget _buildContactScreen() {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppColors.midnightOnyx, AppColors.primary]),
                      border: Border.all(color: AppColors.champagneGold, width: 2),
                    ),
                    child: const Center(child: Icon(Icons.diamond, color: AppColors.champagneGold, size: 36)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Colors Forever',
                    style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Global Color Enhanced Diamond Purveyor',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Wholesale Member Portal / Account Status Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: authProvider.isAuthenticated
                      ? AppColors.champagneGold
                      : AppColors.border,
                  width: authProvider.isAuthenticated ? 1.5 : 1.0,
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.midnightOnyx, AppColors.primary],
                      ),
                      border: Border.all(color: AppColors.champagneGold, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(
                        authProvider.isAuthenticated ? Icons.person : Icons.lock_outline,
                        color: AppColors.champagneGold,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.isAuthenticated
                              ? authProvider.currentUser!.fullName
                              : 'Wholesale Member Portal',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          authProvider.isAuthenticated
                              ? '${authProvider.currentUser!.company} • Group ${authProvider.currentUser!.group}'
                              : 'Sign in for wholesale pricing & inventory',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (authProvider.isAuthenticated) {
                        UserProfileModal.show(context, authProvider);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.richGold,
                    ),
                    child: Text(
                      authProvider.isAuthenticated ? 'Profile' : 'Sign In',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Global Vaults & Offices', style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _buildOfficeCard('New York (NY)', '580 5th Avenue, Suite 1204, New York, NY 10036'),
            const SizedBox(height: 10),
            _buildOfficeCard('Hong Kong (HK)', 'Kowloon, Hong Kong SAR'),
            const SizedBox(height: 10),
            _buildOfficeCard('Japan (JP)', 'Tokyo, Japan'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Official Email Inquiries', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('requests@colorsforever.com', style: TextStyle(color: AppColors.primary)),
                    const SizedBox(height: 10),
                    const Text('Official Website', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('https://colorsforever.com', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsapp,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20),
                label: Text(
                  'Chat with Concierge on WhatsApp',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _launchWhatsApp('Hello Colors Forever Concierge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp(String message) async {
    await WhatsAppHelper.launchWhatsApp(context, message);
  }

  Widget _buildOfficeCard(String city, String address) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warmGoldTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: AppColors.richGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(address, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

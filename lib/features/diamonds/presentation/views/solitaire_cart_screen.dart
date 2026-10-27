import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../domain/entities/cart_response.dart';
import '../providers/diamond_catalog_provider.dart';
import '../widgets/whatsapp_share_dialog.dart';
import '../widgets/cart_request_dialog.dart';
import 'diamond_detail_screen.dart';


class SolitaireCartScreen extends StatefulWidget {
  const SolitaireCartScreen({super.key});

  static Future<dynamic> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SolitaireCartScreen(),
      ),
    );
  }

  @override
  State<SolitaireCartScreen> createState() => _SolitaireCartScreenState();
}

class _SolitaireCartScreenState extends State<SolitaireCartScreen> {
  final Set<String> _selectedCartIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<DiamondCatalogProvider>().fetchCart();
      }
    });
  }

  void _toggleSelectAll(List<SolitaireCartItem> items) {
    setState(() {
      if (_selectedCartIds.length == items.length) {
        _selectedCartIds.clear();
      } else {
        _selectedCartIds.addAll(items.map((i) => i.cartId));
      }
    });
  }

  void _toggleSelectItem(String cartId) {
    setState(() {
      if (_selectedCartIds.contains(cartId)) {
        _selectedCartIds.remove(cartId);
      } else {
        _selectedCartIds.add(cartId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Guest guard: show login prompt for unauthenticated users
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Diamond Cart',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: _buildGuestCartView(context),
        ),
      );
    }

    return Consumer<DiamondCatalogProvider>(
      builder: (context, catalogProvider, _) {
        final cartItems = catalogProvider.cartItems;
        final isLoading = catalogProvider.isLoadingCart;

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Diamond Cart List (${catalogProvider.cartCount})',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                if (cartItems.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.richGold),
                    tooltip: 'Refresh Cart',
                    onPressed: () => catalogProvider.fetchCart(),
                  ),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.champagneGold,
              onRefresh: () => catalogProvider.fetchCart(),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.champagneGold),
                    )
                  : cartItems.isEmpty
                      ? _buildEmptyCart(context, catalogProvider)
                      : Column(
                          children: [
                            // 1. Top Web Action Bar (Delete Cart | Request Memo/Hold | Email Cart)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              color: Colors.white,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildHeaderActionButton(
                                      icon: Icons.delete_outline,
                                      label: 'Delete Cart',
                                      fillColor: const Color(0xFF64B5F6),
                                      textColor: Colors.white,
                                      onTap: () {
                                        if (_selectedCartIds.isNotEmpty) {
                                          _showConfirmDialog(
                                            context,
                                            title: 'Delete Selected Items?',
                                            content: 'Are you sure you want to delete ${_selectedCartIds.length} selected item(s) from your cart?',
                                            confirmLabel: 'Delete (${_selectedCartIds.length})',
                                            onConfirm: () async {
                                              final idsToDelete = _selectedCartIds.toList();
                                              setState(() => _selectedCartIds.clear());
                                              final res = await catalogProvider.deleteCartItems(idsToDelete);
                                              if (context.mounted) {
                                                final msg = res['message']?.toString() ?? 'Cart item(s) deleted successfully!';
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(msg),
                                                    duration: const Duration(seconds: 2),
                                                    backgroundColor: AppColors.primary,
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        } else if (cartItems.isNotEmpty) {
                                          _showConfirmDialog(
                                            context,
                                            title: 'Clear Entire Cart?',
                                            content: 'Are you sure you want to remove all ${cartItems.length} item(s) from your cart?',
                                            confirmLabel: 'Clear All Cart',
                                            onConfirm: () async {
                                              final allIds = cartItems.map((i) => i.cartId).toList();
                                              final res = await catalogProvider.deleteCartItems(allIds);
                                              if (context.mounted) {
                                                final msg = res['message']?.toString() ?? 'Cart cleared successfully!';
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(msg),
                                                    duration: const Duration(seconds: 2),
                                                    backgroundColor: AppColors.primary,
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _buildHeaderActionButton(
                                      iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                                      label: _selectedCartIds.isNotEmpty
                                          ? 'Inquire (${_selectedCartIds.length}) on WhatsApp'
                                          : 'Inquire on WhatsApp',
                                      fillColor: AppColors.whatsapp,
                                      textColor: Colors.white,
                                      onTap: () {
                                        final targetItems = _selectedCartIds.isNotEmpty
                                            ? cartItems.where((i) => _selectedCartIds.contains(i.cartId)).toList()
                                            : cartItems;
                                        final diamonds = targetItems.map((i) => i.toDiamond()).toList();
                                        showDialog(
                                          context: context,
                                          builder: (_) => WhatsAppShareDialog(diamonds: diamonds),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _buildHeaderActionButton(
                                      icon: Icons.send_outlined,
                                      label: 'Request Memo/Hold',
                                      fillColor: const Color(0xFF64B5F6),
                                      textColor: Colors.white,
                                      onTap: () {
                                        if (_selectedCartIds.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please select at least select one'),
                                              backgroundColor: AppColors.midnightOnyx,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (_) => const CartRequestDialog(
                                            initialRequestType: 'Request Memo',
                                            initialCart: 'Loose Diamond Cart',
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _buildHeaderActionButton(
                                      icon: Icons.email_outlined,
                                      label: 'Email Cart',
                                      fillColor: const Color(0xFF64B5F6),
                                      textColor: Colors.white,
                                      onTap: () {
                                        if (_selectedCartIds.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Please select at least select one'),
                                              backgroundColor: AppColors.midnightOnyx,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        showDialog(
                                          context: context,
                                          builder: (_) => const CartRequestDialog(
                                            initialRequestType: 'Email Cart',
                                            initialCart: 'Loose Diamond Cart',
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Banner Header Title Bar (Matches Grey Banner in Website Mockup)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                border: Border(
                                  top: BorderSide(color: Color(0xFFCBD5E1)),
                                  bottom: BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _selectedCartIds.length == cartItems.length && cartItems.isNotEmpty,
                                      onChanged: (_) => _toggleSelectAll(cartItems),
                                      activeColor: const Color(0xFF1E6FBA),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Diamond Cart List',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${cartItems.length} Item(s)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3. Grid of Diamond Cart Cards (Matching Crisp Website Layout)
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  int crossAxisCount = width > 900
                                      ? 4
                                      : width > 600
                                          ? 3
                                          : 2;

                                  final ratio = width > 600 ? 0.62 : 0.54;

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: ratio,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      final isSelected = _selectedCartIds.contains(item.cartId);
                                      return _buildCartCard(context, item, isSelected, catalogProvider);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActionButton({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required Color fillColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: fillColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: iconWidget ?? Icon(icon, size: 18, color: textColor),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildCartCard(
    BuildContext context,
    SolitaireCartItem item,
    bool isSelected,
    DiamondCatalogProvider catalogProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox & Diamond Image Preview Box
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                color: const Color(0xFFF1F5F9),
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 26, 12, 8),
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagneGold),
                          ),
                        ),
                        errorWidget: (_, _, _) => Image.asset(
                          AppAssets.getDiamondImageForShade(item.color) ?? AppAssets.noImageDiamond,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        AppAssets.getDiamondImageForShade(item.color) ?? AppAssets.noImageDiamond,
                        fit: BoxFit.contain,
                      ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelectItem(item.cartId),
                    activeColor: const Color(0xFF1E6FBA),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Details & Actions Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title: COLOR WEIGHT GRADE (e.g., AQUA BLUE I 12.53 IF)
                  Text(
                    '${item.color} ${Formatters.formatCarat(item.weight)} ${item.grade}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Lot # / Serial #
                  Text(
                    item.serialNo,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Price per Carat: $16860/Carat
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final priceInfo = PriceHelper.getDiamondPrice(item.toDiamond(), auth);
                      return Text(
                        priceInfo.isHidden
                            ? 'Price Upon Request'
                            : '${priceInfo.formattedPerCt}/Carat',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: priceInfo.isHidden ? 11.5 : 13.5,
                          color: priceInfo.isHidden ? AppColors.primary : const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  // Action Buttons: [ More Details ] & [ Remove ]
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5B9BD5),
                              side: const BorderSide(color: Color(0xFF5B9BD5), width: 1.2),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DiamondDetailScreen(diamond: item.toDiamond()),
                                ),
                              );
                            },
                            child: Text(
                              'More Details',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5B9BD5),
                              side: const BorderSide(color: Color(0xFF5B9BD5), width: 1.2),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              _showConfirmDialog(
                                context,
                                title: 'Remove Item from Cart?',
                                content: 'Are you sure you want to remove item #${item.serialNo} (${item.color} ${Formatters.formatCarat(item.weight)}) from your cart?',
                                confirmLabel: 'Remove Item',
                                onConfirm: () async {
                                  final res = await catalogProvider.deleteCartItems([item.cartId]);
                                  if (context.mounted) {
                                    final msg = res['message']?.toString() ?? 'Cart item deleted successfully!';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            child: Text(
                              'Remove',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, DiamondCatalogProvider catalogProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.richGold),
            const SizedBox(height: 16),
            Text(
              'Your Solitaire Diamond Cart is Empty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse live solitaire inventory to add certified natural fancy diamonds to your cart.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Browse Solitaires'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCartView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.midnightOnyx, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.champagneGold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withAlpha(70),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.champagneGold,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In to View Cart',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.midnightOnyx,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Wholesale pricing, live hold requests, and cart management are reserved for registered partners. Please sign in to view your cart items.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.champagneGold.withAlpha(60)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildGuestBenefitRow(
                    icon: Icons.price_check,
                    title: 'Wholesale B2B Pricing',
                    subtitle: 'Exclusive tiered partner rates and discounts',
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildGuestBenefitRow(
                    icon: Icons.pause_circle_outline,
                    title: 'Live Hold & Memo Requests',
                    subtitle: 'Reserve stones directly from worldwide inventory',
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildGuestBenefitRow(
                    icon: Icons.verified_outlined,
                    title: 'Full Diamond Dossiers',
                    subtitle: 'GIA / IGI certificates, 360° videos & specs',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightOnyx,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 18, color: AppColors.champagneGold),
                    const SizedBox(width: 10),
                    Text(
                      'Sign In to Your Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Browsing Solitaires',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.warmGoldTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.richGold),
        ),
        const SizedBox(width: 14),
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
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

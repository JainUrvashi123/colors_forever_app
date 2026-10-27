import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'package:provider/provider.dart';
import '../../data/models/jewelry_item_model.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../views/jewelry_detail_screen.dart';

class JewelryGridCard extends StatelessWidget {
  final JewelryItem item;

  const JewelryGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item.displayTitle;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JewelryDetailScreen(item: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header & Badges
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: item.imageShow != null && item.imageShow!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: CachedNetworkImage(
                                imageUrl: item.imageShow!,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.diamond_outlined, size: 36, color: AppColors.champagneGold),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.diamond_outlined, size: 36, color: AppColors.champagneGold),
                            ),
                    ),
                    // Gold Karat / Department Badge Top Left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.midnightOnyx.withAlpha(200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.goldKarat.isNotEmpty ? item.goldKarat : item.department,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Diamond Color Badge Top Right
                    if (item.diamondColor.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmGoldTint,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                          ),
                          child: Text(
                            item.diamondColor,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.richGold,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Details Padding
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Title / Description
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Gold Color / Carat Line
                    Row(
                      children: [
                        if (item.goldColor.isNotEmpty)
                          Flexible(
                            child: Text(
                              '${item.goldColor} Gold',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (item.goldColor.isNotEmpty &&
                            (item.parsedCarat > 0 ||
                                (item.totalDiamondWeight.isNotEmpty &&
                                    item.totalDiamondWeight != '0')))
                          Text(
                            ' • ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        if (item.parsedCarat > 0 ||
                            (item.totalDiamondWeight.isNotEmpty &&
                                item.totalDiamondWeight != '0'))
                          Flexible(
                            child: Text(
                              item.parsedCarat > 0
                                  ? Formatters.formatCarat(item.parsedCarat)
                                  : '${item.totalDiamondWeight} Carat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price & WhatsApp Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (!auth.isAuthenticated) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, size: 10, color: AppColors.richGold),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Login for Price',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.richGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final hidden = PriceHelper.isPriceHidden(auth, category: 'jewelry');
                              if (hidden || item.parsedPrice <= 0) {
                                return Text(
                                  'Price on Request',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.richGold,
                                  ),
                                );
                              }
                              return Text(
                                Formatters.formatCurrency(item.parsedPrice, compact: true),
                                style: AppTheme.priceStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.richGold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer<DiamondCatalogProvider>(
                              builder: (context, catalogProvider, _) {
                                final itemId = item.item.isNotEmpty ? item.item : item.stockId;
                                final inCart = catalogProvider.isInCart(itemId);
                                return InkWell(
                                  onTap: () async {
                                    if (itemId.isEmpty) return;
                                    final auth = context.read<AuthProvider>();
                                    if (!auth.isAuthenticated) {
                                      GuestGuard.requireLogin(
                                        context,
                                        actionLabel: 'add jewelry to your cart',
                                      );
                                      return;
                                    }
                                    final res = await catalogProvider.addToCart([itemId]);
                                    if (context.mounted) {
                                      final msg = res['message']?.toString() ?? 'Added to cart!';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: inCart ? AppColors.warmGoldTint : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                      border: inCart ? Border.all(color: AppColors.champagneGold.withAlpha(180)) : null,
                                    ),
                                    child: Icon(
                                      inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                                      size: 14,
                                      color: inCart ? AppColors.richGold : AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                final msg = 'Hello Colors Forever, I am inquiring about Fine Jewelry Item: ${item.item} '
                                    '(${item.displayTitle}, Gold: ${item.goldKarat} ${item.goldColor}).';
                                WhatsAppHelper.launchWhatsApp(context, msg);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 14,
                                  color: AppColors.whatsapp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

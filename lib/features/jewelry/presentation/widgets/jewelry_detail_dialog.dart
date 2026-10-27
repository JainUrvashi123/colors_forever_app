import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diamonds/presentation/providers/diamond_catalog_provider.dart';
import '../../../diamonds/presentation/widgets/cart_request_dialog.dart';
import 'package:provider/provider.dart';
import '../../data/models/jewelry_item_model.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../views/jewelry_detail_screen.dart';

class JewelryDetailDialog extends StatelessWidget {
  final JewelryItem item;

  const JewelryDetailDialog({super.key, required this.item});

  static void show(BuildContext context, JewelryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JewelryDetailScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image Banner with Close Button
              Stack(
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    color: const Color(0xFFFAFAFA),
                    child: item.imageShow != null && item.imageShow!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageShow!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.diamond_outlined, size: 48, color: AppColors.champagneGold),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.diamond_outlined, size: 48, color: AppColors.champagneGold),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(200),
                      ),
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (item.imageShow2 != null && item.imageShow2!.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.midnightOnyx.withAlpha(200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Model Photo Available',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Title & Stock ID
                    Text(
                      item.displayTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Item Code: ${item.item} ${item.subItem.isNotEmpty ? "• Size: ${item.subItem}" : ""}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Tag
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final hidden = PriceHelper.isPriceHidden(auth, category: 'jewelry');
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warmGoldTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hidden || item.parsedPrice <= 0
                                    ? 'Price Upon Request'
                                    : Formatters.formatCurrency(item.parsedPrice),
                                style: AppTheme.priceStyle(
                                  fontSize: hidden ? 14 : 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.richGold,
                                ),
                              ),
                              if (!hidden && item.parsedPrice > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Retail Est.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Specifications Grid Table
                    Text(
                      'Jewelry Specifications',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSpecTable(item),
                    const SizedBox(height: 20),

                    // Video button if available
                    if (Formatters.isValidUrl(item.videoShow)) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.richGold),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.play_circle_fill, color: AppColors.richGold),
                          label: Text(
                            'Watch High-Res 360° Video',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: AppColors.richGold,
                            ),
                          ),
                          onPressed: () async {
                            var url = item.videoShow!.trim();
                            if (!url.startsWith('http://') && !url.startsWith('https://')) {
                              url = 'https://$url';
                            }
                            final uri = Uri.tryParse(url);
                            if (uri != null) {
                              try {
                                final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                if (!launched) {
                                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                                }
                              } catch (e) {
                                try {
                                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                                } catch (_) {}
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Actions: Add to Cart, Email / Memo, WhatsApp Inquiry
                    Consumer<DiamondCatalogProvider>(
                      builder: (context, catalogProvider, _) {
                        final itemId = item.item.isNotEmpty ? item.item : item.stockId;
                        final inCart = catalogProvider.isInCart(itemId);
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: inCart ? AppColors.richGold : AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    label: Text(
                                      inCart ? 'In Cart' : 'Add to Cart',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
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
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.richGold, width: 1.5),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.email_outlined, color: AppColors.richGold, size: 16),
                                    label: Text(
                                      'Email / Memo',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.richGold,
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => const CartRequestDialog(initialCart: 'Jewelry Cart'),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8, height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.whatsapp,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                                label: Text(
                                  'Inquire on WhatsApp',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  final msg = 'Hello Colors Forever, I am interested in Jewelry Item: ${item.item} '
                                      '(${item.displayTitle}, Gold: ${item.goldKarat} ${item.goldColor}, Diamond: ${item.diamondColor}). '
                                      'Please provide further details.';
                                  WhatsAppHelper.launchWhatsApp(context, msg);
                                },
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildSpecTable(JewelryItem item) {
    final specs = <MapEntry<String, String>>[];
    if (item.department.isNotEmpty) specs.add(MapEntry('Department', item.department));
    if (item.sec1.isNotEmpty) specs.add(MapEntry('Sub Category', item.sec1));
    if (item.goldKarat.isNotEmpty) specs.add(MapEntry('Gold Karat', item.goldKarat));
    if (item.goldColor.isNotEmpty) specs.add(MapEntry('Gold Color', item.goldColor.toLowerCase().contains('gold') ? item.goldColor : '${item.goldColor} Gold'));
    if (item.goldWeight.isNotEmpty) specs.add(MapEntry('Gold Weight', '${item.goldWeight} g'));
    if (item.diamondColor.isNotEmpty) specs.add(MapEntry('Diamond Color', item.diamondColor));
    if (item.diamondClarity.isNotEmpty) specs.add(MapEntry('Diamond Clarity', item.diamondClarity));
    if (item.parsedCarat > 0) {
      specs.add(MapEntry('Total Diamond Wt.', Formatters.formatCarat(item.parsedCarat)));
    } else if (item.totalDiamondWeight.isNotEmpty && item.totalDiamondWeight != '0') {
      specs.add(MapEntry('Total Diamond Wt.', '${item.totalDiamondWeight} Carat'));
    }
    if (item.sec4A.isNotEmpty) specs.add(MapEntry('Style Setting', item.sec4A));
    if (item.subItem.isNotEmpty) specs.add(MapEntry('Size / Fit', item.subItem));

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(specs.length, (i) {
          final entry = specs[i];
          final isLast = i == specs.length - 1;
          final isEven = i % 2 == 0;
          return Container(
            decoration: BoxDecoration(
              color: isEven ? Colors.white : const Color(0xFFF8FAFC),
              border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1.0)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

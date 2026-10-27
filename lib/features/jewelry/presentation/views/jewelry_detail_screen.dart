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
import '../../../../core/widgets/app_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diamonds/presentation/providers/diamond_catalog_provider.dart';
import '../../../diamonds/presentation/widgets/cart_request_dialog.dart';
import 'package:provider/provider.dart';
import '../../data/models/jewelry_item_model.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../../auth/presentation/views/login_screen.dart';

class JewelryDetailScreen extends StatefulWidget {
  final JewelryItem item;

  const JewelryDetailScreen({super.key, required this.item});

  @override
  State<JewelryDetailScreen> createState() => _JewelryDetailScreenState();
}

class _JewelryDetailScreenState extends State<JewelryDetailScreen> {
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  List<String> _getImages() {
    final list = <String>[];
    if (widget.item.imageShow != null && widget.item.imageShow!.isNotEmpty) {
      list.add(widget.item.imageShow!);
    }
    if (widget.item.imageShow2 != null && widget.item.imageShow2!.isNotEmpty) {
      list.add(widget.item.imageShow2!);
    }
    return list;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchVideo(BuildContext context, String rawUrl) async {
    var url = rawUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
          if (!fallback && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open 360° video link.'),
                backgroundColor: AppColors.midnightOnyx,
              ),
            );
          }
        }
      } catch (e) {
        if (!context.mounted) return;
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to launch video player.'),
              backgroundColor: AppColors.midnightOnyx,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final images = _getImages();
    final hasVideo = Formatters.isValidUrl(item.videoShow);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            item.displayTitle,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 22),
              tooltip: 'Inquire on WhatsApp',
              onPressed: () {
                final msg = 'Hello Colors Forever, I am interested in Fine Jewelry Item: ${item.item} '
                    '(${item.displayTitle}, Gold: ${item.goldKarat} ${item.goldColor}, Diamond: ${item.diamondColor}). '
                    'Please provide further details.';
                WhatsAppHelper.launchWhatsApp(context, msg);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Viewer Carousel / Header Container
              Container(
                height: 320,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.95,
                    colors: [
                      Colors.white,
                      AppColors.velvetPedestal,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    images.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (idx) {
                              setState(() => _selectedImageIndex = idx);
                            },
                            itemBuilder: (context, index) {
                              final imgUrl = images[index];
                              return Center(
                                child: InteractiveViewer(
                                  maxScale: 4.0,
                                  child: CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (_, _) => const Center(
                                      child: CircularProgressIndicator(color: AppColors.champagneGold),
                                    ),
                                    errorWidget: (_, _, _) => const Center(
                                      child: Icon(Icons.diamond_outlined, size: 64, color: AppColors.champagneGold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.diamond_outlined, size: 64, color: AppColors.champagneGold),
                          ),

                    // Page Indicator Badge
                    if (images.length > 1)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.midnightOnyx.withAlpha(200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_selectedImageIndex + 1} / ${images.length}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Pinch to zoom hint
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.midnightOnyx.withAlpha(180),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Pinch to Zoom',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Thumbnail Selector Row for multi-image switching
                    if (images.length > 1)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(images.length, (idx) {
                            final isSelected = _selectedImageIndex == idx;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  idx,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.richGold : AppColors.border,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: images[idx],
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => const Icon(Icons.diamond_outlined, size: 16),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // 2. Main Details & Pricing Container
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Item Code Row
                    Text(
                      item.displayTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Item Code: ${item.item}${item.subItem.isNotEmpty ? " • Size: ${item.subItem}" : ""}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Attribute Badges Row (Gold Karat, Metal Color, Diamond Color)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (item.goldKarat.isNotEmpty)
                          _buildBadge(item.goldKarat, AppColors.midnightOnyx, Colors.white),
                        if (item.goldColor.isNotEmpty)
                          _buildBadge('${item.goldColor} Gold', const Color(0xFFF1F5F9), AppColors.textPrimary),
                        if (item.diamondColor.isNotEmpty)
                          _buildBadge(item.diamondColor, AppColors.warmGoldTint, AppColors.richGold, isGoldBorder: true),
                        if (item.sec1.isNotEmpty)
                          _buildBadge(item.sec1, const Color(0xFFF3F7FC), AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pricing Card
                    if (item.parsedPrice > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.warmGoldTint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                if (!auth.isAuthenticated) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmGoldTint,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.champagneGold, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.lock_rounded, size: 14, color: AppColors.richGold),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Login to View Price',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.midnightOnyx,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.richGold),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                final hidden = PriceHelper.isPriceHidden(auth, category: 'jewelry');
                                if (hidden || item.parsedPrice <= 0) {
                                  return Text(
                                    'Price Upon Request',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.richGold,
                                    ),
                                  );
                                }
                                return Text(
                                  Formatters.formatCurrency(item.parsedPrice),
                                  style: AppTheme.priceStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.richGold,
                                    letterSpacing: -0.3,
                                  ),
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.champagneGold.withAlpha(120)),
                              ),
                              child: Text(
                                'RETAIL EST.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.richGold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.warmGoldTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.champagneGold.withAlpha(150)),
                        ),
                        child: Text(
                          'Price Available Upon Request',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.richGold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // 3. 360° Video Action Card (if available)
                    if (hasVideo) ...[
                      InkWell(
                        onTap: () => _launchVideo(context, item.videoShow!),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.richGold, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.warmGoldTint,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_circle_fill, color: AppColors.richGold, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Watch High-Res 360° Video',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Interactive HD rotation view',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.richGold),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 4. Jewelry Dossier & Specifications Card
                    Text(
                      'Jewelry Dossier & Specifications',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSpecTable(item),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Consumer<DiamondCatalogProvider>(
          builder: (context, catalogProvider, _) {
            final itemId = item.item.isNotEmpty ? item.item : item.stockId;
            final inCart = catalogProvider.isInCart(itemId);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Add to Cart Button (Primary Action)
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: inCart ? AppColors.richGold : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          inCart ? 'In Cart' : 'Add to Cart',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
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
                    // Email / Request Memo Button
                    Expanded(
                      flex: 5,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.richGold, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.email_outlined, color: AppColors.richGold, size: 18),
                        label: Text(
                          'Email / Memo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
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
                    const SizedBox(width: 8),
                    // WhatsApp Concierge Button
                    InkWell(
                      onTap: () {
                        final msg = 'Hello Colors Forever, I am interested in Fine Jewelry Item: ${item.item} '
                            '(${item.displayTitle}, Gold: ${item.goldKarat} ${item.goldColor}, Diamond: ${item.diamondColor}). '
                            'Please provide further details.';
                        WhatsAppHelper.launchWhatsApp(context, msg);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.whatsapp,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color textColor, {bool isGoldBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isGoldBorder ? Border.all(color: AppColors.champagneGold.withAlpha(150)) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
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
      specs.add(MapEntry('Total Diamond Weight', Formatters.formatCarat(item.parsedCarat)));
    } else if (item.totalDiamondWeight.isNotEmpty && item.totalDiamondWeight != '0') {
      specs.add(MapEntry('Total Diamond Weight', '${item.totalDiamondWeight} Carat'));
    }
    if (item.sec4A.isNotEmpty) specs.add(MapEntry('Style Setting', item.sec4A));
    if (item.subItem.isNotEmpty) specs.add(MapEntry('Size / Fit', item.subItem));

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(specs.length, (i) {
          final entry = specs[i];
          final isLast = i == specs.length - 1;
          final isEven = i % 2 == 0;
          return Container(
            decoration: BoxDecoration(
              color: isEven ? const Color(0xFFF8FAFC) : Colors.white,
              border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1.0)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
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

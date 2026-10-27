import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/widgets/diamond_shape_icon.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../domain/entities/diamond.dart';
import '../providers/diamond_catalog_provider.dart';
import '../widgets/email_diamond_dialog.dart';
import '../widgets/whatsapp_share_dialog.dart';
import '../widgets/diamond_grid_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';


class DiamondDetailScreen extends StatefulWidget {
  final Diamond diamond;

  const DiamondDetailScreen({super.key, required this.diamond});

  @override
  State<DiamondDetailScreen> createState() => _DiamondDetailScreenState();
}

class _DiamondDetailScreenState extends State<DiamondDetailScreen> {
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final vdGroupId = authProvider.userProfile?.details?.groupId;
      context.read<DiamondCatalogProvider>().fetchDiamondDetails(
        widget.diamond.serialNo,
        vdGroupId: vdGroupId,
      );
    });
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
    return Consumer<DiamondCatalogProvider>(
      builder: (context, catalogProvider, _) {
        final details = catalogProvider.currentDetails;
        final currentDiamond = details?.diamond ?? widget.diamond;
        final images = currentDiamond.imageArray.isNotEmpty
            ? currentDiamond.imageArray
            : (currentDiamond.imageUrl.isNotEmpty ? [currentDiamond.imageUrl] : <String>[]);
        final videos = currentDiamond.videoArray.isNotEmpty
            ? currentDiamond.videoArray
            : (currentDiamond.videoUrl.isNotEmpty ? [currentDiamond.videoUrl] : <String>[]);
        final rawCerts = currentDiamond.certificateArray.isNotEmpty
            ? currentDiamond.certificateArray
            : (currentDiamond.certUrl.isNotEmpty ? [currentDiamond.certUrl] : <String>[]);
        final certs = rawCerts.where((c) => Formatters.isValidUrl(c)).toList();
        final similarDiamonds = details?.similarDiamonds ?? currentDiamond.similarDiamonds;

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                '${currentDiamond.shape} • ${Formatters.formatCarat(currentDiamond.weight)}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                /*
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.roseGold : AppColors.textPrimary,
                  ),
                  onPressed: () => catalogProvider.toggleFavorite(currentDiamond.serialNo),
                ),
                */
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 24),
                  tooltip: 'Share via WhatsApp',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => WhatsAppShareDialog(diamonds: [currentDiamond]),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Multi-Image Carousel Container with Pedestal Lighting
                  Container(
                    height: 340,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
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
                                        errorWidget: (_, _, _) => Image.asset(
                                          AppAssets.getDiamondImageForShade(currentDiamond.color) ??
                                              AppAssets.noImageDiamond,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: InteractiveViewer(
                                  maxScale: 4.0,
                                  child: Image.asset(
                                    AppAssets.getDiamondImageForShade(currentDiamond.color) ??
                                        AppAssets.noImageDiamond,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                        // Image Pagination Indicator (if multi-image)
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
                              color: AppColors.midnightOnyx.withAlpha(200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
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

                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // 2. Pricing & Main Info
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                final priceInfo = PriceHelper.getDiamondPrice(
                                  currentDiamond,
                                  auth,
                                  compact: false,
                                );

                                if (priceInfo.loginRequired || !auth.isAuthenticated) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmGoldTint,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.champagneGold, width: 1.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.champagneGold.withAlpha(50),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.champagneGold,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.lock_rounded, size: 14, color: Colors.black),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Login to View Price',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.midnightOnyx,
                                                ),
                                              ),
                                              Text(
                                                'Tap to unlock wholesale B2B pricing',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.richGold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.richGold),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (priceInfo.isHidden) {
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => WhatsAppShareDialog(diamonds: [currentDiamond]),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Price Upon Request',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          priceInfo.formattedTotal,
                                          style: AppTheme.priceStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: priceInfo.isWholesale ? AppColors.richGold : AppColors.midnightOnyx,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        if (priceInfo.isWholesale) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.warmGoldTint,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.champagneGold.withAlpha(120)),
                                            ),
                                            child: Text(
                                              'WHOLESALE',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.richGold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${priceInfo.formattedPerCt} / Ct',
                                      style: AppTheme.priceStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (currentDiamond.location.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warmGoldTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.champagneGold.withAlpha(120)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: AppColors.textGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      currentDiamond.location,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textGold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Item Badge Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              DiamondShapeIcon(shape: currentDiamond.shape, size: 28, color: AppColors.primary),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${Formatters.formatCarat(currentDiamond.weight)} ${currentDiamond.shape}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      'Item #${currentDiamond.serialNo}',
                                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 360° Video Action Card (if available)
                        if (videos.isNotEmpty) ...[
                          InkWell(
                            onTap: () => _launchVideo(context, videos.first),
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

                        // // 3. Complete Specifications Dossier
                        // Text(
                        //   'Gemological Dossier',
                        //   style: GoogleFonts.plusJakartaSans(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w700,
                        //     color: AppColors.textPrimary,
                        //     letterSpacing: 0.2,
                        //   ),
                        // ),
                        // const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildSpecRow('Shape', currentDiamond.shape),
                                _buildSpecRow('Carat Weight', Formatters.formatCarat(currentDiamond.weight)),
                                _buildSpecRow('Color', currentDiamond.color),
                                if (currentDiamond.labColor.isNotEmpty)
                                  _buildSpecRow('Lab Color Description', currentDiamond.labColor),
                                _buildSpecRow('Clarity Grade', currentDiamond.grade),
                                _buildSpecRow('Cut', Formatters.cleanString(currentDiamond.cut)),
                                _buildSpecRow('Polish', Formatters.cleanString(currentDiamond.polish)),
                                _buildSpecRow('Symmetry', Formatters.cleanString(currentDiamond.symmetry)),
                                _buildSpecRow('Fluorescence', Formatters.cleanString(currentDiamond.fluorescence)),
                                _buildSpecRow('Depth %', '${currentDiamond.depth.toStringAsFixed(1)}%'),
                                _buildSpecRow('Table %', '${currentDiamond.table.toStringAsFixed(1)}%'),
                                _buildSpecRow('Measurements', Formatters.cleanString(currentDiamond.measurements)),
                                _buildSpecRow('Lab Certification', '${currentDiamond.lab} #${currentDiamond.certNumber}'),
                                _buildSpecRow('Vault Location', currentDiamond.location),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Certificate Download Buttons
                        if (certs.isNotEmpty) ...[
                          for (final certPath in certs)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.champagneGold, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf, color: AppColors.textGold),
                                  label: Text(
                                    'View Official ${currentDiamond.lab.isNotEmpty ? currentDiamond.lab : "Lab"} Certificate Report',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textGold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final uri = Uri.tryParse(certPath.trim());
                                    if (uri != null) {
                                      try {
                                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        if (!launched) {
                                          await launchUrl(uri, mode: LaunchMode.platformDefault);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Unable to open certificate report URL.'),
                                              backgroundColor: AppColors.midnightOnyx,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                        ],

                        // 5. Similar Diamonds Carousel
                        if (similarDiamonds.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Text(
                            'Similar Solitaire Diamonds',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 245,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarDiamonds.length,
                              itemBuilder: (context, index) {
                                final sim = similarDiamonds[index];
                                return Container(
                                  width: 175,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: DiamondGridCard(
                                    diamond: sim,
                                    isFavorite: catalogProvider.isFavorite(sim.serialNo),
                                    onToggleFavorite: () => catalogProvider.toggleFavorite(sim.serialNo),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  // Add to Cart Button (Primary Action)
                  Expanded(
                    flex: 4,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catalogProvider.isInCart(currentDiamond.serialNo)
                            ? AppColors.richGold
                            : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        catalogProvider.isInCart(currentDiamond.serialNo)
                            ? Icons.shopping_bag
                            : Icons.add_shopping_cart,
                        size: 18,
                      ),
                      label: Text(
                        catalogProvider.isInCart(currentDiamond.serialNo)
                            ? 'In Cart'
                            : 'Add to Cart',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        if (!auth.isAuthenticated) {
                          GuestGuard.requireLogin(
                            context,
                            actionLabel: 'add this diamond to your cart',
                          );
                          return;
                        }
                        final res = await catalogProvider.addToCart([currentDiamond.serialNo]);
                        if (context.mounted) {
                          final msg = res['message']?.toString() ?? 'Cart updated successfully!';
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
                  // WhatsApp Inquiry Button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => WhatsAppShareDialog(diamonds: [currentDiamond]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Email Diamond Button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 20, color: AppColors.primary),
                    tooltip: 'Email Diamond',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EmailDiamondDialog(diamond: currentDiamond),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

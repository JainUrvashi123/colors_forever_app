import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../domain/entities/diamond.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../providers/diamond_catalog_provider.dart';
import '../views/diamond_detail_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'whatsapp_share_dialog.dart';


class DiamondListCard extends StatelessWidget {
  final Diamond diamond;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool isSelected;
  final ValueChanged<bool?>? onToggleSelect;

  const DiamondListCard({
    super.key,
    required this.diamond,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.isSelected = false,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E6FBA) : AppColors.border.withAlpha(140),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiamondDetailScreen(diamond: diamond),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Left: Diamond Image Box (Expanded 92x92 with Checkbox Overlay)
              Stack(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withAlpha(140)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6),
                    child: diamond.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: diamond.imageUrl,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagneGold),
                              ),
                            ),
                            errorWidget: (_, _, _) => Image.asset(
                              AppAssets.getDiamondImageForShade(diamond.color) ??
                                  AppAssets.noImageDiamond,
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            AppAssets.getDiamondImageForShade(diamond.color) ??
                                AppAssets.noImageDiamond,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                  ),

                  // Overlay Checkbox on Top-Left Corner of Image
                  if (onToggleSelect != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: onToggleSelect,
                          activeColor: const Color(0xFF1E6FBA),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // 2. Right: Clean 3-Row Spacious Information Layout
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final priceInfo = PriceHelper.getDiamondPrice(diamond, auth);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ROW 1: Carat & Shape (Left) | Total Price (Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                '${Formatters.formatCarat(diamond.weight)} ${diamond.shape}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (priceInfo.loginRequired || !auth.isAuthenticated) ...[
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.warmGoldTint,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.champagneGold.withAlpha(140), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_outline_rounded, size: 11, color: AppColors.richGold),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Login to View Price',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            color: AppColors.richGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (priceInfo.isHidden) ...[
                              Text(
                                'Price Upon Request',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ] else ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (priceInfo.isWholesale) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmGoldTint,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'WS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.richGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Text(
                                    priceInfo.formattedTotal,
                                    style: AppTheme.priceStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: priceInfo.isWholesale ? AppColors.richGold : AppColors.midnightOnyx,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 7),

                        // ROW 2: Color, Clarity & Lab Separate Boxes (Left) | Price per Ct (Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Box 1: Color
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        diamond.labColor.isNotEmpty ? diamond.labColor : diamond.color,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    if (diamond.grade.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      // Box 2: Clarity
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          diamond.grade,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (diamond.lab.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      // Box 3: Lab Certificate
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          diamond.lab,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!priceInfo.isHidden) ...[
                              Text(
                                '${priceInfo.formattedPerCt}/Ct',
                                style: AppTheme.priceStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 9),

                        // ROW 3: Serial No / Measurements (Left) | Action Buttons (Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                diamond.serialNo.isNotEmpty
                                    ? '#${diamond.serialNo}${diamond.measurements.isNotEmpty ? " • ${diamond.measurements}" : ""}'
                                    : diamond.measurements,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Consumer<DiamondCatalogProvider>(
                                  builder: (context, catalogProvider, _) {
                                    final inCart = catalogProvider.isInCart(diamond.serialNo);
                                    return InkWell(
                                      onTap: () async {
                                        final auth = context.read<AuthProvider>();
                                        if (!auth.isAuthenticated) {
                                          GuestGuard.requireLogin(
                                            context,
                                            actionLabel: 'add diamonds to your cart',
                                          );
                                          return;
                                        }
                                        final res = await catalogProvider.addToCart([diamond.serialNo]);
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
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: inCart ? AppColors.warmGoldTint : const Color(0xFFF1F5F9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                                          size: 16,
                                          color: inCart ? AppColors.richGold : AppColors.primary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => WhatsAppShareDialog(diamonds: [diamond]),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      size: 15,
                                      color: AppColors.whatsapp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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



class DiamondGridCard extends StatelessWidget {
  final Diamond diamond;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool isSelected;
  final ValueChanged<bool?>? onToggleSelect;

  const DiamondGridCard({
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E6FBA) : AppColors.border.withAlpha(150),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DiamondDetailScreen(diamond: diamond),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diamond Pedestal Display Container (Responsive height)
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Inner Grey Image Box (Centered like Featured Solitaires)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
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
                                    width: 22,
                                    height: 22,
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
                    ),

                    // Selection Checkbox Overlay
                    if (onToggleSelect != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: onToggleSelect,
                            activeColor: const Color(0xFF1E6FBA),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),

                    // Floating Wishlist Heart (Top Right White Background) - Commented Out
                    /*
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: onToggleFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.roseGold : AppColors.textMuted,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              ),

            const Divider(height: 1, color: AppColors.borderLight),

            // Card Body Info (Responsive flex)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & Attribute Boxes Group (Fixed spacing between Carat Weight and Attribute Boxes)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${Formatters.formatCarat(diamond.weight)} ${diamond.shape}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),

                        // 3 Separate Attribute Boxes with Uniform Styling: [ CANARY YELLOW ]  [ VS2 ]  [ IGI ]
                        FittedBox(
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
                                    fontSize: 9.5,
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
                                      fontSize: 9.5,
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
                                      fontSize: 9.5,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Pricing (Cormorant Garamond font) & WhatsApp
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final priceInfo = PriceHelper.getDiamondPrice(diamond, auth);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (priceInfo.loginRequired || !auth.isAuthenticated) ...[
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.warmGoldTint,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.champagneGold.withAlpha(140), width: 0.8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.lock_outline_rounded, size: 10.5, color: AppColors.richGold),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Login for Price',
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
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            priceInfo.formattedTotal,
                                            style: AppTheme.priceStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15.5,
                                              color: priceInfo.isWholesale
                                                  ? AppColors.richGold
                                                  : AppColors.midnightOnyx,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          if (priceInfo.isWholesale) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 1.5),
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
                                        ],
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${priceInfo.formattedPerCt}/Ct',
                                        style: AppTheme.priceStyle(
                                          fontSize: 10.5,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Add to Cart (Increased Size & Removed WhatsApp from Container)
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
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: inCart ? AppColors.warmGoldTint : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                                      size: 20,
                                      color: inCart ? AppColors.richGold : AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/diamond.dart';
import '../views/diamond_detail_screen.dart';
import '../../../auth/presentation/views/login_screen.dart';

class HauteDiamondCard extends StatelessWidget {
  final Diamond diamond;
  final VoidCallback? onTap;

  const HauteDiamondCard({
    super.key,
    required this.diamond,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardDarkNavyStart,
            AppColors.cardDarkNavyEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(45),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.champagneGold.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DiamondDetailScreen(diamond: diamond),
                  ),
                );
              },
          child: Stack(
            children: [
              // Subtle background spotlight ray on right side
              Positioned(
                right: -20,
                top: -30,
                bottom: -30,
                width: 220,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.2, 0.0),
                      radius: 0.8,
                      colors: [
                        AppColors.primaryLight.withAlpha(50),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Left Column: Titles, Specs & Price
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Diamond Title in clean Plus Jakarta Sans
                          Text(
                            diamond.labColor.isNotEmpty
                                ? diamond.labColor
                                : '${diamond.color} ${diamond.shape} Diamond',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Specs: e.g. "0.52 ct, Cushion Cut, VVS2"
                          Text(
                            '${Formatters.formatCarat(diamond.weight)}, ${diamond.shape} Cut, ${diamond.grade}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Price in clean tabular Plus Jakarta Sans
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              final priceInfo = PriceHelper.getDiamondPrice(diamond, auth, compact: false);
                              if (priceInfo.loginRequired || !auth.isAuthenticated) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.champagneGold.withAlpha(35),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.champagneGold.withAlpha(140), width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.champagneGold),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Login to View Price',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.champagneGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Text(
                                priceInfo.isHidden ? 'Price Upon Request' : priceInfo.formattedTotal,
                                style: AppTheme.priceStyle(
                                  fontSize: priceInfo.isHidden ? 14 : 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textLightGold,
                                  letterSpacing: -0.2,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Right Column: Diamond on Velvet Box Pedestal
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: _buildVelvetPedestal(diamond),
                      ),
                    ),
                  ],
                ),
              ),

              // GIA / IGI Gold Stamp Emblem in Top Right
              Positioned(
                top: 10,
                right: 12,
                child: _buildGoldSealBadge(diamond.lab.isNotEmpty ? diamond.lab : 'GIA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVelvetPedestal(Diamond diamond) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Velvet Jewelry Box Base (Navy with Gold Trim)
          Positioned(
            bottom: 4,
            child: Container(
              width: 95,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E3354),
                    Color(0xFF0F1D33),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.champagneGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppColors.champagneGold.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14243B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // Glowing spotlight beneath the stone
          Positioned(
            bottom: 24,
            child: Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withAlpha(160),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // The High-Resolution Diamond Gemstone
          Positioned(
            top: 2,
            child: SizedBox(
              width: 72,
              height: 72,
              child: diamond.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: diamond.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.champagneGold,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Image.asset(
                        AppAssets.getDiamondImageForShade(diamond.color) ??
                            AppAssets.noImageDiamond,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      AppAssets.getDiamondImageForShade(diamond.color) ??
                          AppAssets.noImageDiamond,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSealBadge(String lab) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9EE),
            Color(0xFFE8D4A8),
          ],
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.champagneGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 11, color: Color(0xFF996515)),
          const SizedBox(width: 3),
          Text(
            lab,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7A4E0B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

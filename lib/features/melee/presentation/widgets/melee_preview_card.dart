import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/melee_model.dart';
import '../providers/melee_provider.dart';

class MeleePreviewCard extends StatelessWidget {
  final MeleeProvider provider;

  const MeleePreviewCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = provider.currentPreviewImageUrl;
    final isSolitaire = provider.viewMode == MeleeViewMode.solitaire;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder.withAlpha(120), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Showcase Image Area
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: Builder(
                    builder: (context) {
                      final diamondAsset = AppAssets.getDiamondImageForShade(
                        provider.selectedShade ?? provider.selectedColor,
                      );

                      if (isSolitaire && diamondAsset != null) {
                        return Container(
                          color: const Color(0xFFFAFAFA),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Image.asset(
                              diamondAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }

                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF8F9FA),
                          child: Center(
                            child: diamondAsset != null
                                ? Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Image.asset(
                                      diamondAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.champagneGold,
                                    ),
                                  ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFF8F9FA),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Image.asset(
                              isSolitaire
                                  ? (diamondAsset ?? AppAssets.solitaireDiamonds)
                                  : AppAssets.meleeDiamonds,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading overlay
              if (provider.isLoadingPreview)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(140),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.champagneGold,
                        ),
                      ),
                    ),
                  ),
                ),

              // Active Shade Label Tag (Top-Right)
              if (provider.selectedShade != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.midnightOnyx.withAlpha(210),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.champagneGold.withAlpha(180)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond_outlined, color: AppColors.champagneGold, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          provider.selectedShade!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Bottom Bar inside card: Melee vs Solitaire toggle (matches website & screenshots)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9F5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
              border: Border(
                top: BorderSide(color: AppColors.border.withAlpha(80)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.selectedShade != null
                            ? provider.selectedShade!
                            : (provider.selectedColor != null
                                ? '${provider.selectedColor} Diamond Parcel'
                                : 'Fancy Color Melee Collection'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        provider.selectedSize != null
                            ? 'Calibrated Size: ${provider.selectedSize} • ${provider.selectedGrade ?? "VVS-VS"}'
                            : 'Select color & sieve size below',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Melee | Solitaire Pill Switcher
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModePill(
                        label: 'Melee',
                        isSelected: !isSolitaire,
                        onTap: () => provider.setViewMode(MeleeViewMode.melee),
                      ),
                      const SizedBox(width: 2),
                      _buildModePill(
                        label: 'Solitaire',
                        isSelected: isSolitaire,
                        onTap: () => provider.setViewMode(MeleeViewMode.solitaire),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

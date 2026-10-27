import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/widgets/diamond_shape_icon.dart';
import '../../domain/entities/diamond.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';
import 'package:provider/provider.dart';
import 'email_diamond_dialog.dart';
import 'whatsapp_share_dialog.dart';

class QuickViewDialog extends StatelessWidget {
  final Diamond diamond;

  const QuickViewDialog({super.key, required this.diamond});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${diamond.shape} • ${Formatters.formatCarat(diamond.weight)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diamond Image
                    Center(
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: diamond.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: diamond.imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (_, _) => const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
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
                    ),
                    const SizedBox(height: 16),

                    // Price & Serial
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final priceInfo = PriceHelper.getDiamondPrice(diamond, auth, compact: false);
                            if (priceInfo.loginRequired || !auth.isAuthenticated) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmGoldTint,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.champagneGold, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.richGold),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Login to View Price',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.richGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (priceInfo.isHidden) {
                              return Text(
                                'Price Upon Request',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  priceInfo.formattedTotal,
                                  style: AppTheme.priceStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: priceInfo.isWholesale
                                        ? AppColors.richGold
                                        : AppColors.midnightOnyx,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  '${priceInfo.formattedPerCt} / Ct',
                                  style: AppTheme.priceStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Item: ${diamond.serialNo}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Specs Table
                    const Text(
                      'Diamond Specifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildSpecRow('Shape', diamond.shape, icon: DiamondShapeIcon(shape: diamond.shape, size: 16)),
                    _buildSpecRow('Carat Weight', Formatters.formatCarat(diamond.weight)),
                    _buildSpecRow('Color', diamond.color),
                    if (diamond.labColor.isNotEmpty)
                      _buildSpecRow('Lab Color Description', diamond.labColor),
                    _buildSpecRow('Clarity Grade', diamond.grade),
                    _buildSpecRow('Cut', Formatters.cleanString(diamond.cut)),
                    _buildSpecRow('Polish', Formatters.cleanString(diamond.polish)),
                    _buildSpecRow('Symmetry', Formatters.cleanString(diamond.symmetry)),
                    _buildSpecRow('Fluorescence', Formatters.cleanString(diamond.fluorescence)),
                    _buildSpecRow('Depth %', '${diamond.depth.toStringAsFixed(1)}%'),
                    _buildSpecRow('Table %', '${diamond.table.toStringAsFixed(1)}%'),
                    _buildSpecRow('Measurements', Formatters.cleanString(diamond.measurements)),
                    _buildSpecRow('Lab Certification', '${diamond.lab} ${diamond.certNumber}'),
                    _buildSpecRow('Stock Location', diamond.location),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Certificate Link
                  if (Formatters.isValidUrl(diamond.certUrl))
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Cert PDF', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final uri = Uri.tryParse(diamond.certUrl.trim());
                          if (uri != null) {
                            try {
                              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                              if (!launched) {
                                await launchUrl(uri, mode: LaunchMode.platformDefault);
                              }
                            } catch (_) {}
                          }
                        },
                      ),
                    ),
                  if (Formatters.isValidUrl(diamond.certUrl)) const SizedBox(width: 8),

                  // WhatsApp
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                    tooltip: 'Inquire on WhatsApp',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => WhatsAppShareDialog(diamonds: [diamond]),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Email
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.email, size: 18),
                    tooltip: 'Email Diamond',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EmailDiamondDialog(diamond: diamond),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 6)],
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

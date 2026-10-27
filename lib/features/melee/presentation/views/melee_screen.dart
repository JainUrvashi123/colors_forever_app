import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/melee_model.dart';
import '../providers/melee_provider.dart';
import '../widgets/birthstone_month_selector.dart';
import '../widgets/melee_calculator_section.dart';
import '../widgets/melee_cart_sheet.dart';
// import '../widgets/melee_preview_card.dart';
import '../widgets/melee_swatch_selector.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MeleeScreen extends StatelessWidget {
  const MeleeScreen({super.key});

  void _launchWhatsApp(BuildContext context, String message) async {
    await WhatsAppHelper.launchWhatsApp(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeleeProvider>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Melee Diamonds',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Melee Cart Icon with Badge
          Builder(
            builder: (context) {
              final auth = context.watch<AuthProvider>();
              final showBadge = auth.isAuthenticated && provider.cartCount > 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 26),
                    tooltip: showBadge ? 'Melee Cart (${provider.cartCount})' : 'Melee Cart',
                    onPressed: () {
                      if (!auth.isAuthenticated) {
                        GuestGuard.requireLogin(
                          context,
                          actionLabel: 'view your melee cart',
                        );
                        return;
                      }
                      MeleeCartSheet.show(context, provider);
                    },
                  ),
                  if (showBadge)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.richGold,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '${provider.cartCount}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Direct WhatsApp Concierge
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 26),
            tooltip: 'WhatsApp Concierge',
            onPressed: () => _launchWhatsApp(
              context,
              'Hello Colors Forever, I am inquiring about Melee Diamond calibrated parcels.',
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Top Pill Switcher: [ Melee ] | [ Birth Stone ] (Matching media_1788514135422.png)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF1E6FBA), width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x101E6FBA),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStoneTypeTab(
                            title: 'Melee',
                            isSelected: provider.stoneType == MeleeStoneType.melee,
                            onTap: () => provider.setStoneType(MeleeStoneType.melee),
                          ),
                          _buildStoneTypeTab(
                            title: 'Birth Stone',
                            isSelected: provider.stoneType == MeleeStoneType.birthstone,
                            onTap: () => provider.setStoneType(MeleeStoneType.birthstone),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Showcase Preview Card commented out as requested:
                  // if (provider.stoneType == MeleeStoneType.melee) ...[
                  //   MeleePreviewCard(provider: provider),
                  //   const SizedBox(height: 10),
                  // ],

                  // Color Swatches (if Melee mode) or Birth Month Selector (if Birth Stone mode)
                  if (provider.stoneType == MeleeStoneType.melee)
                    MeleeSwatchSelector(provider: provider)
                  else
                    BirthstoneMonthSelector(provider: provider),

                  const SizedBox(height: 8),

                  // Calculator Section: Shades, Size picker, Clarity, Quantity, Estimates, Comment
                  MeleeCalculatorSection(provider: provider),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildStoneTypeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF70A9DA) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}

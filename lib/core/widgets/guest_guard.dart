import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/views/login_screen.dart';

/// A reusable utility that gates actions requiring authentication.
///
/// Call [GuestGuard.requireLogin] anywhere a logged-in session is needed.
/// It shows a premium brand-styled bottom sheet with a "Sign In" CTA and
/// an option to dismiss and continue browsing as a guest.
class GuestGuard {
  GuestGuard._();

  /// Shows the sign-in prompt bottom sheet.
  ///
  /// Returns `true` if the user tapped "Sign In" (navigated to LoginScreen),
  /// `false` if they dismissed (continued as guest).
  static Future<bool> requireLogin(
    BuildContext context, {
    String? actionLabel,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GuestGuardSheet(actionLabel: actionLabel),
    );
    return result == true;
  }
}

class _GuestGuardSheet extends StatelessWidget {
  final String? actionLabel;

  const _GuestGuardSheet({this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final label = actionLabel ?? 'this action';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Brand icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.midnightOnyx, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.champagneGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withAlpha(70),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.champagneGold,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Members Only',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Sign in to your wholesale account to $label.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // Benefit chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: const [
                  _BenefitChip(icon: Icons.shopping_bag_outlined, label: 'Add to Cart'),
                  _BenefitChip(icon: Icons.price_check, label: 'Wholesale Pricing'),
                  _BenefitChip(icon: Icons.verified_outlined, label: 'Live Inventory'),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.midnightOnyx,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withAlpha(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 18, color: AppColors.champagneGold),
                        const SizedBox(width: 10),
                        Text(
                          'Sign In to Your Account',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Continue as Guest
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(
                  'Continue Browsing as Guest',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
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

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warmGoldTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.champagneGold.withAlpha(140)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.richGold),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.richGold,
            ),
          ),
        ],
      ),
    );
  }
}

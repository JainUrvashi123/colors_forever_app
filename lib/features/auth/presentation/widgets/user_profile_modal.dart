import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../views/profile_edit_screen.dart';
import 'markup_toggle_dialog.dart';
import 'markup_toggle_switch.dart';
import 'logout_confirmation_dialog.dart';

class UserProfileModal extends StatelessWidget {
  final AuthProvider authProvider;

  const UserProfileModal({
    super.key,
    required this.authProvider,
  });

  static void show(BuildContext context, AuthProvider authProvider) {
    ProfileEditScreen.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Luxury Avatar Circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.midnightOnyx, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.champagneGold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.champagneGold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Full Name
            Text(
              user.fullName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),

            // Company Pill
            if (user.company.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warmGoldTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.champagneGold.withAlpha(120)),
                ),
                child: Text(
                  user.company,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.richGold,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // User Info Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: '#${user.userId}',
                  ),
                  const Divider(height: 18),
                  _buildDetailRow(
                    icon: Icons.corporate_fare_outlined,
                    label: 'Parent ID',
                    value: '#${user.parentId}',
                  ),
                  const Divider(height: 18),
                  _buildDetailRow(
                    icon: Icons.group_work_outlined,
                    label: 'Tier / Group',
                    value: 'Group ${user.group}',
                  ),
                  const Divider(height: 18),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Account Status',
                    value: user.isActive ? 'Active' : 'Inactive',
                    valueColor: user.isActive ? const Color(0xFF1B5E20) : Colors.red,
                  ),
                ],
              ),
            ),
            // Edit Profile Tile
            InkWell(
              onTap: () {
                Navigator.pop(context);
                ProfileEditScreen.show(context);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.champagneGold,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withAlpha(50),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_note, color: AppColors.textPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profile & Markup',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Company info, markups & hide price',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withAlpha(210),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dealer Markup Settings Tile
            InkWell(
              onTap: () {
                MarkupToggleDialog.show(context);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warmGoldTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.champagneGold.withAlpha(140)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune, color: AppColors.richGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dealer Markup Settings',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            authProvider.isMarkupEnabled
                                ? 'Retail Markup Active'
                                : 'Wholesale Direct',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const MarkupToggleSwitch(showTooltip: false),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.richGold, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  LogoutConfirmationDialog.show(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53935), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Color(0xFFE53935), size: 18),
                label: Text(
                  'Log Out',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

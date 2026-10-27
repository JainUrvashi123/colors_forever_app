import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'markup_toggle_dialog.dart';

class MarkupToggleSwitch extends StatelessWidget {
  final double width;
  final double height;
  final bool showTooltip;

  const MarkupToggleSwitch({
    super.key,
    this.width = 54.0,
    this.height = 26.0,
    this.showTooltip = true,
  });

  void _handleTap(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isLoading) return;

    MarkupToggleDialog.show(
      context,
      targetState: !authProvider.isMarkupEnabled,
      initialEmail: authProvider.savedUsername ?? authProvider.currentUser?.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isEnabled = authProvider.isMarkupEnabled;
    final isLoading = authProvider.isLoading;

    final knobSize = height - 4.0;
    const activeColor = Color(0xFF43A047); // Website green
    const inactiveColor = Color(0xFF64748B); // Sleek slate grey

    final switchWidget = GestureDetector(
      onTap: () => _handleTap(context, authProvider),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          color: isEnabled ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.black.withAlpha(25),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: (isEnabled ? activeColor : Colors.black).withAlpha(45),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Text Indicator ("ON" on left when active, "OFF" on right when inactive)
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: isEnabled ? const Alignment(-0.65, 0) : const Alignment(0.65, 0),
              child: Text(
                isEnabled ? 'ON' : 'OFF',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // Sliding White Knob
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: knobSize * 0.55,
                          height: knobSize * 0.55,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.richGold,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );

    if (showTooltip) {
      return Tooltip(
        message: isEnabled
            ? 'Retail Markup: ON (Tap to toggle)'
            : 'Retail Markup: OFF (Tap to toggle)',
        child: switchWidget,
      );
    }

    return switchWidget;
  }
}

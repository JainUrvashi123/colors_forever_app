import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/melee_constants.dart';
import '../../domain/models/melee_model.dart';
import '../providers/melee_provider.dart';

class BirthstoneMonthSelector extends StatefulWidget {
  final MeleeProvider provider;

  const BirthstoneMonthSelector({
    super.key,
    required this.provider,
  });

  @override
  State<BirthstoneMonthSelector> createState() => _BirthstoneMonthSelectorState();
}

class _BirthstoneMonthSelectorState extends State<BirthstoneMonthSelector> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;
        final months = provider.birthMonths.isNotEmpty
            ? provider.birthMonths
            : MeleeConstants.birthMonths;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "MONTH" with selected month badge and clear button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'MONTH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  if (provider.selectedMonth != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warmGoldTint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.champagneGold.withAlpha(120),
                        ),
                      ),
                      child: Text(
                        '${provider.selectedMonth!.displayName} • ${provider.selectedMonth!.shadeName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.richGold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Responsive Month Grid (3 columns on mobile: 4 quarterly rows; 6 columns on tablet/web)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final crossAxisCount = isWide ? 6 : 3;
                  final childAspectRatio = isWide ? 2.8 : 2.5;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    itemCount: months.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return _buildMonthButton(context, months[index]);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthButton(
    BuildContext context,
    BirthMonthOption month,
  ) {
    final isSelected = widget.provider.selectedMonth?.month == month.month;
    final isApril = month.month.toLowerCase() == 'april';
    final isNovember = month.month.toLowerCase() == 'november';
    final isDarkText = isApril || isNovember;
    final textColor = isDarkText ? const Color(0xFF1F2937) : Colors.white;

    return GestureDetector(
      onTap: () {
        if (month.isDisabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'April (White / Diamond) is not available in color melee.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        widget.provider.selectMonth(isSelected ? null : month);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: month.accentColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : (isApril
                  ? Border.all(color: const Color(0xFFD1D5DB), width: 1.2)
                  : Border.all(color: Colors.black.withAlpha(25), width: 0.8)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E6FBA).withAlpha(120),
                    spreadRadius: 1.5,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: month.accentColor.withAlpha(80),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 2.5,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 13, color: textColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                month.displayName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

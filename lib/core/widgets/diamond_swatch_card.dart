import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'diamond_shape_icon.dart';

class DiamondColorSpec {
  final String key;
  final String displayName;
  final String singleLineName;
  final String assetPath;
  final Color bgColor;
  final Color borderColor;
  final Color selectedBorderColor;

  const DiamondColorSpec({
    required this.key,
    required this.displayName,
    required this.singleLineName,
    required this.assetPath,
    required this.bgColor,
    required this.borderColor,
    required this.selectedBorderColor,
  });
}

class DiamondSwatchCard extends StatelessWidget {
  final String colorName;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? cardSize;
  final bool showLabel;

  const DiamondSwatchCard({
    super.key,
    required this.colorName,
    this.isSelected = false,
    this.onTap,
    this.cardSize,
    this.showLabel = true,
  });

  /// All 10 official diamond colors in order of reference
  static const List<DiamondColorSpec> allSpecs = [
    DiamondColorSpec(
      key: 'Blue',
      displayName: 'Blue',
      singleLineName: 'Blue',
      assetPath: 'assets/images/Sky Blue.png',
      bgColor: Color(0xFFEBF3FC),
      borderColor: Color(0xFFB9D8F5),
      selectedBorderColor: Color(0xFF1E6FBA),
    ),
    DiamondColorSpec(
      key: 'Green',
      displayName: 'Green',
      singleLineName: 'Green',
      assetPath: 'assets/images/Pine Green.png',
      bgColor: Color(0xFFEBF7F0),
      borderColor: Color(0xFFBDE7CF),
      selectedBorderColor: Color(0xFF108A48),
    ),
    DiamondColorSpec(
      key: 'Yellow',
      displayName: 'Yellow',
      singleLineName: 'Yellow',
      assetPath: 'assets/images/Golden Yellow.png',
      bgColor: Color(0xFFFFFBE8),
      borderColor: Color(0xFFFDE68A),
      selectedBorderColor: Color(0xFFD97706),
    ),
    DiamondColorSpec(
      key: 'Pink',
      displayName: 'Pink',
      singleLineName: 'Pink',
      assetPath: 'assets/images/Rose Pink.png',
      bgColor: Color(0xFFFDF0F6),
      borderColor: Color(0xFFFBCFE8),
      selectedBorderColor: Color(0xFFDB2777),
    ),
    DiamondColorSpec(
      key: 'Purple',
      displayName: 'Purple',
      singleLineName: 'Purple',
      assetPath: 'assets/images/Purple Pink.png',
      bgColor: Color(0xFFF7F0FB),
      borderColor: Color(0xFFDEC5F2),
      selectedBorderColor: Color(0xFF9333EA),
    ),
    DiamondColorSpec(
      key: 'Red',
      displayName: 'Red',
      singleLineName: 'Red',
      assetPath: 'assets/images/Reddish Cognac.png',
      bgColor: Color(0xFFFDF1F0),
      borderColor: Color(0xFFF9C3BE),
      selectedBorderColor: Color(0xFFDC2626),
    ),
    DiamondColorSpec(
      key: 'Orange',
      displayName: 'Orange',
      singleLineName: 'Orange',
      assetPath: 'assets/images/Organish Cognac.png',
      bgColor: Color(0xFFFFF4EB),
      borderColor: Color(0xFFFED7AA),
      selectedBorderColor: Color(0xFFEA580C),
    ),
    DiamondColorSpec(
      key: 'Black',
      displayName: 'Black',
      singleLineName: 'Black',
      assetPath: 'assets/images/Black.png',
      bgColor: Color(0xFFF1F3F5),
      borderColor: Color(0xFFD1D5DB),
      selectedBorderColor: Color(0xFF1F2937),
    ),
    DiamondColorSpec(
      key: 'Champagne/Brown',
      displayName: 'Champagne/\nBrown',
      singleLineName: 'Champagne/Brown',
      assetPath: 'assets/images/Brown Diamond.png',
      bgColor: Color(0xFFFAF5EE),
      borderColor: Color(0xFFEADBCC),
      selectedBorderColor: Color(0xFF9A6E3A),
    ),
    DiamondColorSpec(
      key: 'White/Colorless',
      displayName: 'White/\nColorless',
      singleLineName: 'White/Colorless',
      assetPath: 'assets/images/White Diamond.png',
      bgColor: Color(0xFFF3F6F9),
      borderColor: Color(0xFFD8DFE6),
      selectedBorderColor: Color(0xFF4B5563),
    ),
  ];

  static DiamondColorSpec getSpec(String name) {
    final lower = name.trim().toLowerCase();
    for (final spec in allSpecs) {
      if (spec.key.toLowerCase() == lower ||
          spec.singleLineName.toLowerCase() == lower ||
          spec.displayName.toLowerCase().replaceAll('\n', '') == lower) {
        return spec;
      }
    }
    // Check aliases
    if (lower == 'brown' || lower.contains('brown') || lower.contains('champagne')) {
      return allSpecs.firstWhere((s) => s.key == 'Champagne/Brown');
    }
    if (lower == 'white' || lower == 'colorless') {
      return allSpecs.firstWhere((s) => s.key == 'White/Colorless');
    }

    // Default fallback
    final fallbackAsset = AppAssets.getDiamondImageForShade(name) ??
        'assets/images/Sky Blue.png';
    return DiamondColorSpec(
      key: name,
      displayName: name,
      singleLineName: name,
      assetPath: fallbackAsset,
      bgColor: const Color(0xFFF5F7FA),
      borderColor: const Color(0xFFE2E8F0),
      selectedBorderColor: const Color(0xFF1E6FBA),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spec = getSpec(colorName);

    final cardContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: spec.bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? spec.selectedBorderColor : spec.borderColor,
          width: isSelected ? 2.5 : 1.4,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: spec.selectedBorderColor.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            const BoxShadow(
              color: Color(0x08000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
        ],
      ),
      padding: const EdgeInsets.all(4.0),
      child: ClipOval(
        child: SizedBox.expand(
          child: Transform.scale(
            scale: (spec.assetPath.contains('Brown') || spec.assetPath.contains('White'))
                ? 1.38
                : 1.05,
            child: Image.asset(
              spec.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: spec.borderColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: spec.singleLineName,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: cardSize ?? 52,
                maxHeight: cardSize ?? 52,
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: cardContainer,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 5),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cardSize != null ? cardSize! + 32 : 96,
                ),
                child: Text(
                  spec.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                    color: const Color(0xFF1557BF),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A 4-columns grid layout for diamond colors, wrapping onto the next line
class DiamondSwatchGrid extends StatelessWidget {
  final List<String> colors;
  final Set<String> selectedColors;
  final ValueChanged<String> onColorSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;

  const DiamondSwatchGrid({
    super.key,
    required this.colors,
    required this.selectedColors,
    required this.onColorSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.spacing = 10.0,
    this.runSpacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // Chunk into groups of 4
    final rows = <List<String>>[];
    for (var i = 0; i < colors.length; i += 4) {
      rows.add(colors.sublist(i, i + 4 > colors.length ? colors.length : i + 4));
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: runSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < 4; c++) ...[
                  if (c > 0) SizedBox(width: spacing),
                  Expanded(
                    child: c < rows[r].length
                        ? Builder(
                            builder: (context) {
                              final colName = rows[r][c];
                              final isSelected = selectedColors.contains(colName) ||
                                  (selectedColors.contains('Brown') && colName == 'Champagne/Brown') ||
                                  (selectedColors.contains('White') && colName == 'White/Colorless');

                              return DiamondSwatchCard(
                                colorName: colName,
                                isSelected: isSelected,
                                onTap: () => onColorSelected(colName),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A multi-row grid layout for diamond shapes (arranged in 2-3 rows)
class DiamondShapeGrid extends StatelessWidget {
  final List<String> shapes;
  final Set<String> selectedShapes;
  final ValueChanged<String> onShapeSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;
  final int itemsPerRow;

  const DiamondShapeGrid({
    super.key,
    required this.shapes,
    required this.selectedShapes,
    required this.onShapeSelected,
    this.padding = EdgeInsets.zero,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.itemsPerRow = 4,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[];
    for (var i = 0; i < shapes.length; i += itemsPerRow) {
      rows.add(shapes.sublist(
        i,
        i + itemsPerRow > shapes.length ? shapes.length : i + itemsPerRow,
      ));
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: runSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < itemsPerRow; c++) ...[
                  if (c > 0) SizedBox(width: spacing),
                  Expanded(
                    child: c < rows[r].length
                        ? _buildShapeCard(rows[r][c])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShapeCard(String shape) {
    final isSelected = selectedShapes.contains(shape);

    return Tooltip(
      message: shape,
      child: InkWell(
        onTap: () => onShapeSelected(shape),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 68,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEBF3FC) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E6FBA)
                  : const Color(0xFFD8DFE6),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF1E6FBA).withAlpha(35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              else
                const BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DiamondShapeIcon(
                shape: shape,
                size: 28,
                color: isSelected
                    ? const Color(0xFF1E6FBA)
                    : const Color(0xFF1E293B),
              ),
              const SizedBox(height: 4),
              Text(
                shape.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF1E6FBA)
                      : const Color(0xFF1E293B),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A luxury shade pill button displaying the shade color and name
class ShadePill extends StatelessWidget {
  final String shadeName;
  final bool isSelected;
  final VoidCallback? onTap;

  const ShadePill({
    super.key,
    required this.shadeName,
    this.isSelected = false,
    this.onTap,
  });

  static Color getShadeColor(String shadeName) {
    final lower = shadeName.toLowerCase().trim();
    if (lower.contains('aqua blue ii') || lower.contains('aqua blue 2')) {
      return const Color(0xFF78ADE3);
    }
    if (lower.contains('aqua')) return const Color(0xFF85B5E1);
    if (lower.contains('sky')) return const Color(0xFF2B65B4);
    if (lower.contains('ocean')) return const Color(0xFF20559E);
    if (lower.contains('royal')) return const Color(0xFF0A3A7B);
    if (lower.contains('pine')) return const Color(0xFFA3EBB7);
    if (lower.contains('ice green ii') || lower.contains('ice green 2')) {
      return const Color(0xFF7ED168);
    }
    if (lower.contains('ice')) return const Color(0xFF7ED168);
    if (lower.contains('emerald')) return const Color(0xFF12A023);
    if (lower.contains('forest')) return const Color(0xFF067E15);
    if (lower.contains('canary')) return const Color(0xFFFFFF71);
    if (lower.contains('golden') || lower.contains('gold')) return const Color(0xFFFFEA25);
    if (lower.contains('baby')) return const Color(0xFFF29ACF);
    if (lower.contains('rose')) return const Color(0xFFD84CA1);
    if (lower.contains('purplish')) return const Color(0xFFA5357E);
    if (lower.contains('purple')) return const Color(0xFF8A1B63);
    if (lower.contains('reddish') || lower.contains('red')) return const Color(0xFFA22F05);
    if (lower.contains('orangish') || lower.contains('orange')) return const Color(0xFFCA5615);
    if (lower.contains('black')) return const Color(0xFF1A1A1A);
    if (lower.contains('brown-c4')) return const Color(0xFFC4A482);
    if (lower.contains('brown-c5')) return const Color(0xFFA67B4F);
    if (lower.contains('brown-c6')) return const Color(0xFF87582B);
    if (lower.contains('brown-c7')) return const Color(0xFF5A3614);
    if (lower.contains('brown') || lower.contains('champagne')) return const Color(0xFF9A6E3A);
    if (lower.contains('white') || lower.length <= 3) return const Color(0xFFF8FAFC);
    return const Color(0xFF1E6FBA);
  }

  static bool isLightShade(Color color) {
    return color.computeLuminance() > 0.55;
  }

  static String formatShadeName(String name) {
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      final upper = word.toUpperCase();
      if (upper == 'I' || upper == 'II' || upper == 'III' || upper == 'IV') {
        return upper;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = getShadeColor(shadeName);
    final formattedName = formatShadeName(shadeName);
    final isLight = isLightShade(baseColor);
    final textColor = isLight ? const Color(0xFF1F2937) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9.5),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : (baseColor == const Color(0xFFFFFFFF) || baseColor == const Color(0xFFF8FAFC)
                  ? Border.all(color: const Color(0xFFD1D5DB), width: 1.2)
                  : null),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0xFF1E6FBA),
                    spreadRadius: 2.2,
                    blurRadius: 0,
                    offset: Offset(0, 0),
                  ),
                  BoxShadow(
                    color: baseColor.withAlpha(90),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(22),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          formattedName,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
            letterSpacing: 0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// A 3-columns grid layout for diamond color shades, wrapping onto the next line
class ShadeGrid extends StatelessWidget {
  final List<String> shades;
  final Set<String> selectedShades;
  final ValueChanged<String> onShadeSelected;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;

  const ShadeGrid({
    super.key,
    required this.shades,
    required this.selectedShades,
    required this.onShadeSelected,
    this.padding = EdgeInsets.zero,
    this.spacing = 9.0,
    this.runSpacing = 9.0,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[];
    for (var i = 0; i < shades.length; i += 3) {
      rows.add(shades.sublist(i, i + 3 > shades.length ? shades.length : i + 3));
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: runSpacing),
            Row(
              children: [
                for (var c = 0; c < 3; c++) ...[
                  if (c > 0) SizedBox(width: spacing),
                  Expanded(
                    child: c < rows[r].length
                        ? ShadePill(
                            shadeName: rows[r][c],
                            isSelected: selectedShades.contains(rows[r][c]) ||
                                selectedShades.any((s) => s.toLowerCase() == rows[r][c].toLowerCase()),
                            onTap: () => onShadeSelected(rows[r][c]),
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Signature luxury action button for "Reset Filter"
class ResetFilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final double height;
  final double? width;

  const ResetFilterButton({
    super.key,
    required this.onTap,
    this.label = 'Reset Filter',
    this.height = 44,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E6FBA),
          backgroundColor: const Color(0xFFF8FAFC),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rotate_left, size: 16, color: Color(0xFF1E6FBA)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E6FBA),
                  letterSpacing: 0.1,
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

/// The signature Colors Forever double-ring outline pill button for "Add To Cart"
/// (Matching official design in media_1788514829105.png and media_1788502153609.png)
class AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final double height;
  final double? width;

  const AddToCartButton({
    super.key,
    required this.onTap,
    this.label = 'Add To Cart',
    this.height = 40,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF1E6FBA),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(2.5),
        child: Material(
          color: AppColors.champagneGold,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom diamond facet silhouette clipper for color tone swatches
class DiamondClipper extends CustomClipper<Path> {
  const DiamondClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    // Classic brilliant-cut diamond shape (flat table top, crown facets, pavilion point)
    path.moveTo(w * 0.24, h * 0.04);
    path.lineTo(w * 0.76, h * 0.04);
    path.lineTo(w * 0.96, h * 0.35);
    path.lineTo(w * 0.50, h * 0.96);
    path.lineTo(w * 0.04, h * 0.35);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DiamondShapeIcon extends StatelessWidget {
  final String shape;
  final double size;
  final Color color;

  const DiamondShapeIcon({
    super.key,
    required this.shape,
    this.size = 24.0,
    this.color = AppColors.primary,
  });

  /// Maps diamond shape string to exact unicode character code from `webfontregular` (diamonds.ttf) font
  static String? getCharForShape(String shapeName) {
    final normalized = shapeName.trim().toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    switch (normalized) {
      case 'ROUND':
        return '\u0061'; // 'a'
      case 'PRINCESS':
        return '\u0062'; // 'b'
      case 'ASSCHER':
        return '\u0063'; // 'c'
      case 'CLOSE':
        return '\u0064'; // 'd'
      case 'CLOSE_CIRCLE_FILL':
        return '\u0065'; // 'e'
      case 'CLOSE_CIRCLE':
        return '\u0066'; // 'f'
      case 'RADIANT':
        return '\u0067'; // 'g'
      case 'BAG':
      case 'BAGUETTE':
        return '\u0068'; // 'h'
      case 'BAG_O':
        return '\u0069'; // 'i'
      case 'BAG_O_S':
        return '\u006A'; // 'j'
      case 'SIDE':
        return '\u006B'; // 'k'
      case 'CUSHION':
        return '\u006C'; // 'l'
      case 'EMERALD':
        return '\u006D'; // 'm'
      case 'MARQUISE':
        return '\u006E'; // 'n'
      case 'OVAL':
        return '\u006F'; // 'o'
      case 'PEAR':
        return '\u0070'; // 'p'
      case 'HEART':
        return '\u0071'; // 'q'
      case 'RING':
        return '\u0072'; // 'r'
      case 'SETTING':
        return '\u0073'; // 's'
      case 'OTHER':
      default:
        return null; // For OTHER shape, use dedicated Other-dia.png image asset
    }
  }

  @override
  Widget build(BuildContext context) {
    final charStr = getCharForShape(shape);
    if (charStr != null) {
      return Text(
        charStr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'webfontregular',
          fontSize: size,
          color: color,
          height: 1.0,
        ),
      );
    }

    return Image.asset(
      'assets/images/Other-dia.png',
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          '\u0061',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'webfontregular',
            fontSize: size,
            color: color,
            height: 1.0,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'melee_model.dart';

class MeleeConstants {
  static const List<MeleeColorOption> colors = [
    MeleeColorOption(
      name: 'Blue',
      assetPath: 'assets/colors/blue.jpg',
      primaryColor: Color(0xFF0D47A1),
      networkImgUrl: 'https://colorsforever.com/assets/images/blue.jpg',
    ),
    MeleeColorOption(
      name: 'Green',
      assetPath: 'assets/colors/green.jpg',
      primaryColor: Color(0xFF1B5E20),
      networkImgUrl: 'https://colorsforever.com/assets/images/green.jpg',
    ),
    MeleeColorOption(
      name: 'Yellow',
      assetPath: 'assets/colors/yellow.jpg',
      primaryColor: Color(0xFFE5A910),
      networkImgUrl: 'https://colorsforever.com/assets/images/yellow.jpg',
    ),
    MeleeColorOption(
      name: 'Pink',
      assetPath: 'assets/colors/pink.jpg',
      primaryColor: Color(0xFFD81B60),
      networkImgUrl: 'https://colorsforever.com/assets/images/pink.jpg',
    ),
    MeleeColorOption(
      name: 'Purple',
      assetPath: 'assets/colors/purple.jpg',
      primaryColor: Color(0xFF6A1B9A),
      networkImgUrl: 'https://colorsforever.com/assets/images/purple.jpg',
    ),
    MeleeColorOption(
      name: 'Red',
      assetPath: 'assets/colors/red.jpg',
      primaryColor: Color(0xFFB71C1C),
      networkImgUrl: 'https://colorsforever.com/assets/images/red.jpg',
    ),
    MeleeColorOption(
      name: 'Orange',
      assetPath: 'assets/colors/orange.jpg',
      primaryColor: Color(0xFFE65100),
      networkImgUrl: 'https://colorsforever.com/assets/images/orange.jpg',
    ),
    MeleeColorOption(
      name: 'Black',
      assetPath: 'assets/colors/black.jpg',
      primaryColor: Color(0xFF212121),
      networkImgUrl: 'https://colorsforever.com/assets/images/black.jpg',
    ),
    MeleeColorOption(
      name: 'Champagne/Brown',
      assetPath: 'assets/images/Brown Diamond.png',
      primaryColor: Color(0xFF8D6E63),
      networkImgUrl: 'https://colorsforever.com/assets/images/brown.jpg',
    ),
    MeleeColorOption(
      name: 'White/Colorless',
      assetPath: 'assets/images/White Diamond.png',
      primaryColor: Color(0xFF9E9E9E),
      networkImgUrl: 'https://colorsforever.com/assets/images/white.jpg',
    ),
  ];

  static const List<MeleeShadeOption> allShades = [
    // Blue Shades
    MeleeShadeOption(
      name: 'AQUA BLUE I',
      colorName: 'Blue',
      badgeColor: Color(0xFF4FC3F7),
      matchingMonth: 'march',
    ),
    MeleeShadeOption(
      name: 'AQUA BLUE II',
      colorName: 'Blue',
      badgeColor: Color(0xFF29B6F6),
    ),
    MeleeShadeOption(
      name: 'SKY BLUE',
      colorName: 'Blue',
      badgeColor: Color(0xFF0288D1),
      matchingMonth: 'december',
    ),
    MeleeShadeOption(
      name: 'OCEAN BLUE',
      colorName: 'Blue',
      badgeColor: Color(0xFF01579B),
    ),
    MeleeShadeOption(
      name: 'ROYAL BLUE',
      colorName: 'Blue',
      badgeColor: Color(0xFF0D47A1),
      matchingMonth: 'september',
    ),

    // Green Shades
    MeleeShadeOption(
      name: 'PINE GREEN',
      colorName: 'Green',
      badgeColor: Color(0xFF2E7D32),
    ),
    MeleeShadeOption(
      name: 'ICE GREEN I',
      colorName: 'Green',
      badgeColor: Color(0xFF81C784),
      matchingMonth: 'august',
    ),
    MeleeShadeOption(
      name: 'ICE GREEN II',
      colorName: 'Green',
      badgeColor: Color(0xFF66BB6A),
    ),
    MeleeShadeOption(
      name: 'EMERALD GREEN',
      colorName: 'Green',
      badgeColor: Color(0xFF1B5E20),
      matchingMonth: 'may',
    ),
    MeleeShadeOption(
      name: 'FOREST GREEN',
      colorName: 'Green',
      badgeColor: Color(0xFF004D40),
      matchingMonth: 'june',
    ),

    // Yellow Shades
    MeleeShadeOption(
      name: 'CANARY YELLOW',
      colorName: 'Yellow',
      badgeColor: Color(0xFFFDD835),
    ),
    MeleeShadeOption(
      name: 'GOLDEN YELLOW',
      colorName: 'Yellow',
      badgeColor: Color(0xFFFFB300),
      matchingMonth: 'november',
    ),

    // Pink Shades
    MeleeShadeOption(
      name: 'BABY PINK',
      colorName: 'Pink',
      badgeColor: Color(0xFFF48FB1),
    ),
    MeleeShadeOption(
      name: 'ROSE PINK',
      colorName: 'Pink',
      badgeColor: Color(0xFFD81B60),
      matchingMonth: 'october',
    ),

    // Purple Shades
    MeleeShadeOption(
      name: 'PURPLISH PINK',
      colorName: 'Purple',
      badgeColor: Color(0xFFBA68C8),
    ),
    MeleeShadeOption(
      name: 'PURPLE',
      colorName: 'Purple',
      badgeColor: Color(0xFF6A1B9A),
      matchingMonth: 'february',
    ),

    // Red Shades
    MeleeShadeOption(
      name: 'REDDISH COGNAC',
      colorName: 'Red',
      badgeColor: Color(0xFFB71C1C),
      matchingMonth: 'july',
    ),

    // Orange Shades
    MeleeShadeOption(
      name: 'ORANGISH COGNAC',
      colorName: 'Orange',
      badgeColor: Color(0xFFE65100),
      matchingMonth: 'january',
    ),

    // Black Shades
    MeleeShadeOption(
      name: 'BLACK',
      colorName: 'Black',
      badgeColor: Color(0xFF212121),
    ),
  ];

  static const List<BirthMonthOption> birthMonths = [
    BirthMonthOption(
      month: 'january',
      displayName: 'January',
      shadeName: 'ORANGISH COGNAC',
      colorName: 'Orange',
      accentColor: Color(0xFFCA5615),
    ),
    BirthMonthOption(
      month: 'february',
      displayName: 'February',
      shadeName: 'PURPLE',
      colorName: 'Purple',
      accentColor: Color(0xFF8A1B63),
    ),
    BirthMonthOption(
      month: 'march',
      displayName: 'March',
      shadeName: 'AQUA BLUE I',
      colorName: 'Blue',
      accentColor: Color(0xFF85B5E1),
    ),
    BirthMonthOption(
      month: 'april',
      displayName: 'April',
      shadeName: 'WHITE',
      colorName: 'White',
      accentColor: Color(0xFFFFFFFF),
      isDisabled: true, // Diamond / White month disabled on colorsforever
    ),
    BirthMonthOption(
      month: 'may',
      displayName: 'May',
      shadeName: 'EMERALD GREEN',
      colorName: 'Green',
      accentColor: Color(0xFF12A023),
    ),
    BirthMonthOption(
      month: 'june',
      displayName: 'June',
      shadeName: 'FOREST GREEN',
      colorName: 'Green',
      accentColor: Color(0xFF067E15),
    ),
    BirthMonthOption(
      month: 'july',
      displayName: 'July',
      shadeName: 'REDDISH COGNAC',
      colorName: 'Red',
      accentColor: Color(0xFFA22F05),
    ),
    BirthMonthOption(
      month: 'august',
      displayName: 'August',
      shadeName: 'ICE GREEN I',
      colorName: 'Green',
      accentColor: Color(0xFF7ED168),
    ),
    BirthMonthOption(
      month: 'september',
      displayName: 'September',
      shadeName: 'ROYAL BLUE',
      colorName: 'Blue',
      accentColor: Color(0xFF0A3A7B),
    ),
    BirthMonthOption(
      month: 'october',
      displayName: 'October',
      shadeName: 'ROSE PINK',
      colorName: 'Pink',
      accentColor: Color(0xFFD84CA1),
    ),
    BirthMonthOption(
      month: 'november',
      displayName: 'November',
      shadeName: 'GOLDEN YELLOW',
      colorName: 'Yellow',
      accentColor: Color(0xFFFFEA25),
    ),
    BirthMonthOption(
      month: 'december',
      displayName: 'December',
      shadeName: 'SKY BLUE',
      colorName: 'Blue',
      accentColor: Color(0xFF2B65B4),
    ),
  ];

  static const List<String> defaultSizes = [
    '0.8 MM', '0.9 MM', '1.0 MM', '1.1 MM', '1.2 MM', '1.3 MM',
    '1.4 MM', '1.5 MM', '1.6 MM', '1.7 MM', '1.8 MM', '1.9 MM',
    '2.0 MM', '2.1 MM', '2.2 MM', '2.3 MM', '2.4 MM', '2.5 MM',
    '2.6 MM', '2.7 MM', '2.8 MM', '2.9 MM', '3.0 MM', '3.1 MM',
    '3.2 MM', '3.3 MM', '3.4 MM', '3.5 MM',
    '1/5 CTS', '1/4 CTS', '1/3 CTS', '3/8 CTS', '1/2 CTS', '3/4 CTS',
  ];

  static const Set<String> premiumSizes = {
    '1.0 MM', '1.3 MM', '1.5 MM', '2.0 MM', '2.5 MM', '3.0 MM', '3.5 MM',
  };

  static bool isPremiumSize(String? size) {
    if (size == null || size.trim().isEmpty) return false;
    final normalized = size.trim().toUpperCase().replaceAll(' ', '');
    for (final s in premiumSizes) {
      if (s.toUpperCase().replaceAll(' ', '') == normalized) return true;
    }
    return false;
  }

  static const List<String> defaultGrades = [
    'VVS1-VS2',
    'VS2-SI2',
    'SI2-I1',
  ];

  static double getClarityMultiplier(String grade) {
    switch (grade.toUpperCase()) {
      case 'VVS1-VS2':
        return 1.10;
      case 'VS2-SI2':
        return 1.0;
      case 'SI2-I1':
        return 0.85;
      default:
        return 1.0;
    }
  }

  // Base approximate carat weight per single stone for accurate offline fallback
  static const Map<String, (double, double)> sizeToWeightRange = {
    '0.8 MM': (0.0020, 0.0030),
    '0.9 MM': (0.0030, 0.0050),
    '1.0 MM': (0.0040, 0.0060),
    '1.1 MM': (0.0050, 0.0070),
    '1.2 MM': (0.0070, 0.0090),
    '1.3 MM': (0.0090, 0.0110),
    '1.4 MM': (0.0110, 0.0135),
    '1.5 MM': (0.0130, 0.0160),
    '1.6 MM': (0.0160, 0.0190),
    '1.7 MM': (0.0190, 0.0220),
    '1.8 MM': (0.0220, 0.0260),
    '1.9 MM': (0.0260, 0.0300),
    '2.0 MM': (0.0300, 0.0350),
    '2.1 MM': (0.0350, 0.0410),
    '2.2 MM': (0.0410, 0.0470),
    '2.3 MM': (0.0470, 0.0540),
    '2.4 MM': (0.0540, 0.0610),
    '2.5 MM': (0.0610, 0.0700),
    '2.6 MM': (0.0700, 0.0800),
    '2.7 MM': (0.0800, 0.0900),
    '2.8 MM': (0.0900, 0.1000),
    '2.9 MM': (0.1000, 0.1100),
    '3.0 MM': (0.1050, 0.1150),
    '3.1 MM': (0.1150, 0.1250),
    '3.2 MM': (0.1250, 0.1400),
    '3.3 MM': (0.1350, 0.1500),
    '3.4 MM': (0.1450, 0.1600),
    '3.5 MM': (0.1550, 0.1750),
    '1/5 CTS': (0.1800, 0.2200),
    '1/4 CTS': (0.2300, 0.2700),
    '1/3 CTS': (0.3000, 0.3500),
    '3/8 CTS': (0.3600, 0.4000),
    '1/2 CTS': (0.4600, 0.5300),
    '3/4 CTS': (0.7000, 0.7700),
  };

  // Base price per carat by shade for offline fallback
  static double getBasePricePerCarat(String shade) {
    switch (shade.toUpperCase()) {
      case 'FOREST GREEN':
        return 635.0;
      case 'SKY BLUE':
      case 'AQUA BLUE I':
      case 'AQUA BLUE II':
      case 'OCEAN BLUE':
      case 'ROYAL BLUE':
        return 645.0;
      case 'EMERALD GREEN':
      case 'PINE GREEN':
      case 'ICE GREEN I':
      case 'ICE GREEN II':
        return 580.0;
      case 'CANARY YELLOW':
      case 'GOLDEN YELLOW':
        return 490.0;
      case 'ROSE PINK':
      case 'BABY PINK':
        return 720.0;
      case 'PURPLE':
      case 'PURPLISH PINK':
        return 620.0;
      case 'REDDISH COGNAC':
        return 540.0;
      case 'ORANGISH COGNAC':
        return 510.0;
      case 'BLACK':
        return 380.0;
      default:
        return 600.0;
    }
  }

  // Generate fallback preview URL for shade
  static String getPreviewImageUrl(String shade, {bool isSolitaire = false}) {
    final slug = shade.toLowerCase().replaceAll(' ', '-');
    final suffix = isSolitaire ? '-sol' : '';
    return 'https://colorsforever.com/assets/images/melle/preview/$slug$suffix.jpg';
  }

  // 16-pile and 4-pile image/video URLs
  static const String melee16OverviewUrl =
      'https://colorsforever.com/assets/images/melle-diamonds.png';
  static const String solitaire16OverviewUrl =
      'https://colorsforever.com/assets/images/solitaire-diamonds.png';

  static String get4BlockVideoUrl(String color, {bool isSolitaire = false}) {
    final suffix = isSolitaire ? '_sol' : '';
    return 'https://colorsforever.com/assets/images/melle/videos/$color$suffix.mp4';
  }

  static MeleeCalculationResult calculateFallbackEstimate(
    String shade,
    String size,
    int quantity, {
    String clarity = 'VVS1-VS2',
  }) {
    final basePrice = getBasePricePerCarat(shade) * getClarityMultiplier(clarity);
    final weightRange = sizeToWeightRange[size] ?? (0.0030, 0.0050);

    final totalWtFrom = weightRange.$1 * quantity;
    final totalWtTo = weightRange.$2 * quantity;
    final totalPriceFrom = totalWtFrom * basePrice;
    final totalPriceTo = totalWtTo * basePrice;

    return MeleeCalculationResult(
      pricePerCarat: '\$${basePrice.toStringAsFixed(0)}',
      wtFrom: totalWtFrom.toStringAsFixed(4),
      wtTo: totalWtTo.toStringAsFixed(4),
      priceFrom: '\$${totalPriceFrom.round()}',
      priceTo: '\$${totalPriceTo.round()}',
      isExceeded: quantity > 10000,
    );
  }
}

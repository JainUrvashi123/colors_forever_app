class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String favicon = 'assets/images/favicon.png';
  static const String solitaireDiamonds = 'assets/images/SOLITIRE.jpg';
  static const String meleeDiamonds = 'assets/images/MELEE.jpg';
  static const String colorJewelry = 'assets/images/JEWELRY.jpg';
  static const String otherDiamond = 'assets/images/Other-dia.png';
  static const String noImageDiamond = 'assets/images/no_image_diamond.jpg';
  static const String backgroundImage = 'assets/images/colorsfor.jpg';
  static const String giaCert = 'assets/certs/gia.png';
  static const String igiCert = 'assets/certs/igi.png';

  static const Map<String, String> colorSwatches = {
    'Blue': 'assets/images/Sky Blue.png',
    'Green': 'assets/images/Pine Green.png',
    'Yellow': 'assets/images/Golden Yellow.png',
    'Pink': 'assets/images/Rose Pink.png',
    'Purple': 'assets/images/Purple Pink.png',
    'Red': 'assets/images/Reddish Cognac.png',
    'Orange': 'assets/images/Organish Cognac.png',
    'Black': 'assets/images/Black.png',
    'Brown': 'assets/images/Brown Diamond.png',
    'Champagne/Brown': 'assets/images/Brown Diamond.png',
    'White': 'assets/images/White Diamond.png',
    'White/Colorless': 'assets/images/White Diamond.png',
  };

  static const Map<String, String> diamondShadeImages = {
    'Aqua Blue': 'assets/images/Aqua Blue.png',
    'Baby Pink': 'assets/images/Baby Pink.png',
    'Black': 'assets/images/Black.png',
    'Canary Yellow': 'assets/images/Canary Yellow.png',
    'Emerald Green': 'assets/images/Emerald Green.png',
    'Forest Green': 'assets/images/Forest Green.png',
    'Golden Yellow': 'assets/images/Golden Yellow.png',
    'Ice Green': 'assets/images/Ice Green.png',
    'Ocean Blue': 'assets/images/Ocean Blue.png',
    'Organish Cognac': 'assets/images/Organish Cognac.png',
    'Pine Green': 'assets/images/Pine Green.png',
    'Purple Pink': 'assets/images/Purple Pink.png',
    'Reddish Cognac': 'assets/images/Reddish Cognac.png',
    'Rose Pink': 'assets/images/Rose Pink.png',
    'Royal Blue': 'assets/images/Royal Blue.png',
    'Sky Blue': 'assets/images/Sky Blue.png',
  };

  /// Returns the diamond asset image path for a given shade name or color category.
  static String? getDiamondImageForShade(String? shadeOrColor) {
    if (shadeOrColor == null || shadeOrColor.trim().isEmpty) return null;
    final normalized = shadeOrColor.trim().toLowerCase();

    // 1. Exact match
    for (final entry in diamondShadeImages.entries) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.value;
      }
    }

    // 2. Prefix / Contains match (e.g. "Aqua Blue I" -> "Aqua Blue")
    for (final entry in diamondShadeImages.entries) {
      final keyLower = entry.key.toLowerCase();
      if (normalized.startsWith(keyLower) || keyLower.startsWith(normalized)) {
        return entry.value;
      }
    }

    // 3. Keyword matching for specific shades & colors
    if (normalized.contains('aqua')) return 'assets/images/Aqua Blue.png';
    if (normalized.contains('ocean')) return 'assets/images/Ocean Blue.png';
    if (normalized.contains('royal')) return 'assets/images/Royal Blue.png';
    if (normalized.contains('sky') || normalized == 'blue') return 'assets/images/Sky Blue.png';
    if (normalized.contains('baby')) return 'assets/images/Baby Pink.png';
    if (normalized.contains('purple pink') || normalized.contains('purplish')) return 'assets/images/Purple Pink.png';
    if (normalized.contains('rose') || normalized == 'pink') return 'assets/images/Rose Pink.png';
    if (normalized.contains('canary')) return 'assets/images/Canary Yellow.png';
    if (normalized.contains('golden') || normalized.contains('gold') || normalized == 'yellow') return 'assets/images/Golden Yellow.png';
    if (normalized.contains('emerald')) return 'assets/images/Emerald Green.png';
    if (normalized.contains('forest')) return 'assets/images/Forest Green.png';
    if (normalized.contains('ice')) return 'assets/images/Ice Green.png';
    if (normalized.contains('pine') || normalized == 'green') return 'assets/images/Pine Green.png';
    if (normalized.contains('brown') || normalized.contains('champagne')) {
      return 'assets/images/Brown Diamond.png';
    }
    if (normalized.contains('organish') ||
        normalized.contains('cognac') ||
        normalized == 'orange') {
      return 'assets/images/Organish Cognac.png';
    }
    if (normalized.contains('reddish') || normalized == 'red') {
      return 'assets/images/Reddish Cognac.png';
    }
    if (normalized.contains('black')) return 'assets/images/Black.png';
    if (normalized.contains('purple')) return 'assets/images/Purple Pink.png';
    if (normalized.contains('white') ||
        normalized.contains('colorless') ||
        normalized == 'd' ||
        normalized == 'e' ||
        normalized == 'f' ||
        normalized == 'g' ||
        normalized == 'h' ||
        normalized == 'i' ||
        normalized == 'j' ||
        normalized == 'k' ||
        normalized == 'l' ||
        normalized == 'm' ||
        normalized == 'n-z') {
      return 'assets/images/White Diamond.png';
    }

    return null;
  }

  static const String sampleDiamondsJson = 'assets/data/sample_diamonds.json';
}

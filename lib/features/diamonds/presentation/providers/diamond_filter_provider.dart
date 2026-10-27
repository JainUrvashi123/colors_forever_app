import 'package:flutter/material.dart';
import '../../domain/entities/diamond_filter.dart';
import '../../domain/entities/solitaire_index.dart';

class DiamondFilterProvider extends ChangeNotifier {
  DiamondFilter _filter = DiamondFilter.initial;
  SolitaireIndex _solitaireIndex = SolitaireIndex.empty;

  DiamondFilter get filter => _filter;
  SolitaireIndex get solitaireIndex => _solitaireIndex;

  void setSolitaireIndex(SolitaireIndex index) {
    _solitaireIndex = index;
    notifyListeners();
  }

  // Available colors on colorsforever.com
  List<String> get dynamicColors {
    if (_solitaireIndex.colors.isNotEmpty) {
      return _solitaireIndex.colors.map((c) => c.name).toList();
    }
    return availableColors;
  }

  static const List<String> availableColors = [
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Red',
    'Orange',
    'Black',
    'Champagne/Brown',
    'White/Colorless',
  ];

  // Map each color to its website shades
  static const Map<String, List<String>> colorToShades = {
    'Blue': ['AQUA BLUE', 'SKY BLUE', 'OCEAN BLUE', 'ROYAL BLUE'],
    'Green': ['PINE GREEN', 'ICE GREEN', 'EMERALD GREEN', 'FOREST GREEN'],
    'Yellow': ['CANARY YELLOW', 'GOLDEN YELLOW'],
    'Pink': ['BABY PINK', 'ROSE PINK'],
    'Purple': ['PURPLISH PINK', 'PURPLE'],
    'Red': ['REDDISH COGNAC'],
    'Orange': ['ORANGISH COGNAC'],
    'Black': ['BLACK'],
    'Brown': ['BROWN-C4', 'BROWN-C5', 'BROWN-C6', 'BROWN-C7'],
    'Champagne/Brown': ['BROWN-C4', 'BROWN-C5', 'BROWN-C6', 'BROWN-C7'],
    'White': ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N-Z'],
    'White/Colorless': ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N-Z'],
  };

  static const List<String> availableShapes = [
    'ROUND',
    'ASSCHER',
    'CUSHION',
    'EMERALD',
    'HEART',
    'MARQUISE',
    'OVAL',
    'PRINCESS',
    'PEAR',
    'RADIANT',
    'OTHER',
  ];

  static const List<String> availableClarities = [
    'FL',
    'IF',
    'VVS1',
    'VVS2',
    'VS1',
    'VS2',
    'SI1',
    'SI2',
    'SI3',
    'I1',
    'I2',
    'I3',
  ];

  static const List<String> availableLabs = ['GIA', 'IGI'];

  static const List<Map<String, dynamic>> caratPresets = [
    {'label': 'ALL', 'min': 0.0, 'max': 100.0},
    {'label': 'BELOW 1.00', 'min': 0.0, 'max': 0.99},
    {'label': '1.00 - 1.49', 'min': 1.00, 'max': 1.49},
    {'label': '1.50 - 1.99', 'min': 1.50, 'max': 1.99},
    {'label': '2.00 - 2.99', 'min': 2.00, 'max': 2.99},
    {'label': '3.00 - 4.99', 'min': 3.00, 'max': 4.99},
    {'label': '5.00 - 9.99', 'min': 5.00, 'max': 9.99},
    {'label': '10.00 - 19.99', 'min': 10.00, 'max': 19.99},
    {'label': '20.00 +', 'min': 20.0, 'max': 100.0},
  ];

  static const List<Map<String, dynamic>> pricePresets = [
    {'label': 'ALL', 'min': 0.0, 'max': 500000.0},
    {'label': 'BELOW \$5K', 'min': 0.0, 'max': 5000.0},
    {'label': '\$5K - \$10K', 'min': 5000.0, 'max': 10000.0},
    {'label': '\$10K - \$25K', 'min': 10000.0, 'max': 25000.0},
    {'label': '\$25K - \$50K', 'min': 25000.0, 'max': 50000.0},
    {'label': '\$50K - \$100K', 'min': 50000.0, 'max': 100000.0},
    {'label': '\$100K +', 'min': 100000.0, 'max': 500000.0},
  ];

  List<String> get availableShades {
    if (_filter.selectedColors.isEmpty) return [];
    final shades = <String>{};
    for (final col in _filter.selectedColors) {
      if (colorToShades.containsKey(col)) {
        shades.addAll(colorToShades[col]!);
      }
    }
    return shades.toList();
  }

  void toggleColor(String color) {
    final list = List<String>.from(_filter.selectedColors);
    if (list.contains(color)) {
      list.remove(color);
      // Clean up shades that belong to removed color
      final removedShades = colorToShades[color] ?? [];
      final activeShades = List<String>.from(_filter.selectedShades)
        ..removeWhere((s) => removedShades.contains(s));
      _filter = _filter.copyWith(selectedColors: list, selectedShades: activeShades);
    } else {
      list.add(color);
      _filter = _filter.copyWith(selectedColors: list);
    }
    notifyListeners();
  }

  void toggleShade(String shade) {
    final list = List<String>.from(_filter.selectedShades);
    if (list.contains(shade)) {
      list.remove(shade);
    } else {
      list.add(shade);
    }
    _filter = _filter.copyWith(selectedShades: list);
    notifyListeners();
  }

  void toggleShape(String shape) {
    final list = List<String>.from(_filter.selectedShapes);
    if (list.contains(shape)) {
      list.remove(shape);
    } else {
      list.add(shape);
    }
    _filter = _filter.copyWith(selectedShapes: list);
    notifyListeners();
  }

  void toggleClarity(String clarity) {
    final list = List<String>.from(_filter.selectedClarities);
    if (list.contains(clarity)) {
      list.remove(clarity);
    } else {
      list.add(clarity);
    }
    _filter = _filter.copyWith(selectedClarities: list);
    notifyListeners();
  }

  void toggleLab(String lab) {
    final list = List<String>.from(_filter.selectedLabs);
    if (list.contains(lab)) {
      list.remove(lab);
    } else {
      list.add(lab);
    }
    _filter = _filter.copyWith(selectedLabs: list);
    notifyListeners();
  }

  void setCaratRange(double min, double max) {
    _filter = _filter.copyWith(minCarat: min, maxCarat: max);
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _filter = _filter.copyWith(minPrice: min, maxPrice: max);
    notifyListeners();
  }

  void setLocation(String? loc) {
    _filter = _filter.copyWith(location: loc);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setSortBy(String sort) {
    _filter = _filter.copyWith(sortBy: sort);
    notifyListeners();
  }

  void resetFilters() {
    _filter = DiamondFilter.initial;
    notifyListeners();
  }
}

class DiamondFilter {
  final List<String> selectedColors;
  final List<String> selectedShades;
  final List<String> selectedShapes;
  final List<String> selectedClarities;
  final List<String> selectedLabs;
  final double minCarat;
  final double maxCarat;
  final double minPrice;
  final double maxPrice;
  final String? location;
  final String searchQuery;
  final String sortBy; // weight_l, weight_h, shape_l, shape_h, color_l, color_h

  const DiamondFilter({
    this.selectedColors = const [],
    this.selectedShades = const [],
    this.selectedShapes = const [],
    this.selectedClarities = const [],
    this.selectedLabs = const [],
    this.minCarat = 0.0,
    this.maxCarat = 100.0,
    this.minPrice = 0.0,
    this.maxPrice = 500000.0,
    this.location,
    this.searchQuery = '',
    this.sortBy = 'weight_l',
  });

  bool get hasActiveFilters =>
      selectedColors.isNotEmpty ||
      selectedShades.isNotEmpty ||
      selectedShapes.isNotEmpty ||
      selectedClarities.isNotEmpty ||
      selectedLabs.isNotEmpty ||
      minCarat > 0.0 ||
      maxCarat < 100.0 ||
      minPrice > 0.0 ||
      maxPrice < 500000.0 ||
      (location != null && location!.isNotEmpty) ||
      searchQuery.trim().isNotEmpty ||
      (sortBy.isNotEmpty && sortBy != 'weight_l');

  int get activeFilterCount {
    int count = 0;
    if (selectedColors.isNotEmpty) count += selectedColors.length;
    if (selectedShades.isNotEmpty) count += selectedShades.length;
    if (selectedShapes.isNotEmpty) count += selectedShapes.length;
    if (selectedClarities.isNotEmpty) count += selectedClarities.length;
    if (selectedLabs.isNotEmpty) count += selectedLabs.length;
    if (minCarat > 0.0 || maxCarat < 100.0) count++;
    if (minPrice > 0.0 || maxPrice < 500000.0) count++;
    if (location != null && location!.isNotEmpty) count++;
    if (searchQuery.trim().isNotEmpty) count++;
    return count;
  }

  DiamondFilter copyWith({
    List<String>? selectedColors,
    List<String>? selectedShades,
    List<String>? selectedShapes,
    List<String>? selectedClarities,
    List<String>? selectedLabs,
    double? minCarat,
    double? maxCarat,
    double? minPrice,
    double? maxPrice,
    String? location,
    String? searchQuery,
    String? sortBy,
  }) {
    return DiamondFilter(
      selectedColors: selectedColors ?? this.selectedColors,
      selectedShades: selectedShades ?? this.selectedShades,
      selectedShapes: selectedShapes ?? this.selectedShapes,
      selectedClarities: selectedClarities ?? this.selectedClarities,
      selectedLabs: selectedLabs ?? this.selectedLabs,
      minCarat: minCarat ?? this.minCarat,
      maxCarat: maxCarat ?? this.maxCarat,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      location: location ?? this.location,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const DiamondFilter initial = DiamondFilter();
}

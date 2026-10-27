import 'package:flutter/foundation.dart';
import '../../data/datasources/jewelry_remote_data_source.dart';
import '../../data/models/jewelry_index_model.dart';
import '../../data/models/jewelry_item_model.dart';

class JewelryProvider extends ChangeNotifier {
  final JewelryRemoteDataSource _dataSource;

  JewelryIndexResponse _indexData = JewelryIndexResponse.empty;
  List<JewelryItem> _items = [];
  int _totalRecords = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isGridView = true;
  bool _isInitialized = false;

  // Active Filters State (Multi-Select Support)
  Set<String> _selectedDepartments = {'Ring'};
  Set<String> _selectedSec1List = {};
  Set<String> _selectedGoldKarats = {};
  Set<String> _selectedGoldColors = {};
  Set<String> _selectedDiamondColors = {};
  Set<String> _selectedStyleSettings = {};
  Set<String> _selectedSizes = {};
  double? _caratMin;
  double? _caratMax;
  double? _priceMin;
  double? _priceMax;
  String _searchQuery = '';
  String _sortBy = 'random';
  String? _userId;

  JewelryProvider({JewelryRemoteDataSource? dataSource, bool autoLoad = true})
      : _dataSource = dataSource ?? JewelryRemoteDataSource() {
    if (autoLoad) {
      initData();
    }
  }

  // Getters
  JewelryIndexResponse get indexData => _indexData;
  List<JewelryItem> get items => _items;
  int get totalRecords => _totalRecords;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage && !_isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;
  bool get isInitialized => _isInitialized;

  Set<String> get selectedDepartments => _selectedDepartments;
  String get selectedDepartment => _selectedDepartments.isEmpty ? 'All' : _selectedDepartments.first;

  Set<String> get selectedSec1List => _selectedSec1List;
  String? get selectedSec1 => _selectedSec1List.isEmpty ? null : _selectedSec1List.first;

  Set<String> get selectedGoldKarats => _selectedGoldKarats;
  String? get selectedGoldKarat => _selectedGoldKarats.isEmpty ? null : _selectedGoldKarats.first;

  Set<String> get selectedGoldColors => _selectedGoldColors;
  String? get selectedGoldColor => _selectedGoldColors.isEmpty ? null : _selectedGoldColors.first;

  Set<String> get selectedDiamondColors => _selectedDiamondColors;
  String? get selectedDiamondColor => _selectedDiamondColors.isEmpty ? null : _selectedDiamondColors.first;

  Set<String> get selectedStyleSettings => _selectedStyleSettings;
  String? get selectedStyleSetting => _selectedStyleSettings.isEmpty ? null : _selectedStyleSettings.first;

  Set<String> get selectedSizes => _selectedSizes;
  String? get selectedSize => _selectedSizes.isEmpty ? null : _selectedSizes.first;

  double? get caratMin => _caratMin;
  double? get caratMax => _caratMax;
  double? get priceMin => _priceMin;
  double? get priceMax => _priceMax;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String? get userId => _userId;

  int get activeFilterCount {
    int count = 0;
    count += _selectedDepartments.where((d) => d != 'All').length;
    count += _selectedSec1List.length;
    count += _selectedGoldKarats.length;
    count += _selectedGoldColors.length;
    count += _selectedDiamondColors.length;
    count += _selectedStyleSettings.length;
    count += _selectedSizes.length;
    if (_caratMin != null || _caratMax != null) count++;
    if (_priceMin != null || _priceMax != null) count++;
    if (_searchQuery.isNotEmpty) count++;
    if (_sortBy != 'random' && _sortBy.isNotEmpty) count++;
    return count;
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    applyFilters();
  }

  void applyAllFilters({
    Set<String>? departments,
    Set<String>? sec1List,
    Set<String>? goldKarats,
    Set<String>? goldColors,
    Set<String>? diamondColors,
    Set<String>? styleSettings,
    Set<String>? sizes,
    double? caratMin,
    double? caratMax,
    double? priceMin,
    double? priceMax,
  }) {
    if (departments != null) _selectedDepartments = Set.from(departments);
    if (sec1List != null) _selectedSec1List = Set.from(sec1List);
    if (goldKarats != null) _selectedGoldKarats = Set.from(goldKarats);
    if (goldColors != null) _selectedGoldColors = Set.from(goldColors);
    if (diamondColors != null) _selectedDiamondColors = Set.from(diamondColors);
    if (styleSettings != null) _selectedStyleSettings = Set.from(styleSettings);
    if (sizes != null) _selectedSizes = Set.from(sizes);
    _caratMin = caratMin;
    _caratMax = caratMax;
    _priceMin = priceMin;
    _priceMax = priceMax;

    applyFilters();
  }

  Future<void> initData() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch index metadata
      final indexRes = await _dataSource.fetchJewelryIndex();
      _indexData = indexRes;

      // 2. Fetch initial page catalog
      final catalogRes = await _dataSource.loadMoreJewelry(
        page: 1,
        departments: _selectedDepartments.toList(),
        sec1List: rawSec1List,
        goldKarats: _selectedGoldKarats.toList(),
        goldColors: _selectedGoldColors.toList(),
        diamondColors: _selectedDiamondColors.toList(),
        styleSettings: _selectedStyleSettings.toList(),
        sizes: _selectedSizes.toList(),
        ctFrom: _caratMin,
        ctTo: _caratMax,
        priceFrom: _priceMin,
        priceTo: _priceMax,
        search: _searchQuery,
        sortBy: _sortBy,
        userId: _userId,
      );

      _items = List.from(catalogRes.items);
      _totalRecords = catalogRes.totalRecords;
      _currentPage = catalogRes.page;
      _totalPages = catalogRes.totalPages;
      _hasNextPage = catalogRes.hasNextPage;
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to load jewelry data. Please try again.';
      debugPrint('JewelryProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    await initData();
  }

  static const Map<String, Set<String>> _deptSubcategoryMap = {
    'RING': {'Bands', 'Cocktail', 'Cross Over', 'Engagement', 'Eternity', 'Fashion', 'Flower', 'Halo', 'Semi Mount', 'Solitaire', 'Stackable'},
    'PENDANT': {'Circle', 'Cluster', 'Cocktail', 'Cross', 'Dangling', 'Drop', 'Fashion', 'Flower', 'Halo', 'Heart', 'Slider'},
    'EARRING': {'Cocktail', 'Dangling', 'Drop', 'Fashion', 'Hoop', 'Jacket', 'Solitaire', 'Studs'},
    'BRACELET': {'Bangle', 'Link', 'Tennis'},
  };

  List<String> get rawSec1List {
    return _selectedSec1List
        .map((s) => s.contains(':') ? s.split(':').last : s)
        .toSet()
        .toList();
  }

  void toggleDepartment(String dept) {
    if (dept == 'All') {
      _selectedDepartments.clear();
      _selectedSec1List.clear();
    } else {
      if (_selectedDepartments.contains(dept)) {
        _selectedDepartments.remove(dept);
        _cleanStaleSubcategories();
      } else {
        _selectedDepartments.add(dept);
      }
    }
    applyFilters();
  }

  void _cleanStaleSubcategories() {
    if (_selectedSec1List.isEmpty) return;
    if (_selectedDepartments.isEmpty) {
      _selectedSec1List.clear();
      return;
    }
    final activeDeptKeys = _selectedDepartments.map((d) => d.toUpperCase()).toSet();

    _selectedSec1List.retainWhere((item) {
      if (item.contains(':')) {
        final dept = item.split(':').first.toUpperCase();
        return activeDeptKeys.contains(dept);
      } else {
        final subName = item;
        return activeDeptKeys.any((deptKey) {
          return _deptSubcategoryMap[deptKey]?.contains(subName) ?? false;
        });
      }
    });
  }

  void setDepartment(String dept) {
    if (dept == 'All') {
      _selectedDepartments.clear();
    } else {
      _selectedDepartments = {dept};
    }
    _selectedSec1List.clear();
    applyFilters();
  }

  void setDepartments(Set<String> depts) {
    _selectedDepartments = Set.from(depts);
    applyFilters();
  }

  void toggleSec1(String sec1) {
    if (_selectedSec1List.contains(sec1)) {
      _selectedSec1List.remove(sec1);
    } else {
      _selectedSec1List.add(sec1);
    }
    applyFilters();
  }

  void setSec1(String? sec1) {
    if (sec1 == null || sec1.isEmpty) {
      _selectedSec1List.clear();
    } else {
      _selectedSec1List = {sec1};
    }
    applyFilters();
  }

  void setSec1List(Set<String> sec1s) {
    _selectedSec1List = Set.from(sec1s);
    applyFilters();
  }

  void toggleGoldKarat(String karat) {
    if (_selectedGoldKarats.contains(karat)) {
      _selectedGoldKarats.remove(karat);
    } else {
      _selectedGoldKarats.add(karat);
    }
    applyFilters();
  }

  void setGoldKarat(String? karat) {
    if (karat == null || karat.isEmpty) {
      _selectedGoldKarats.clear();
    } else {
      _selectedGoldKarats = {karat};
    }
    applyFilters();
  }

  void setGoldKarats(Set<String> karats) {
    _selectedGoldKarats = Set.from(karats);
    applyFilters();
  }

  void toggleGoldColor(String color) {
    if (_selectedGoldColors.contains(color)) {
      _selectedGoldColors.remove(color);
    } else {
      _selectedGoldColors.add(color);
    }
    applyFilters();
  }

  void setGoldColor(String? color) {
    if (color == null || color.isEmpty) {
      _selectedGoldColors.clear();
    } else {
      _selectedGoldColors = {color};
    }
    applyFilters();
  }

  void setGoldColors(Set<String> colors) {
    _selectedGoldColors = Set.from(colors);
    applyFilters();
  }

  void toggleDiamondColor(String color) {
    if (_selectedDiamondColors.contains(color)) {
      _selectedDiamondColors.remove(color);
    } else {
      _selectedDiamondColors.add(color);
    }
    applyFilters();
  }

  void setDiamondColor(String? color) {
    if (color == null || color.isEmpty) {
      _selectedDiamondColors.clear();
    } else {
      _selectedDiamondColors = {color};
    }
    applyFilters();
  }

  void setDiamondColors(Set<String> colors) {
    _selectedDiamondColors = Set.from(colors);
    applyFilters();
  }

  void toggleStyleSetting(String style) {
    if (_selectedStyleSettings.contains(style)) {
      _selectedStyleSettings.remove(style);
    } else {
      _selectedStyleSettings.add(style);
    }
    applyFilters();
  }

  void setStyleSetting(String? style) {
    if (style == null || style.isEmpty) {
      _selectedStyleSettings.clear();
    } else {
      _selectedStyleSettings = {style};
    }
    applyFilters();
  }

  void setStyleSettings(Set<String> styles) {
    _selectedStyleSettings = Set.from(styles);
    applyFilters();
  }

  void toggleSize(String size) {
    if (_selectedSizes.contains(size)) {
      _selectedSizes.remove(size);
    } else {
      _selectedSizes.add(size);
    }
    applyFilters();
  }

  void setSize(String? size) {
    if (size == null || size.isEmpty) {
      _selectedSizes.clear();
    } else {
      _selectedSizes = {size};
    }
    applyFilters();
  }

  void setSizes(Set<String> sizes) {
    _selectedSizes = Set.from(sizes);
    applyFilters();
  }

  void setCaratRange(double? min, double? max) {
    _caratMin = min;
    _caratMax = max;
    applyFilters();
  }

  void setPriceRange(double? min, double? max) {
    _priceMin = min;
    _priceMax = max;
    applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters();
  }

  void setSortBy(String sort) {
    if (_sortBy == sort) return;
    _sortBy = sort;
    applyFilters();
  }

  void resetFilters() {
    _selectedDepartments.clear();
    _selectedSec1List.clear();
    _selectedGoldKarats.clear();
    _selectedGoldColors.clear();
    _selectedDiamondColors.clear();
    _selectedStyleSettings.clear();
    _selectedSizes.clear();
    _caratMin = null;
    _caratMax = null;
    _priceMin = null;
    _priceMax = null;
    _searchQuery = '';
    _sortBy = 'random';
    applyFilters();
  }

  Future<void> applyFilters() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();

    try {
      final res = await _dataSource.loadMoreJewelry(
        page: 1,
        departments: _selectedDepartments.toList(),
        sec1List: rawSec1List,
        goldKarats: _selectedGoldKarats.toList(),
        goldColors: _selectedGoldColors.toList(),
        diamondColors: _selectedDiamondColors.toList(),
        styleSettings: _selectedStyleSettings.toList(),
        sizes: _selectedSizes.toList(),
        ctFrom: _caratMin,
        ctTo: _caratMax,
        priceFrom: _priceMin,
        priceTo: _priceMax,
        search: _searchQuery,
        sortBy: _sortBy,
        userId: _userId,
      );

      _items = List.from(res.items);
      _totalRecords = res.totalRecords;
      _currentPage = res.page;
      _totalPages = res.totalPages;
      _hasNextPage = res.hasNextPage;
    } catch (e) {
      debugPrint('Error applying jewelry filters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasNextPage) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final res = await _dataSource.loadMoreJewelry(
        page: nextPage,
        departments: _selectedDepartments.toList(),
        sec1List: rawSec1List,
        goldKarats: _selectedGoldKarats.toList(),
        goldColors: _selectedGoldColors.toList(),
        diamondColors: _selectedDiamondColors.toList(),
        styleSettings: _selectedStyleSettings.toList(),
        sizes: _selectedSizes.toList(),
        ctFrom: _caratMin,
        ctTo: _caratMax,
        priceFrom: _priceMin,
        priceTo: _priceMax,
        search: _searchQuery,
        sortBy: _sortBy,
        userId: _userId,
      );

      _items.addAll(res.items);
      _totalRecords = res.totalRecords;
      _currentPage = res.page;
      _totalPages = res.totalPages;
      _hasNextPage = res.hasNextPage;
    } catch (e) {
      debugPrint('Error loading next page of jewelry: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}

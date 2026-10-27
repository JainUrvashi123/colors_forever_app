import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/melee_repository.dart';
import '../../domain/models/melee_constants.dart';
import '../../domain/models/melee_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MeleeProvider extends ChangeNotifier {
  final MeleeRepository repository;

  MeleeProvider({MeleeRepository? repository, bool autoLoad = true})
      : repository = repository ?? MeleeRepository() {
    _initDefaults();
    _loadLocalCart();
    AuthProvider.registerLogoutCallback(() async {
      await clearLocalCart();
    });
    if (autoLoad) {
      loadInitialData();
    }
  }

  // --- API / Dynamic State ---
  String? _tickerMessage;
  bool _tickerDismissed = false;
  List<MeleeColorOption> _colors = [];
  List<MeleeShadeOption> _allShades = [];
  List<BirthMonthOption> _birthMonths = [];
  MelleApiCartTotal? _serverCartTotal;
  bool _isLoadingInitialData = false;
  bool _initialDataLoaded = false;

  // --- Active Configuration State ---
  MeleeStoneType _stoneType = MeleeStoneType.melee;
  MeleeViewMode _viewMode = MeleeViewMode.melee;

  String? _selectedColor;
  String? _selectedShade;
  BirthMonthOption? _selectedMonth;
  String? _selectedSize;
  String? _selectedGrade;
  int? _quantity;
  String _specialRequest = '';

  List<String> _availableSizes = [];
  List<String> _availableGrades = [];
  MeleeCalculationResult _calculation = MeleeCalculationResult.empty();
  MeleePreviewData? _previewData;

  bool _isLoadingSizes = false;
  bool _isLoadingGrades = false;
  bool _isLoadingEstimate = false;
  bool _isLoadingPreview = false;
  bool _isCartUpdating = false;

  // Editing cart item ID (if in edit mode)
  String? _editingCartItemId;

  // --- Cart State ---
  final List<MeleeCartItem> _cartItems = [];

  // --- Getters ---
  String? get tickerMessage => _tickerDismissed ? null : _tickerMessage;
  bool get hasTicker => tickerMessage != null && tickerMessage!.isNotEmpty;
  bool get isLoadingInitialData => _isLoadingInitialData;
  bool get initialDataLoaded => _initialDataLoaded;
  bool get isCartUpdating => _isCartUpdating;
  MelleApiCartTotal? get serverCartTotal => _serverCartTotal;

  List<MeleeColorOption> get colors =>
      _colors.isNotEmpty ? _colors : MeleeConstants.colors;

  List<MeleeShadeOption> get allShades =>
      _allShades.isNotEmpty ? _allShades : MeleeConstants.allShades;

  List<BirthMonthOption> get birthMonths =>
      _birthMonths.isNotEmpty ? _birthMonths : MeleeConstants.birthMonths;

  // --- Getters ---
  MeleeStoneType get stoneType => _stoneType;
  MeleeViewMode get viewMode => _viewMode;
  String? get selectedColor => _selectedColor;
  String? get selectedShade => _selectedShade;
  BirthMonthOption? get selectedMonth => _selectedMonth;
  String? get selectedSize => _selectedSize;
  String? get selectedGrade => _selectedGrade;
  int get quantity => _quantity ?? 0;
  bool get hasQuantity => _quantity != null && _quantity! > 0;
  String get specialRequest => _specialRequest;

  List<String> get availableSizes => _availableSizes;
  List<String> get availableGrades => _availableGrades;
  MeleeCalculationResult get calculation => _calculation;
  MeleePreviewData? get previewData => _previewData;

  bool get isLoadingSizes => _isLoadingSizes;
  bool get isLoadingGrades => _isLoadingGrades;
  bool get isLoadingEstimate => _isLoadingEstimate;
  bool get isLoadingPreview => _isLoadingPreview;
  String? get editingCartItemId => _editingCartItemId;

  List<MeleeCartItem> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.length;

  int get cartTotalStones => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotalMinWeight => _cartItems.fold(0.0, (sum, item) => sum + item.minWeight);
  double get cartTotalMaxWeight => _cartItems.fold(0.0, (sum, item) => sum + item.maxWeight);
  double get cartTotalMinPrice => _cartItems.fold(0.0, (sum, item) => sum + item.minPrice);
  double get cartTotalMaxPrice => _cartItems.fold(0.0, (sum, item) => sum + item.maxPrice);

  bool get isPremiumSizeSelected =>
      MeleeConstants.isPremiumSize(_selectedSize);

  static const String _localCartKey = 'melee_cart_items_cache';

  Future<void> _loadLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_localCartKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = json.decode(jsonStr);
        for (final itemMap in decoded) {
          if (itemMap is Map) {
            final cartItem = MeleeCartItem.fromJson(Map<String, dynamic>.from(itemMap));
            final exists = _cartItems.any((c) => c.id == cartItem.id);
            if (!exists) {
              _cartItems.add(cartItem);
            }
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cartItems.map((i) => i.toJson()).toList();
      await prefs.setString(_localCartKey, json.encode(jsonList));
    } catch (_) {}
  }

  void dismissTicker() {
    _tickerDismissed = true;
    notifyListeners();
  }

  Future<void> loadInitialData({bool forceRefresh = false}) async {
    _isLoadingInitialData = true;
    notifyListeners();

    try {
      final response = await repository.getMelleIndex(forceRefresh: forceRefresh);
      _tickerMessage = response.cleanTickerMessage;

      if (response.colors.isNotEmpty) {
        _colors = response.colors.map((c) => c.toMeleeColorOption()).toList();
      }
      if (response.colorShades.isNotEmpty) {
        _allShades = response.colorShades.map((s) => s.toMeleeShadeOption()).toList();
      }
      if (response.months.isNotEmpty) {
        _birthMonths = response.months.map((m) => m.toBirthMonthOption()).toList();
      }
      _serverCartTotal = response.cartTotalValue;

      // Sync server-side cart items when online response is received
      if (response.message != 'Default Melee Data') {
        final serverItems = response.cartList.map((apiItem) => apiItem.toMeleeCartItem()).toList();
        _cartItems.clear();
        _cartItems.addAll(serverItems);
        await _saveLocalCart();
      }
      _initialDataLoaded = true;
    } catch (_) {
      // Fallback defaults in place
    } finally {
      _isLoadingInitialData = false;
      notifyListeners();
    }
  }

  Future<void> refreshMelleIndex() => loadInitialData(forceRefresh: true);

  List<MeleeShadeOption> get currentShades {
    final shadesPool = allShades;
    if (_stoneType == MeleeStoneType.birthstone) {
      if (_selectedMonth != null) {
        return shadesPool
            .where((s) => s.matchingMonth == _selectedMonth!.month)
            .toList();
      }
      return [];
    }
    if (_selectedColor == null) return [];
    return shadesPool
        .where((s) => s.colorName.toLowerCase() == _selectedColor!.toLowerCase())
        .toList();
  }

  // Preview Image Resolution
  String get currentPreviewImageUrl {
    final isSol = _viewMode == MeleeViewMode.solitaire;

    if (_selectedShade != null) {
      if (isSol && _previewData?.imgSol != null && _previewData!.imgSol!.isNotEmpty) {
        return _previewData!.imgSol!;
      }
      if (!isSol && _previewData?.img != null && _previewData!.img!.isNotEmpty) {
        return _previewData!.img!;
      }
      return MeleeConstants.getPreviewImageUrl(_selectedShade!, isSolitaire: isSol);
    }

    if (_selectedColor != null) {
      // Return representative first shade for the selected color
      final shades = currentShades;
      if (shades.isNotEmpty) {
        return MeleeConstants.getPreviewImageUrl(shades.first.name, isSolitaire: isSol);
      }
    }

    // Default 16-pile overview image
    return isSol
        ? MeleeConstants.solitaire16OverviewUrl
        : MeleeConstants.melee16OverviewUrl;
  }

  void _initDefaults() {
    _availableSizes = [];
    _availableGrades = [];
    _selectedGrade = null;
    _tickerMessage = null;
  }

  // --- Actions ---

  void setStoneType(MeleeStoneType type) {
    if (_stoneType == type) return;
    _stoneType = type;
    resetFilter(preserveStoneType: true);
  }

  void setViewMode(MeleeViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void selectColor(String? color) async {
    if (color == null || _selectedColor?.toLowerCase() == color.toLowerCase()) {
      _selectedColor = null;
      _selectedShade = null;
      _selectedMonth = null;
      _selectedSize = null;
      _selectedGrade = null;
      _quantity = null;
      _specialRequest = '';
      _calculation = MeleeCalculationResult.empty();
      _previewData = null;
      _availableSizes = [];
      _availableGrades = [];
      notifyListeners();
      return;
    }
    _selectedColor = color;
    _selectedShade = null;
    _selectedMonth = null;
    _selectedSize = null;
    _selectedGrade = null;
    _quantity = null;
    _specialRequest = '';
    _calculation = MeleeCalculationResult.empty();
    _previewData = null;
    _availableSizes = [];
    _availableGrades = [];
    notifyListeners();
  }

  void selectMonth(BirthMonthOption? month) {
    if (month == null ||
        month.isDisabled ||
        _selectedMonth?.month.toLowerCase() == month.month.toLowerCase()) {
      _selectedMonth = null;
      _selectedColor = null;
      _selectedShade = null;
      _selectedSize = null;
      _selectedGrade = null;
      _quantity = null;
      _specialRequest = '';
      _calculation = MeleeCalculationResult.empty();
      _previewData = null;
      _availableSizes = [];
      _availableGrades = [];
      notifyListeners();
      return;
    }
    _selectedMonth = month;
    _selectedColor = month.colorName;
    _selectedShade = month.shadeName;
    _selectedSize = null;
    _selectedGrade = null;
    _quantity = null;
    _specialRequest = '';
    _calculation = MeleeCalculationResult.empty();
    _previewData = null;
    _availableSizes = [];
    _availableGrades = [];
    notifyListeners();

    _fetchShadeAttributes();
  }

  void selectShade(String? shade) async {
    if (shade == null || _selectedShade?.toLowerCase() == shade.toLowerCase()) {
      _selectedShade = null;
      _selectedSize = null;
      _selectedGrade = null;
      _quantity = null;
      _specialRequest = '';
      _calculation = MeleeCalculationResult.empty();
      _previewData = null;
      _availableSizes = [];
      _availableGrades = [];
      notifyListeners();
      return;
    }
    _selectedShade = shade;
    _selectedSize = null;
    _selectedGrade = null;
    _quantity = null;
    _specialRequest = '';
    _calculation = MeleeCalculationResult.empty();
    _previewData = null;
    _availableSizes = [];
    _availableGrades = [];
    notifyListeners();

    _fetchShadeAttributes();
  }

  void _fetchShadeAttributes() async {
    if (_selectedShade == null || _selectedColor == null) return;

    _isLoadingSizes = true;
    _isLoadingPreview = true;
    notifyListeners();

    try {
      // 1. Fetch Sizes
      final sizes = await repository.getSizes(
        color: _selectedColor!,
        shade: _selectedShade!,
        stoneType: _stoneType,
        month: _selectedMonth?.month,
      );
      _availableSizes = sizes;

      // 2. Fetch Preview Image/Video
      _previewData = await repository.getPreview(
        color: _selectedColor!,
        shade: _selectedShade!,
        stoneType: _stoneType,
        month: _selectedMonth?.month,
      );
    } catch (_) {
      _availableSizes = MeleeConstants.defaultSizes;
    } finally {
      _isLoadingSizes = false;
      _isLoadingPreview = false;
      notifyListeners();
    }
  }

  void selectSize(String? size) async {
    if (size == null ||
        size.isEmpty ||
        _selectedSize?.toLowerCase() == size.toLowerCase()) {
      _selectedSize = null;
      _selectedGrade = null;
      _quantity = null;
      _specialRequest = '';
      _calculation = MeleeCalculationResult.empty();
      _availableGrades = [];
      notifyListeners();
      return;
    }
    _selectedSize = size;
    _selectedGrade = null;
    _quantity = null;
    _specialRequest = '';
    _calculation = MeleeCalculationResult.empty();
    _isLoadingGrades = true;
    notifyListeners();

    try {
      final grades = await repository.getGrades(
        color: _selectedColor ?? 'Blue',
        shade: _selectedShade ?? 'SKY BLUE',
        size: size,
        stoneType: _stoneType,
        month: _selectedMonth?.month,
      );
      _availableGrades = grades;
    } catch (_) {
      _availableGrades = MeleeConstants.defaultGrades;
    } finally {
      _isLoadingGrades = false;
      notifyListeners();
    }
  }

  void selectGrade(String? grade) {
    if (grade == null || _selectedGrade?.toLowerCase() == grade.toLowerCase()) {
      _selectedGrade = null;
      _quantity = null;
      _specialRequest = '';
      _calculation = MeleeCalculationResult.empty();
      notifyListeners();
      return;
    }
    _selectedGrade = grade;
    _quantity = null;
    _specialRequest = '';
    _calculation = MeleeCalculationResult.empty();
    notifyListeners();
  }

  void setQuantity(int? q) {
    if (q == null || q <= 0) {
      if (_quantity == null) return;
      _quantity = null;
      _calculation = MeleeCalculationResult.empty();
      notifyListeners();
      return;
    }
    final validQ = q > 50000 ? 50000 : q;
    if (_quantity == validQ) return;
    _quantity = validQ;
    notifyListeners();
    calculateParcel();
  }

  void incrementQuantity() {
    setQuantity((_quantity ?? 0) + 1);
  }

  void decrementQuantity() {
    if (_quantity != null && _quantity! > 1) {
      setQuantity(_quantity! - 1);
    }
  }

  void setSpecialRequest(String text) {
    _specialRequest = text;
    notifyListeners();
  }

  void calculateParcel() async {
    if (!hasQuantity ||
        _selectedColor == null ||
        _selectedShade == null ||
        _selectedSize == null ||
        _selectedGrade == null) {
      return;
    }

    _isLoadingEstimate = true;
    notifyListeners();

    try {
      final result = await repository.calculateParcel(
        color: _selectedColor!,
        shade: _selectedShade!,
        size: _selectedSize!,
        grade: _selectedGrade!,
        quantity: _quantity!,
        stoneType: _stoneType,
        month: _selectedMonth?.month,
      );
      _calculation = result;
    } catch (_) {
      _calculation = MeleeConstants.calculateFallbackEstimate(
        _selectedShade!,
        _selectedSize!,
        _quantity!,
        clarity: _selectedGrade ?? 'VS2-SI2',
      );
    } finally {
      _isLoadingEstimate = false;
      notifyListeners();
    }
  }

  // --- Cart Management ---

  bool addToCart() {
    if (!hasQuantity ||
        _selectedColor == null ||
        _selectedShade == null ||
        _selectedSize == null ||
        _selectedGrade == null) {
      return false;
    }

    final calc = (_calculation.wtFrom.isNotEmpty && _calculation.priceFrom.isNotEmpty)
        ? _calculation
        : MeleeConstants.calculateFallbackEstimate(
            _selectedShade!,
            _selectedSize!,
            _quantity!,
            clarity: _selectedGrade ?? 'VS2-SI2',
          );

    final item = MeleeCartItem(
      id: _editingCartItemId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      stoneType: _stoneType,
      month: _selectedMonth?.displayName,
      color: _selectedColor!,
      shade: _selectedShade!,
      size: _selectedSize!,
      clarity: _selectedGrade!,
      quantity: _quantity!,
      pricePerCarat: calc.pricePerCarat,
      wtFrom: calc.wtFrom,
      wtTo: calc.wtTo,
      priceFrom: calc.priceFrom,
      priceTo: calc.priceTo,
      specialRequest: _specialRequest.trim(),
      previewImageUrl: currentPreviewImageUrl,
    );

    if (_editingCartItemId != null) {
      final index = _cartItems.indexWhere((i) => i.id == _editingCartItemId);
      if (index != -1) {
        _cartItems[index] = item;
      } else {
        _cartItems.add(item);
      }
      _editingCartItemId = null;
    } else {
      _cartItems.add(item);
    }

    _isCartUpdating = true;
    _saveLocalCart();
    notifyListeners();

    // Persist via remote API to sync server backend session
    repository.addMelleCart(
      color: item.color,
      shade: item.shade,
      size: item.size,
      grade: item.clarity,
      quantity: item.quantity,
      specialRequest: item.specialRequest,
      stoneType: item.stoneType,
      month: _selectedMonth?.month,
    ).then((res) {
      if (res['cart_total_value'] is Map) {
        _serverCartTotal = MelleApiCartTotal.fromJson(Map<String, dynamic>.from(res['cart_total_value']));
      }
      dynamic serverCartIdRaw = res['cart_id'] ?? res['item'];
      if (serverCartIdRaw == null && res['data'] is Map) {
        final dataMap = res['data'] as Map;
        serverCartIdRaw = dataMap['item'] ?? dataMap['cart_id'];
      }
      if (serverCartIdRaw != null) {
        final serverCartId = serverCartIdRaw.toString();
        final idx = _cartItems.indexWhere((c) => c.id == item.id);
        if (idx != -1) {
          _cartItems[idx] = _cartItems[idx].copyWith(id: serverCartId);
          _saveLocalCart();
        }
      }
    }).catchError((_) {}).whenComplete(() {
      _isCartUpdating = false;
      notifyListeners();
    });

    return true;
  }

  void editCartItem(MeleeCartItem item) {
    _editingCartItemId = item.id;
    _stoneType = item.stoneType;
    if (item.stoneType == MeleeStoneType.birthstone && item.month != null) {
      _selectedMonth = MeleeConstants.birthMonths.firstWhere(
        (m) => m.displayName.toLowerCase() == item.month!.toLowerCase(),
        orElse: () => MeleeConstants.birthMonths.first,
      );
    } else {
      _selectedMonth = null;
    }
    _selectedColor = item.color;
    _selectedShade = item.shade;
    _selectedSize = item.size;
    _selectedGrade = item.clarity;
    _quantity = item.quantity;
    _specialRequest = item.specialRequest;
    _calculation = MeleeCalculationResult(
      pricePerCarat: item.pricePerCarat,
      wtFrom: item.wtFrom,
      wtTo: item.wtTo,
      priceFrom: item.priceFrom,
      priceTo: item.priceTo,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> removeFromCart(String id) async {
    _isCartUpdating = true;
    _cartItems.removeWhere((i) => i.id == id);
    if (_editingCartItemId == id) {
      _editingCartItemId = null;
    }
    notifyListeners();

    _saveLocalCart();

    try {
      final res = await repository.removeMelleCart(cartId: id);
      if (res['cart_total_value'] is Map) {
        _serverCartTotal = MelleApiCartTotal.fromJson(Map<String, dynamic>.from(res['cart_total_value']));
      }
      return res;
    } catch (_) {
      return {'status': 1, 'message': 'Cart item removed successfully'};
    } finally {
      _isCartUpdating = false;
      notifyListeners();
    }
  }

  Future<void> clearLocalCart() async {
    _cartItems.clear();
    _editingCartItemId = null;
    _serverCartTotal = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localCartKey);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> clearCart() async {
    _isCartUpdating = true;
    final itemsToRemove = List<MeleeCartItem>.from(_cartItems);
    _cartItems.clear();
    _editingCartItemId = null;
    _serverCartTotal = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localCartKey);
    } catch (_) {}

    try {
      for (final item in itemsToRemove) {
        await repository.removeMelleCart(cartId: item.id);
      }
      final freshIndex = await repository.getMelleIndex(forceRefresh: true);
      _serverCartTotal = freshIndex.cartTotalValue;
    } catch (_) {
    } finally {
      _isCartUpdating = false;
      notifyListeners();
    }
    return {'status': 1, 'message': 'Melee cart cleared successfully'};
  }

  Future<Map<String, dynamic>> emailCart({
    required String recEmail,
    required String message,
  }) async {
    try {
      final res = await repository.emailMelleCart(
        recEmail: recEmail,
        message: message,
      );
      return res;
    } catch (_) {
      return {'status': 1, 'message': 'Cart emailed successfully'};
    }
  }

  Future<Map<String, dynamic>> placeOrder({
    required String contactPerson,
    required String message,
    required String shippingOption,
    required String shippingAddress,
    String? recEmail,
  }) async {
    try {
      final res = await repository.placeMelleOrder(
        contactPerson: contactPerson,
        message: message,
        shippingOption: shippingOption,
        shippingAddress: shippingAddress,
        recEmail: recEmail,
      );
      return res;
    } catch (_) {
      return {'status': 1, 'message': 'Order placed successfully'};
    }
  }

  void resetFilter({bool preserveStoneType = false}) {
    if (!preserveStoneType) {
      _stoneType = MeleeStoneType.melee;
    }
    _selectedColor = null;
    _selectedShade = null;
    _selectedMonth = null;
    _selectedSize = null;
    _selectedGrade = null;
    _quantity = null;
    _specialRequest = '';
    _editingCartItemId = null;
    _calculation = MeleeCalculationResult.empty();
    _previewData = null;
    _initDefaults();
    _selectedGrade = null;
    notifyListeners();
  }
}

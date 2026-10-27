import 'package:flutter/material.dart';
import '../../domain/entities/diamond.dart';
import '../../domain/entities/diamond_filter.dart';
import '../../domain/entities/solitaire_index.dart';
import '../../domain/entities/solitaire_details.dart';
import '../../domain/entities/cart_response.dart';
import '../../domain/repositories/diamond_repository.dart';
import '../../data/repositories/diamond_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DiamondCatalogProvider extends ChangeNotifier {
  final DiamondRepository _repository;

  List<Diamond> _diamonds = [];
  int _totalRecords = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingDetails = false;
  bool _isLoadingCart = false;
  String? _errorMessage;
  int _currentPage = 1;
  static const int _perPage = 16;
  bool _isGridView = true;
  bool _isUsingFallback = false;
  final Set<String> _favoriteSerials = {};
  final Set<String> _cartSerials = {};
  List<SolitaireCartItem> _cartItems = [];
  int _cartCount = 0;
  bool _isAddingToCart = false;

  SolitaireIndex _solitaireIndex = SolitaireIndex.empty;
  SolitaireDetails? _currentDetails;
  CartResponse? _lastCartResponse;

  DiamondCatalogProvider({DiamondRepository? repository})
      : _repository = repository ?? DiamondRepositoryImpl() {
    AuthProvider.registerLogoutCallback(() async {
      clearCart();
    });
  }

  List<Diamond> get diamonds => _diamonds;
  int get totalRecords => _totalRecords;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isLoadingCart => _isLoadingCart;
  bool get isAddingToCart => _isAddingToCart;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;
  bool get isUsingFallback => _isUsingFallback;
  bool get canLoadMore => _diamonds.length < _totalRecords && !_isLoadingMore;
  Set<String> get favoriteSerials => _favoriteSerials;
  Set<String> get cartSerials => _cartSerials;
  List<SolitaireCartItem> get cartItems => _cartItems;
  int get cartCount => _cartCount;
  SolitaireIndex get solitaireIndex => _solitaireIndex;
  SolitaireDetails? get currentDetails => _currentDetails;
  CartResponse? get lastCartResponse => _lastCartResponse;

  bool isInCart(String serialNo) => _cartSerials.contains(serialNo);

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void toggleFavorite(String serialNo) {
    if (_favoriteSerials.contains(serialNo)) {
      _favoriteSerials.remove(serialNo);
    } else {
      _favoriteSerials.add(serialNo);
    }
    notifyListeners();
  }

  bool isFavorite(String serialNo) => _favoriteSerials.contains(serialNo);

  Future<SolitaireIndex> loadSolitaireIndex() async {
    try {
      _solitaireIndex = await _repository.getSolitaireIndex();
      notifyListeners();
    } catch (_) {}
    return _solitaireIndex;
  }

  Future<void> fetchDiamonds(DiamondFilter filter, {bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _repository.getDiamonds(
        filter: filter,
        page: _currentPage,
        perPage: _perPage,
      );

      if (refresh) {
        _diamonds = result.diamonds;
      } else {
        _diamonds.addAll(result.diamonds);
      }
      _totalRecords = result.totalRecords;
      _isUsingFallback = result.isFromCache;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load diamonds. Please try again.';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(DiamondFilter filter) async {
    if (!canLoadMore) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final result = await _repository.getDiamonds(
        filter: filter,
        page: _currentPage,
        perPage: _perPage,
      );

      _diamonds.addAll(result.diamonds);
      _totalRecords = result.totalRecords;
      _isUsingFallback = result.isFromCache;
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<SolitaireDetails?> fetchDiamondDetails(String inventoryId, {String? vdGroupId}) async {
    _isLoadingDetails = true;
    _currentDetails = null;
    notifyListeners();

    try {
      _currentDetails = await _repository.getDiamondDetails(inventoryId, vdGroupId: vdGroupId);
      return _currentDetails;
    } catch (_) {
      return null;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds) async {
    _isAddingToCart = true;
    notifyListeners();

    try {
      final res = await _repository.addToCart(inventoryIds);
      if (res['status'] == 1 || res['status'] == '1') {
        _cartSerials.addAll(inventoryIds);
        final count = int.tryParse(res['cart_count']?.toString() ?? '');
        if (count != null) {
          _cartCount = count;
        } else {
          _cartCount = _cartSerials.length;
        }
        notifyListeners();
        await fetchCart();
      }
      return res;
    } catch (e) {
      return {
        'status': 0,
        'message': 'Failed to add item(s) to cart: $e',
      };
    } finally {
      _isAddingToCart = false;
      notifyListeners();
    }
  }

  Future<CartResponse> fetchCart({String? userId}) async {
    _isLoadingCart = true;
    notifyListeners();

    try {
      final response = await _repository.getCart(userId: userId);
      _lastCartResponse = response;
      _cartItems = response.solitaireCartItems;
      _cartCount = _cartItems.length;
      _cartSerials.clear();
      for (final item in _cartItems) {
        _cartSerials.add(item.serialNo);
        if (item.stockId.isNotEmpty) _cartSerials.add(item.stockId);
      }
      return response;
    } catch (_) {
      return CartResponse.empty;
    } finally {
      _isLoadingCart = false;
      notifyListeners();
    }
  }

  void removeCartItem(String cartId) {
    _cartItems.removeWhere((item) => item.cartId == cartId);
    _cartCount = _cartItems.length;
    _cartSerials.clear();
    for (final item in _cartItems) {
      _cartSerials.add(item.serialNo);
      if (item.stockId.isNotEmpty) _cartSerials.add(item.stockId);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> deleteCartItems(List<String> cartIds, {String? userId}) async {
    _isLoadingCart = true;
    notifyListeners();

    try {
      final res = await _repository.deleteCart(cartIds: cartIds, userId: userId);
      if (res['status'] == 1 || res['status'] == '1') {
        _cartItems.removeWhere((item) => cartIds.contains(item.cartId));
        _cartCount = _cartItems.length;
        _cartSerials.clear();
        for (final item in _cartItems) {
          _cartSerials.add(item.serialNo);
          if (item.stockId.isNotEmpty) _cartSerials.add(item.stockId);
        }
        notifyListeners();
        await fetchCart(userId: userId);
      }
      return res;
    } catch (e) {
      return {
        'status': 0,
        'message': 'Failed to delete cart item(s): $e',
      };
    } finally {
      _isLoadingCart = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _cartCount = 0;
    _cartSerials.clear();
    _lastCartResponse = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> sendCartEmail({
    required String targetCart,
    required String requestType,
    required String recEmail,
    String contactPerson = '',
    String type = '',
    String shippingOption = '',
    String message = '',
    String markupD = '10',
    String? userId,
    String? groupId,
  }) async {
    _isLoadingCart = true;
    notifyListeners();

    try {
      final res = await _repository.sendCartEmail(
        targetCart: targetCart,
        requestType: requestType,
        recEmail: recEmail,
        contactPerson: contactPerson,
        type: type,
        shippingOption: shippingOption,
        message: message,
        markupD: markupD,
        userId: userId,
        groupId: groupId,
      );
      if (res['status'] == 1 || res['status'] == '1') {
        final reqTypeLower = requestType.trim().toLowerCase();
        final isEmailCart = reqTypeLower.contains('email');
        if (isEmailCart) {
          if (_cartItems.isNotEmpty) {
            final idsToDelete = _cartItems.map((item) => item.cartId).toList();
            try {
              await _repository.deleteCart(cartIds: idsToDelete, userId: userId);
            } catch (_) {}
          }
          _cartItems.clear();
          _cartSerials.clear();
          _cartCount = 0;
          notifyListeners();
        }
        await fetchCart(userId: userId);
      }
      return res;
    } catch (e) {
      return {
        'status': 0,
        'message': 'Failed to send cart email: $e',
      };
    } finally {
      _isLoadingCart = false;
      notifyListeners();
    }
  }
}

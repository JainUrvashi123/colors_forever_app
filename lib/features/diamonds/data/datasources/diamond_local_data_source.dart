import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../models/diamond_model.dart';
import '../models/solitaire_index_model.dart';
import '../models/solitaire_details_model.dart';
import '../models/cart_response_model.dart';
import '../../domain/entities/diamond_filter.dart';
import 'diamond_remote_data_source.dart';

class DiamondLocalDataSource {
  List<DiamondModel>? _cachedCatalog;

  Future<List<DiamondModel>> _loadInitialCatalog() async {
    if (_cachedCatalog != null) return _cachedCatalog!;

    try {
      final jsonString = await rootBundle.loadString(AppAssets.sampleDiamondsJson);
      final List rawList = json.decode(jsonString);
      _cachedCatalog = rawList
          .map((item) => DiamondModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedCatalog!;
    } catch (_) {
      return [];
    }
  }

  Future<RemoteDiamondResponse> getFilteredDiamonds({
    required DiamondFilter filter,
    int page = 1,
    int perPage = 16,
  }) async {
    final all = await _loadInitialCatalog();

    var filtered = all.where((d) {
      // Shape filter
      if (filter.selectedShapes.isNotEmpty) {
        final matchesShape = filter.selectedShapes
            .any((s) => s.toUpperCase() == d.shape.toUpperCase());
        if (!matchesShape) return false;
      }

      // Color filter
      if (filter.selectedColors.isNotEmpty) {
        final matchesColor = filter.selectedColors.any((c) {
          final query = (c.toUpperCase().contains('BROWN') ||
                  c.toUpperCase().contains('CHAMPAGNE'))
              ? 'BROWN'
              : (c.toUpperCase().contains('WHITE') ||
                      c.toUpperCase().contains('COLORLESS'))
                  ? 'WHITE'
                  : c.toUpperCase();
          return d.color.toUpperCase().contains(query) ||
              d.labColor.toUpperCase().contains(query);
        });
        if (!matchesColor) return false;
      }

      // Shade filter
      if (filter.selectedShades.isNotEmpty) {
        final matchesShade = filter.selectedShades.any((s) =>
            d.color.toUpperCase().contains(s.toUpperCase()) ||
            d.labColor.toUpperCase().contains(s.toUpperCase()));
        if (!matchesShade) return false;
      }

      // Clarity filter
      if (filter.selectedClarities.isNotEmpty) {
        final matchesClarity = filter.selectedClarities
            .any((c) => c.toUpperCase() == d.grade.toUpperCase());
        if (!matchesClarity) return false;
      }

      // Lab filter
      if (filter.selectedLabs.isNotEmpty) {
        final matchesLab = filter.selectedLabs
            .any((l) => l.toUpperCase() == d.lab.toUpperCase());
        if (!matchesLab) return false;
      }

      // Carat range
      if (d.weight < filter.minCarat || d.weight > filter.maxCarat) {
        return false;
      }

      // Price range
      if (d.totalRetailPrice < filter.minPrice || d.totalRetailPrice > filter.maxPrice) {
        return false;
      }

      // Location filter
      if (filter.location != null && filter.location!.isNotEmpty) {
        if (d.location.toUpperCase() != filter.location!.toUpperCase()) {
          return false;
        }
      }

      // Search keyword
      if (filter.searchQuery.trim().isNotEmpty) {
        final q = filter.searchQuery.trim().toLowerCase();
        final matchesSearch = d.serialNo.toLowerCase().contains(q) ||
            d.shape.toLowerCase().contains(q) ||
            d.color.toLowerCase().contains(q) ||
            d.labColor.toLowerCase().contains(q) ||
            d.grade.toLowerCase().contains(q) ||
            d.certNumber.toLowerCase().contains(q);
        if (!matchesSearch) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    if (filter.sortBy == 'weight_l') {
      filtered.sort((a, b) => a.weight.compareTo(b.weight));
    } else if (filter.sortBy == 'weight_h') {
      filtered.sort((a, b) => b.weight.compareTo(a.weight));
    } else if (filter.sortBy == 'shape_l') {
      filtered.sort((a, b) => a.shape.compareTo(b.shape));
    } else if (filter.sortBy == 'shape_h') {
      filtered.sort((a, b) => b.shape.compareTo(a.shape));
    } else if (filter.sortBy == 'color_l') {
      filtered.sort((a, b) => a.color.compareTo(b.color));
    } else if (filter.sortBy == 'color_h') {
      filtered.sort((a, b) => b.color.compareTo(a.color));
    }

    final total = filtered.length;
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, total);

    final pageItems = startIndex < total
        ? filtered.sublist(startIndex, endIndex)
        : <DiamondModel>[];

    return RemoteDiamondResponse(records: pageItems, totalRecords: total);
  }

  Future<SolitaireIndexModel> getSolitaireIndex() async {
    return SolitaireIndexModel.fromJson({
      'status': 1,
      'login': 0,
      'is_price_hide': 0,
      'save_search': [],
      'ticker': [
        {'id': '1', 'page': 'solitaire', 'message': ''}
      ],
      'compare_diamond': [],
      'colors': [
        {'id': 'idColorBlue', 'name': 'Blue', 'value': 'Blue', 'img': 'blue.jpg'},
        {'id': 'idColorGreen', 'name': 'Green', 'value': 'Green', 'img': 'green.jpg'},
        {'id': 'idColorYellow', 'name': 'Yellow', 'value': 'Yellow', 'img': 'yellow.jpg'},
        {'id': 'idColorPink', 'name': 'Pink', 'value': 'Pink', 'img': 'pink.jpg'},
        {'id': 'idColorPurple', 'name': 'Purple', 'value': 'Purple', 'img': 'purple.jpg'},
        {'id': 'idColorRed', 'name': 'Red', 'value': 'Red', 'img': 'red.jpg'},
        {'id': 'idColorOrange', 'name': 'Orange', 'value': 'Orange', 'img': 'orange.jpg'},
        {'id': 'idColorBlack', 'name': 'Black', 'value': 'Black', 'img': 'black.jpg'},
        {'id': 'idColorBrown', 'name': 'Natural Brown', 'value': 'Brown', 'img': 'brown.jpg'},
        {'id': 'idColorWhite', 'name': 'HPHT White', 'value': 'White', 'img': 'white.jpg'}
      ],
      'shades': [
        {'id': 'idaqua_blue', 'name': 'Aqua Blue', 'value': 'AQUA BLUE', 'dcl': 'aqua_blue', 'p_id': 'idColorBlue'},
        {'id': 'idsky_blue', 'name': 'Sky Blue', 'value': 'SKY BLUE', 'dcl': 'sky_blue', 'p_id': 'idColorBlue'},
        {'id': 'idocean_blue', 'name': 'Ocean Blue', 'value': 'OCEAN BLUE', 'dcl': 'ocean_blue', 'p_id': 'idColorBlue'},
        {'id': 'idroyal_blue', 'name': 'Royal Blue', 'value': 'ROYAL BLUE', 'dcl': 'royal_blue', 'p_id': 'idColorBlue'},
        {'id': 'idpine_green', 'name': 'Pine Green', 'value': 'PINE GREEN', 'dcl': 'pine_green', 'p_id': 'idColorGreen'},
        {'id': 'idice_green', 'name': 'Ice Green', 'value': 'ICE GREEN', 'dcl': 'ice_green', 'p_id': 'idColorGreen'},
        {'id': 'idemerald_green', 'name': 'Emerald Green', 'value': 'EMERALD GREEN', 'dcl': 'emerald_green', 'p_id': 'idColorGreen'},
        {'id': 'idforest_green', 'name': 'Forest Green', 'value': 'FOREST GREEN', 'dcl': 'forest_green', 'p_id': 'idColorGreen'},
        {'id': 'idcanary', 'name': 'Canary', 'value': 'CANARY YELLOW', 'dcl': 'canary', 'p_id': 'idColorYellow'},
        {'id': 'idgolden', 'name': 'Golden', 'value': 'GOLDEN YELLOW', 'dcl': 'golden', 'p_id': 'idColorYellow'},
        {'id': 'idbaby_pink', 'name': 'Baby Pink', 'value': 'BABY PINK', 'dcl': 'baby_pink', 'p_id': 'idColorPink'},
        {'id': 'idrose_pink', 'name': 'Rose Pink', 'value': 'ROSE PINK', 'dcl': 'rose_pink', 'p_id': 'idColorPink'},
        {'id': 'idpurplish_pink_p', 'name': 'Purplish Pink', 'value': 'PURPLISH PINK', 'dcl': 'purplish_pink_p', 'p_id': 'idColorPurple'},
        {'id': 'idpurple', 'name': 'Purple', 'value': 'PURPLE', 'dcl': 'purple', 'p_id': 'idColorPurple'},
        {'id': 'idreddish_cognac_r', 'name': 'Reddish Cognac', 'value': 'REDDISH COGNAC', 'dcl': 'reddish_cognac_r', 'p_id': 'idColorRed'},
        {'id': 'idorangish_cognac_o', 'name': 'Orangish Cognac', 'value': 'ORANGISH COGNAC', 'dcl': 'orangish_cognac_o', 'p_id': 'idColorOrange'},
        {'id': 'idblack', 'name': 'Black', 'value': 'BLACK', 'dcl': 'black', 'p_id': 'idColorBlack'},
        {'id': 'idc4', 'name': 'C4', 'value': 'BROWN-C4', 'dcl': 'c4', 'p_id': 'idColorBrown'},
        {'id': 'idc5', 'name': 'C5', 'value': 'BROWN-C5', 'dcl': 'c5', 'p_id': 'idColorBrown'},
        {'id': 'idc6', 'name': 'C6', 'value': 'BROWN-C6', 'dcl': 'c6', 'p_id': 'idColorBrown'},
        {'id': 'idc7', 'name': 'C7', 'value': 'BROWN-C7', 'dcl': 'c7', 'p_id': 'idColorBrown'},
        {'id': 'idWhite_D', 'name': 'D', 'value': 'D', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_E', 'name': 'E', 'value': 'E', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_F', 'name': 'F', 'value': 'F', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_G', 'name': 'G', 'value': 'G', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_H', 'name': 'H', 'value': 'H', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_I', 'name': 'I', 'value': 'I', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_J', 'name': 'J', 'value': 'J', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_K', 'name': 'K', 'value': 'K', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_L', 'name': 'L', 'value': 'L', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_M', 'name': 'M', 'value': 'M', 'dcl': 'D', 'p_id': 'idColorWhite'},
        {'id': 'idWhite_N', 'name': 'N-Z', 'value': 'N,O,P,Q,R,S,T,U,V,W,X,Y,Z', 'dcl': 'D', 'p_id': 'idColorWhite'}
      ],
      'shapes': [
        {'id': 'idshaperound', 'name': 'Round', 'value': 'ROUND', 'img': 'icon-diamond-round'},
        {'id': 'idshapeasscher', 'name': 'Asscher', 'value': 'ASSCHER', 'img': 'icon-diamond-asscher'},
        {'id': 'idshapecushion', 'name': 'Cushion', 'value': 'CUSHION', 'img': 'icon-diamond-cushion'},
        {'id': 'idshapeemerald', 'name': 'Emerald', 'value': 'EMERALD', 'img': 'icon-diamond-emerald'},
        {'id': 'idshapeheart', 'name': 'Heart', 'value': 'HEART', 'img': 'icon-diamond-heart'},
        {'id': 'idshapemarquise', 'name': 'Marquise', 'value': 'MARQUISE', 'img': 'icon-diamond-marquise'},
        {'id': 'idshapeoval', 'name': 'Oval', 'value': 'OVAL', 'img': 'icon-diamond-oval'},
        {'id': 'idshapeprincess', 'name': 'Princess', 'value': 'PRINCESS', 'img': 'icon-diamond-princess'},
        {'id': 'idshapepear', 'name': 'Pear', 'value': 'PEAR', 'img': 'icon-diamond-pear'},
        {'id': 'idshaperadiant', 'name': 'Radiant', 'value': 'RADIANT', 'img': 'icon-diamond-radiant'},
        {'id': 'idshapeother', 'name': 'Other', 'value': 'Other', 'img': 'icon-diamond-other'}
      ],
      'clarities': [
        {'id': 'FL', 'name': 'FL', 'value': 'FL'},
        {'id': 'IF', 'name': 'IF', 'value': 'IF'},
        {'id': 'VVS1', 'name': 'VVS1', 'value': 'VVS1'},
        {'id': 'VVS2', 'name': 'VVS2', 'value': 'VVS2'},
        {'id': 'VS1', 'name': 'VS1', 'value': 'VS1'},
        {'id': 'VS2', 'name': 'VS2', 'value': 'VS2'},
        {'id': 'SI1', 'name': 'SI1', 'value': 'SI1'},
        {'id': 'SI2', 'name': 'SI2', 'value': 'SI2'},
        {'id': 'SI3', 'name': 'SI3', 'value': 'SI3'},
        {'id': 'I1', 'name': 'I1', 'value': 'I1'},
        {'id': 'I2', 'name': 'I2', 'value': 'I2'},
        {'id': 'I3', 'name': 'I3', 'value': 'I3'}
      ],
      'total_wishlist': 0,
    });
  }

  Future<SolitaireDetailsModel> getDiamondDetails(String inventoryId, {String? vdGroupId}) async {
    final catalog = await _loadInitialCatalog();
    final match = catalog.firstWhere(
      (d) => d.serialNo.toUpperCase() == inventoryId.toUpperCase(),
      orElse: () => catalog.isNotEmpty
          ? catalog.first
          : const DiamondModel(
              serialNo: '',
              shape: '',
              weight: 0,
              color: '',
              labColor: '',
              grade: '',
              cut: '',
              polish: '',
              symmetry: '',
              fluorescence: '',
              depth: 0,
              table: 0,
              retailPricePerCts: 0,
              totalRetailPrice: 0,
              wholesalePrice: 0,
              totalWholesalePrice: 0,
              lab: '',
              certNumber: '',
              measurements: '',
              location: '',
              imageUrl: '',
              videoUrl: '',
              certUrl: '',
            ),
    );

    final similar = catalog
        .where((d) => d.serialNo != match.serialNo && (d.shape == match.shape || d.color == match.color))
        .take(6)
        .toList();

    return SolitaireDetailsModel.fromJson({
      'status': 1,
      'message': 'Diamond details fetched successfully',
      'data': {
        'records': [match.toJson()],
        'similar_records': similar.map((s) => s.toJson()).toList(),
        'image_array': match.imageUrl.isNotEmpty ? [match.imageUrl] : [],
        'sample_image_array': [],
        'video_array': match.videoUrl.isNotEmpty ? [match.videoUrl] : [],
        'certificate_array': match.certUrl.isNotEmpty ? [match.certUrl] : [],
        'image_link': [],
        'video_link': [],
        'is_price_hide': 0,
        'login': 0,
      }
    });
  }

  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds) async {
    return {
      'status': 1,
      'message': 'Cart added successfully!',
      'cart_count': inventoryIds.length.toString(),
    };
  }

  Future<CartResponseModel> fetchCart({String? userId}) async {
    final catalog = await _loadInitialCatalog();
    final sampleItems = catalog.take(3).map((d) {
      return SolitaireCartItemModel(
        cartId: '6224_${d.serialNo}',
        stockId: d.serialNo,
        serialNo: d.serialNo,
        lab: d.lab,
        certNumber: d.certNumber,
        shape: d.shape,
        weight: d.weight,
        color: d.color,
        grade: d.grade,
        cut: d.cut,
        polish: d.polish,
        symmetry: d.symmetry,
        fluorescence: d.fluorescence,
        imageUrl: d.imageUrl,
        pricePerCts: d.wholesalePrice > 0 ? d.wholesalePrice : 1500.0,
        available: 1,
      );
    }).toList();

    return CartResponseModel.fromJson({
      'status': 1,
      'message': 'Cart fetched successfully',
      'data': {
        'd_cart': sampleItems.map((item) => {
          'cart_id': item.cartId,
          'stock_id': item.stockId,
          'SN_LAB': item.lab,
          'UDF4': item.certNumber,
          'SN_SERIALNO': item.serialNo,
          'N_CARAT': item.pricePerCts.toString(),
          'shape_full': item.shape,
          'QT_WEIGHT': item.weight.toString(),
          'SN_COLOR': item.color,
          'SN_GRADE': item.grade,
          'cut_full': item.cut,
          'polish_ful': item.polish,
          'symmetry_full': item.symmetry,
          'fluor_full': item.fluorescence,
          'image_show': item.imageUrl,
          'available': item.available,
        }).toList(),
        'j_cart': [],
        'm_cart': [],
        'd_is_price_hide': '0',
        'j_is_price_hide': '0',
        'm_is_price_hide': '0',
        'getEmail': {
          'parent_to_email': 'support@colorsforever.com',
          'to_email': 'praveen@braintreeproducts.com'
        },
        'total_item': sampleItems.length
      }
    });
  }

  Future<Map<String, dynamic>> deleteCart({
    required List<String> cartIds,
    String? userId,
  }) async {
    return {
      'status': 1,
      'message': 'Cart item deleted successfully!',
      'deleted_count': cartIds.length,
      'cart_count': '0',
    };
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
    return {
      'status': 1,
      'message': '$requestType for $targetCart sent successfully!',
    };
  }
}

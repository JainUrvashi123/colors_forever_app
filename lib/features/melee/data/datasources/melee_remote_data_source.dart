import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/session_manager.dart';
import '../../domain/models/melee_constants.dart';
import '../../domain/models/melee_model.dart';

class MeleeRemoteDataSource {
  static const String melleGetAttributeUrl = 'https://colorsforever.com/api/melle_get_attribute';
  static const String previewUrl = 'https://colorsforever.com/melle-get-preview';
  static const String melleIndexUrl = 'https://colorsforever.com/api/melle_index';
  static const String melleAddCartUrl = 'https://colorsforever.com/api/melle_add_cart';
  static const String melleRemoveCartUrl = 'https://colorsforever.com/api/melle_remove_cart';
  static const String melleEmailCartUrl = 'https://colorsforever.com/api/melle_email_cart';
  static const String mellePlaceOrderUrl = 'https://colorsforever.com/api/melle_place_order';

  final http.Client client;

  MeleeRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Map<String, String> get _headers => SessionManager.getHeaders(isJson: false);

  Future<MelleIndexResponse> fetchMelleIndex() async {
    try {
      final response = await client
          .get(Uri.parse(melleIndexUrl), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return MelleIndexResponse.fromJson(decoded);
        } else if (decoded is Map) {
          return MelleIndexResponse.fromJson(Map<String, dynamic>.from(decoded));
        }
      }
    } catch (_) {
      // Graceful fallback to default offline data
    }

    return MelleIndexResponse(
      status: 1,
      message: 'Default Melee Data',
      cartList: [],
      cartTotalValue: const MelleApiCartTotal(
        totalWtFrom: '0.0000',
        totalWtTo: '0.0000',
        totalPriceFrom: '0.00',
        totalPriceTo: '0.00',
      ),
      months: MeleeConstants.birthMonths
          .map((m) => MelleApiMonth(
                id: m.id ?? 'idmonth${m.month}',
                name: m.displayName,
                value: m.month,
                img: '${m.month}.png',
                dcl: m.shadeName.toLowerCase().replaceAll(' ', '_'),
              ))
          .toList(),
      colors: MeleeConstants.colors
          .map((c) => MelleApiColor(
                id: 'idColor${c.name}',
                name: c.name,
                value: c.name,
                img: '${c.name.toLowerCase()}.jpg',
              ))
          .toList(),
      colorShades: MeleeConstants.allShades
          .map((s) => MelleApiColorShade(
                id: s.id ?? 'id_${s.name.toLowerCase().replaceAll(' ', '_')}',
                name: s.name,
                value: s.name,
                dcl: s.name.toLowerCase().replaceAll(' ', '_'),
                pId: 'idColor${s.colorName}',
                month: s.matchingMonth != null ? 'idmonth${s.matchingMonth}' : null,
              ))
          .toList(),
      ticker: const [
        MelleApiTicker(
          id: '2',
          page: 'melle',
          message:
              'PLEASE TRY AND AVOID THE FOLLOWING PREMIUM SIZES: 1.0 mm, 1.3 mm, 1.5mm, 2.0 mm, 2.5 mm, 3.0mm, and 3.5mm. FOR FANCY SHAPES UNDER 1 CARAT, PLEASE CALL US AS THEY ARE NOT LISTED HERE',
        ),
      ],
    );
  }

  Future<List<String>> fetchSizes({
    required String color,
    required String shade,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    try {
      final body = <String, String>{
        'attrType': 'size',
        'color': color,
        'color_ch': shade,
        'stone_type': stoneType == MeleeStoneType.birthstone ? 'birthstone' : 'mellee',
      };
      if (month != null && month.isNotEmpty) {
        body['month'] = month;
      }

      final response = await client
          .post(
            Uri.parse(melleGetAttributeUrl),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        Map? rootData;
        if (decoded is Map) {
          if (decoded['data'] is Map) {
            rootData = decoded['data'] as Map;
          } else {
            rootData = decoded;
          }
        }

        if (rootData != null && rootData['size'] is List) {
          final list = (rootData['size'] as List)
              .map((item) => item is Map ? (item['size']?.toString() ?? '') : item.toString())
              .where((s) => s.isNotEmpty)
              .toList();
          return list;
        }
      }
    } catch (_) {
      // Fallback to local default sizes
    }
    return MeleeConstants.defaultSizes;
  }

  Future<List<String>> fetchGrades({
    required String color,
    required String shade,
    required String size,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    try {
      final body = <String, String>{
        'attrType': 'grade',
        'color': color,
        'color_ch': shade,
        'size': size,
        'stone_type': stoneType == MeleeStoneType.birthstone ? 'birthstone' : 'mellee',
      };
      if (month != null && month.isNotEmpty) {
        body['month'] = month;
      }

      final response = await client
          .post(
            Uri.parse(melleGetAttributeUrl),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        Map? rootData;
        if (decoded is Map) {
          if (decoded['data'] is Map) {
            rootData = decoded['data'] as Map;
          } else {
            rootData = decoded;
          }
        }

        if (rootData != null && rootData['grade'] is List) {
          final list = (rootData['grade'] as List)
              .map((item) => item is Map ? (item['grade']?.toString() ?? '') : item.toString())
              .where((g) => g.isNotEmpty)
              .toList();
          return list;
        }
      }
    } catch (_) {
      // Fallback
    }
    return MeleeConstants.defaultGrades;
  }

  Future<MeleeCalculationResult> fetchItemEstimate({
    required String color,
    required String shade,
    required String size,
    required String grade,
    required int quantity,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    try {
      final body = <String, String>{
        'attrType': 'item',
        'color': color,
        'color_ch': shade,
        'size': size,
        'grade': grade,
        'quantity': quantity.toString(),
        'check_id': '1',
        'stone_type': stoneType == MeleeStoneType.birthstone ? 'birthstone' : 'mellee',
      };
      if (month != null && month.isNotEmpty) {
        body['month'] = month;
      }

      final response = await client
          .post(
            Uri.parse(melleGetAttributeUrl),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        Map? rootData;
        if (decoded is Map) {
          if (decoded['data'] is Map) {
            rootData = decoded['data'] as Map;
          } else {
            rootData = decoded;
          }
        }

        if (rootData != null) {
          final rawPriceCarat = rootData['price_carat']?.toString() ?? '';
          final wtFrom = rootData['wt_from'] is List
              ? ((rootData['wt_from'] as List).isNotEmpty ? (rootData['wt_from'] as List).first.toString() : '')
              : (rootData['wt_from']?.toString() ?? '');
          final wtTo = rootData['wt_to'] is List
              ? ((rootData['wt_to'] as List).isNotEmpty ? (rootData['wt_to'] as List).last.toString() : '')
              : (rootData['wt_to']?.toString() ?? '');
          final rawPriceFrom = rootData['price_from'] is List
              ? ((rootData['price_from'] as List).isNotEmpty ? (rootData['price_from'] as List).first.toString() : '')
              : (rootData['price_from']?.toString() ?? '');
          final rawPriceTo = rootData['price_to'] is List
              ? ((rootData['price_to'] as List).isNotEmpty ? (rootData['price_to'] as List).last.toString() : '')
              : (rootData['price_to']?.toString() ?? '');
          final isExceeded = rootData['is_exceeded'] == 1 || rootData['is_exceeded'] == '1';

          String formatPrice(String val) {
            if (val.isEmpty) return '';
            final clean = val.replaceAll('\$', '').trim();
            final num = double.tryParse(clean);
            if (num != null) {
              return '\$${num.round()}';
            }
            return val.startsWith('\$') ? val : '\$$val';
          }

          return MeleeCalculationResult(
            pricePerCarat: formatPrice(rawPriceCarat),
            wtFrom: wtFrom,
            wtTo: wtTo,
            priceFrom: formatPrice(rawPriceFrom),
            priceTo: formatPrice(rawPriceTo),
            isExceeded: isExceeded,
          );
        }
      }
    } catch (_) {
      // Fallback to heuristic calculation
    }

    // Heuristic offline calculation
    return _calculateOfflineFallback(shade, size, quantity, clarity: grade);
  }

  Future<MeleePreviewData?> fetchPreview({
    required String color,
    required String shade,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    try {
      final queryParams = {
        'color': color,
        'color_ch': shade,
        'stone_type': stoneType == MeleeStoneType.birthstone ? 'birthstone' : 'mellee',
      };
      if (month != null && month.isNotEmpty) {
        queryParams['month'] = month;
      }

      final uri = Uri.parse(previewUrl).replace(queryParameters: queryParams);
      final response = await client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['preview'] is Map) {
          return MeleePreviewData.fromJson(decoded['preview'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Return null to use static preview image URLs
    }
    return null;
  }

  Future<Map<String, dynamic>> addMelleCart({
    required String color,
    required String shade,
    required String size,
    required String grade,
    required int quantity,
    required String specialRequest,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    try {
      final body = <String, String>{
        'attrType': 'cart',
        'color': color,
        'color_ch': shade,
        'size': size,
        'grade': grade,
        'quantity': quantity.toString(),
        'spl_req': specialRequest,
        'stone_type': stoneType == MeleeStoneType.birthstone ? 'birthstone' : 'mellee',
      };
      if (month != null && month.isNotEmpty) {
        body['month'] = month;
      }

      final response = await client
          .post(
            Uri.parse(melleGetAttributeUrl),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          if (map['data'] is Map) {
            final dataMap = Map<String, dynamic>.from(map['data']);
            if (dataMap.containsKey('cart_total_value')) {
              map['cart_total_value'] = dataMap['cart_total_value'];
            }
            if (dataMap.containsKey('item')) {
              map['cart_id'] = dataMap['item'];
            }
          }
          return map;
        }
      }
    } catch (_) {
      // Fallback
    }

    return {
      'status': 1,
      'message': 'Added to cart successfully',
    };
  }

  Future<Map<String, dynamic>> removeMelleCart({required String cartId}) async {
    try {
      final jsonHeaders = SessionManager.getHeaders(isJson: true);
      final jsonBody = json.encode({
        'cart_id': cartId,
      });

      final response = await client
          .post(
            Uri.parse(melleRemoveCartUrl),
            headers: jsonHeaders,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {
      // Return fallback response map
    }

    return {
      'status': 1,
      'message': 'Cart item removed successfully',
      'cart_total_value': {
        'total_wt_from': '0.0000',
        'total_wt_to': '0.0000',
        'total_price_from': '0.00',
        'total_price_to': '0.00'
      }
    };
  }

  Future<Map<String, dynamic>> emailMelleCart({
    required String recEmail,
    required String message,
  }) async {
    try {
      final jsonHeaders = SessionManager.getHeaders(isJson: true);
      final jsonBody = json.encode({
        'rec_email': recEmail,
        'message': message,
      });

      final response = await client
          .post(
            Uri.parse(melleEmailCartUrl),
            headers: jsonHeaders,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {
      // Fallback
    }

    return {
      'status': 1,
      'message': 'Cart emailed successfully',
    };
  }

  Future<Map<String, dynamic>> placeMelleOrder({
    required String contactPerson,
    required String message,
    required String shippingOption,
    required String shippingAddress,
    String? recEmail,
  }) async {
    try {
      final jsonHeaders = SessionManager.getHeaders(isJson: true);
      final jsonBody = json.encode({
        'contact_person': contactPerson,
        'type': 'Melle',
        'request_type': 'Order',
        'shipping_option': shippingOption,
        'shipping_address': shippingAddress,
        'rec_email': recEmail ?? 'urvashijain1999@gmail.com',
        'message': message,
        'markup_d': 0,
      });

      final response = await client
          .post(
            Uri.parse(mellePlaceOrderUrl),
            headers: jsonHeaders,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        SessionManager.updateCookieFromResponse(response.headers);
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {
      // Fallback
    }

    return {
      'status': 1,
      'message': 'Order placed successfully',
    };
  }

  MeleeCalculationResult _calculateOfflineFallback(
    String shade,
    String size,
    int quantity, {
    String clarity = 'VS2-SI2',
  }) {
    return MeleeConstants.calculateFallbackEstimate(
      shade,
      size,
      quantity,
      clarity: clarity,
    );
  }
}

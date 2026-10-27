import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/diamond_model.dart';
import '../models/solitaire_index_model.dart';
import '../models/solitaire_details_model.dart';
import '../models/cart_response_model.dart';
import '../../domain/entities/diamond_filter.dart';
import '../../../../core/network/session_manager.dart';

class RemoteDiamondResponse {
  final List<DiamondModel> records;
  final int totalRecords;

  RemoteDiamondResponse({required this.records, required this.totalRecords});
}

class DiamondRemoteDataSource {
  static const String solitaireIndexUrl = 'https://colorsforever.com/api/solitaire_index';
  static const String solitaireLoadMoreUrl = 'https://colorsforever.com/api/solitaire_load_more_data';
  static const String solitaireDetailsUrl = 'https://colorsforever.com/api/solitaire_diamond_details';
  static const String solitaireAddCartUrl = 'https://colorsforever.com/api/solitaire_add_cart';
  static const String solitaireGetCartUrl = 'https://colorsforever.com/api/get_cart';
  static const String solitaireDeleteCartUrl = 'https://colorsforever.com/api/delete_cart';
  static const String emailDiamondCartUrl = 'https://colorsforever.com/api/email_diamond_cart_api';
  static const String emailJewelryCartUrl = 'https://colorsforever.com/api/email_jewelry_cart_api';
  static const String emailAllCartUrl = 'https://colorsforever.com/api/email_all_cart_api';

  final http.Client client;

  static http.Client _createCustomClient() {
    try {
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return IOClient(ioClient);
    } catch (_) {
      return http.Client();
    }
  }

  DiamondRemoteDataSource({http.Client? client})
      : client = client ?? _createCustomClient();

  Map<String, String> get _headers => SessionManager.getHeaders(isJson: true);

  Map<String, dynamic> _cleanExtractJson(http.Response response) {
    List<int> bytes = response.bodyBytes;

    final isGzipHeader = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final isGzipEncoding = response.headers['content-encoding']?.toLowerCase().contains('gzip') ?? false;

    if (isGzipHeader || isGzipEncoding) {
      try {
        bytes = gzip.decode(bytes);
      } catch (e) {
        debugPrint('GZip decode error: $e');
      }
    }

    String rawBody = utf8.decode(bytes, allowMalformed: true);

    int jsonStart = rawBody.indexOf('{"');
    if (jsonStart == -1) {
      jsonStart = rawBody.indexOf('{');
    }

    if (jsonStart == -1) {
      throw Exception('Invalid server response format (HTTP ${response.statusCode}): no JSON start in body: ${rawBody.length > 120 ? rawBody.substring(0, 120) : rawBody}');
    }

    int jsonEnd = rawBody.lastIndexOf('}') + 1;
    final jsonText = rawBody.substring(jsonStart, jsonEnd);
    return json.decode(jsonText) as Map<String, dynamic>;
  }

  /// Fetches solitaire index metadata (colors, shades, shapes, clarities, ticker, etc.)
  Future<SolitaireIndexModel> fetchSolitaireIndex() async {
    final response = await client
        .get(
          Uri.parse(solitaireIndexUrl),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 30));

    SessionManager.updateCookieFromResponse(response.headers);
    final data = _cleanExtractJson(response);
    return SolitaireIndexModel.fromJson(data);
  }

  /// Fetches paginated solitaire inventory records using `/api/solitaire_load_more_data`
  Future<RemoteDiamondResponse> fetchDiamonds({
    required DiamondFilter filter,
    int page = 1,
    int perPage = 16,
  }) async {
    final offset = (page - 1) * perPage;

    final minC = filter.minCarat <= 0.0
        ? '0'
        : (filter.minCarat == filter.minCarat.toInt()
            ? filter.minCarat.toInt().toString()
            : filter.minCarat.toStringAsFixed(2));
    final maxC = (filter.maxCarat <= 0.0 || filter.maxCarat >= 100.0)
        ? '100'
        : (filter.maxCarat == filter.maxCarat.toInt()
            ? filter.maxCarat.toInt().toString()
            : filter.maxCarat.toStringAsFixed(2));

    final minP = filter.minPrice <= 0.0 ? '0' : filter.minPrice.toInt().toString();
    final maxP = (filter.maxPrice <= 0.0 || filter.maxPrice >= 500000.0)
        ? '500000'
        : filter.maxPrice.toInt().toString();

    final bodyPayload = <String, dynamic>{
      'stock': '',
      'report': '',
      'checkbox': filter.selectedShapes,
      'color': filter.selectedColors.map((c) {
        if (c == 'Champagne/Brown') return 'Brown';
        if (c == 'White/Colorless') return 'White';
        return c;
      }).toList(),
      'color_ch': filter.selectedShades,
      'clarity': filter.selectedClarities,
      'cert': filter.selectedLabs,
      'carat': '$minC;$maxC',
      'price': '$minP;$maxP',
      'search': filter.searchQuery.trim(),
      'location': filter.location ?? '',
      'sort_by': filter.sortBy.isEmpty ? 'price_l' : filter.sortBy,
      'per_page': perPage,
      'page': offset,
      'vd_user_id': (SessionManager.vdUserId != null && SessionManager.vdUserId!.isNotEmpty)
          ? SessionManager.vdUserId
          : '25',
      'vd_group_id': (SessionManager.vdGroupId != null && SessionManager.vdGroupId!.isNotEmpty)
          ? SessionManager.vdGroupId
          : '4',
      if (SessionManager.userId != null && SessionManager.userId!.isNotEmpty)
        'user_id': SessionManager.userId,
    };

    http.Response response;
    try {
      response = await client
          .post(
            Uri.parse(solitaireLoadMoreUrl),
            headers: _headers,
            body: json.encode(bodyPayload),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      // Retry once in case of transient network connection issue or timeout
      response = await client
          .post(
            Uri.parse(solitaireLoadMoreUrl),
            headers: _headers,
            body: json.encode(bodyPayload),
          )
          .timeout(const Duration(seconds: 30));
    }

    SessionManager.updateCookieFromResponse(response.headers);
    final Map<String, dynamic> data = _cleanExtractJson(response);
    final rawRecords = data['records'] as List? ?? [];
    final records = rawRecords
        .map((r) => DiamondModel.fromJson(r as Map<String, dynamic>))
        .toList();

    int total = 0;
    if (data['total_records'] != null) {
      total = int.tryParse(data['total_records'].toString()) ?? records.length;
    } else {
      total = records.length;
    }

    return RemoteDiamondResponse(records: records, totalRecords: total);
  }

  /// Fetches full diamond dossier details using `/api/solitaire_diamond_details`
  Future<SolitaireDetailsModel> fetchDiamondDetails(
    String inventoryId, {
    String? vdGroupId,
  }) async {
    final effectiveVdGroupId = (vdGroupId != null && vdGroupId.isNotEmpty)
        ? vdGroupId
        : SessionManager.vdGroupId;

    final bodyPayload = <String, dynamic>{
      'inventory_id': inventoryId.trim(),
      if (SessionManager.userId != null && SessionManager.userId!.isNotEmpty)
        'user_id': SessionManager.userId,
      if (effectiveVdGroupId != null && effectiveVdGroupId.isNotEmpty)
        'vd_group_id': effectiveVdGroupId,
    };

    final response = await client
        .post(
          Uri.parse(solitaireDetailsUrl),
          headers: _headers,
          body: json.encode(bodyPayload),
        )
        .timeout(const Duration(seconds: 10));

    SessionManager.updateCookieFromResponse(response.headers);
    final Map<String, dynamic> data = _cleanExtractJson(response);
    return SolitaireDetailsModel.fromJson(data);
  }

  /// Adds items to cart using `/api/solitaire_add_cart` with automatic session recovery
  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds) async {
    final bodyPayload = <String, dynamic>{
      'all_id': inventoryIds,
      if (SessionManager.userId != null && SessionManager.userId!.isNotEmpty)
        'user_id': SessionManager.userId,
    };

    var response = await client
        .post(
          Uri.parse(solitaireAddCartUrl),
          headers: _headers,
          body: json.encode(bodyPayload),
        )
        .timeout(const Duration(seconds: 10));

    SessionManager.updateCookieFromResponse(response.headers);
    var data = _cleanExtractJson(response);

    // Check if server session expired or requires login
    final isUnauthenticated = (data['login'] == 0 ||
        data['login'] == '0' ||
        (data['message'] != null &&
            data['message'].toString().toLowerCase().contains('login')));

    if (isUnauthenticated && SessionManager.reauthenticate != null) {
      final reloggedIn = await SessionManager.reauthenticate!();
      if (reloggedIn) {
        // Retry POST request with refreshed session cookies & headers
        response = await client
            .post(
              Uri.parse(solitaireAddCartUrl),
              headers: _headers,
              body: json.encode(bodyPayload),
            )
            .timeout(const Duration(seconds: 10));

        SessionManager.updateCookieFromResponse(response.headers);
        data = _cleanExtractJson(response);
      }
    }

    return data;
  }

  /// Fetches current active diamond cart items using `/api/get_cart`
  Future<CartResponseModel> fetchCart({String? userId}) async {
    final uid = userId ?? SessionManager.userId ?? SessionManager.vdUserId ?? '25';
    final gid = SessionManager.vdGroupId ?? '4';
    final bodyPayload = <String, dynamic>{
      'user_id': uid,
      'group_id': gid,
      'vd_user_id': uid,
      'vd_group_id': gid,
    };

    var response = await client
        .post(
          Uri.parse(solitaireGetCartUrl),
          headers: _headers,
          body: json.encode(bodyPayload),
        )
        .timeout(const Duration(seconds: 10));

    SessionManager.updateCookieFromResponse(response.headers);
    var data = _cleanExtractJson(response);

    final isUnauthenticated = (data['status'] == 0 &&
        data['message'] != null &&
        data['message'].toString().toLowerCase().contains('login'));

    if (isUnauthenticated && SessionManager.reauthenticate != null) {
      final reloggedIn = await SessionManager.reauthenticate!();
      if (reloggedIn) {
        response = await client
            .post(
              Uri.parse(solitaireGetCartUrl),
              headers: _headers,
              body: json.encode(bodyPayload),
            )
            .timeout(const Duration(seconds: 10));

        SessionManager.updateCookieFromResponse(response.headers);
        data = _cleanExtractJson(response);
      }
    }

    return CartResponseModel.fromJson(data);
  }

  /// Deletes cart item(s) using `/api/delete_cart`
  Future<Map<String, dynamic>> deleteCart({
    required List<String> cartIds,
    String? userId,
  }) async {
    final uid = userId ?? SessionManager.userId ?? '';
    final bodyPayload = <String, dynamic>{
      'user_id': uid,
      'cart_id': cartIds.join(','),
    };

    var response = await client
        .post(
          Uri.parse(solitaireDeleteCartUrl),
          headers: _headers,
          body: json.encode(bodyPayload),
        )
        .timeout(const Duration(seconds: 10));

    SessionManager.updateCookieFromResponse(response.headers);
    var data = _cleanExtractJson(response);

    final isUnauthenticated = (data['status'] == 0 &&
        data['message'] != null &&
        data['message'].toString().toLowerCase().contains('login'));

    if (isUnauthenticated && SessionManager.reauthenticate != null) {
      final reloggedIn = await SessionManager.reauthenticate!();
      if (reloggedIn) {
        response = await client
            .post(
              Uri.parse(solitaireDeleteCartUrl),
              headers: _headers,
              body: json.encode(bodyPayload),
            )
            .timeout(const Duration(seconds: 10));

        SessionManager.updateCookieFromResponse(response.headers);
        data = _cleanExtractJson(response);
      }
    }

    return data;
  }

  /// Sends email or memo request for Diamond Cart, Jewelry Cart, or All Cart
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
    final uid = userId ?? SessionManager.userId ?? SessionManager.vdUserId ?? '25';
    final gid = groupId ?? SessionManager.vdGroupId ?? '4';

    String targetUrl;
    final lowerTarget = targetCart.toLowerCase();
    if (lowerTarget.contains('diamond')) {
      targetUrl = emailDiamondCartUrl;
    } else if (lowerTarget.contains('jewelry')) {
      targetUrl = emailJewelryCartUrl;
    } else {
      targetUrl = emailAllCartUrl;
    }

    final bodyPayload = <String, dynamic>{
      'user_id': uid,
      'group_id': gid,
      'contact_person': contactPerson,
      'type': type,
      'request_type': requestType,
      'shipping_option': shippingOption,
      'rec_email': recEmail,
      'message': message,
      'markup_d': markupD,
    };

    var response = await client
        .post(
          Uri.parse(targetUrl),
          headers: _headers,
          body: json.encode(bodyPayload),
        )
        .timeout(const Duration(seconds: 15));

    SessionManager.updateCookieFromResponse(response.headers);
    var data = _cleanExtractJson(response);

    final isUnauthenticated = (data['status'] == 0 &&
        data['message'] != null &&
        data['message'].toString().toLowerCase().contains('login'));

    if (isUnauthenticated && SessionManager.reauthenticate != null) {
      final reloggedIn = await SessionManager.reauthenticate!();
      if (reloggedIn) {
        response = await client
            .post(
              Uri.parse(targetUrl),
              headers: _headers,
              body: json.encode(bodyPayload),
            )
            .timeout(const Duration(seconds: 15));

        SessionManager.updateCookieFromResponse(response.headers);
        data = _cleanExtractJson(response);
      }
    }

    return data;
  }
}

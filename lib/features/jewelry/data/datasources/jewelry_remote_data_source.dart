import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/jewelry_index_model.dart';
import '../models/jewelry_item_model.dart';

class JewelryLoadMoreResult {
  final List<JewelryItem> items;
  final int totalRecords;
  final int page;
  final int totalPages;
  final bool hasNextPage;

  const JewelryLoadMoreResult({
    required this.items,
    required this.totalRecords,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
  });

  static const JewelryLoadMoreResult empty = JewelryLoadMoreResult(
    items: [],
    totalRecords: 0,
    page: 1,
    totalPages: 0,
    hasNextPage: false,
  );
}

class JewelryRemoteDataSource {
  static const String jewelryIndexUrl = 'https://colorsforever.com/api/jewelry_index';
  static const String jewelryLoadMoreUrl = 'https://colorsforever.com/api/jewelry_load_more_data';

  Map<String, String> get _headers => {
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'X-Requested-With': 'XMLHttpRequest',
        'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)',
      };

  /// GET / POST https://colorsforever.com/api/jewelry_index
  Future<JewelryIndexResponse> fetchJewelryIndex() async {
    try {
      final response = await http.get(
        Uri.parse(jewelryIndexUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1 || data['status'] == '1' || data['status'] == true) {
          return JewelryIndexResponse.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching jewelry index: $e');
    }
    return JewelryIndexResponse.empty;
  }

  /// POST https://colorsforever.com/api/jewelry_load_more_data
  Future<JewelryLoadMoreResult> loadMoreJewelry({
    int page = 1,
    String? department,
    List<String>? departments,
    String? sec1,
    List<String>? sec1List,
    String? goldKarat,
    List<String>? goldKarats,
    String? goldColor,
    List<String>? goldColors,
    String? diamondColor,
    List<String>? diamondColors,
    String? styleSetting,
    List<String>? styleSettings,
    String? size,
    List<String>? sizes,
    double? ctFrom,
    double? ctTo,
    double? priceFrom,
    double? priceTo,
    String? search,
    String sortBy = 'random',
    String? userId,
  }) async {
    try {
      final Map<String, dynamic> bodyJson = {
        'page': page,
        'per_page': 20,
        'sort_by': sortBy,
      };

      if (userId != null && userId.isNotEmpty) {
        bodyJson['user_id'] = userId;
      }

      final depts = departments ?? (department != null && department != 'All' ? [department] : []);
      final cleanDepts = depts.where((d) => d.isNotEmpty && d != 'All').toList();
      if (cleanDepts.isNotEmpty) {
        bodyJson['dep'] = cleanDepts;
      }

      final secRings = <String>[];
      final secPendants = <String>[];
      final secEarrings = <String>[];
      final secBracelets = <String>[];

      final subs = sec1List ?? (sec1 != null ? [sec1] : []);
      for (final s in subs) {
        if (s.isEmpty) continue;
        if (s.contains(':')) {
          final parts = s.split(':');
          final dept = parts.first.toUpperCase();
          final val = parts.last;
          if (dept == 'RING') {
            secRings.add(val);
          } else if (dept == 'PENDANT') {
            secPendants.add(val);
          } else if (dept == 'EARRING') {
            secEarrings.add(val);
          } else if (dept == 'BRACELET') {
            secBracelets.add(val);
          }
        } else {
          secRings.add(s);
          secPendants.add(s);
          secEarrings.add(s);
          secBracelets.add(s);
        }
      }

      if (secRings.isNotEmpty) bodyJson['secRing[]'] = secRings;
      if (secPendants.isNotEmpty) bodyJson['secPendant[]'] = secPendants;
      if (secEarrings.isNotEmpty) bodyJson['secEarring[]'] = secEarrings;
      if (secBracelets.isNotEmpty) bodyJson['secBracelet[]'] = secBracelets;

      final karats = goldKarats ?? (goldKarat != null ? [goldKarat] : []);
      final cleanKarats = karats.where((k) => k.isNotEmpty).toList();
      if (cleanKarats.isNotEmpty) {
        bodyJson['metal_grade'] = cleanKarats.length == 1 ? cleanKarats.first : cleanKarats;
      }

      final mColors = goldColors ?? (goldColor != null ? [goldColor] : []);
      final cleanMColors = mColors.where((mc) => mc.isNotEmpty).toList();
      if (cleanMColors.isNotEmpty) {
        bodyJson['metal_color'] = cleanMColors.length == 1 ? cleanMColors.first : cleanMColors;
      }

      final dColors = diamondColors ?? (diamondColor != null ? [diamondColor] : []);
      final cleanDColors = dColors.where((dc) => dc.isNotEmpty).toList();
      if (cleanDColors.isNotEmpty) {
        bodyJson['diamond_color'] = cleanDColors.length == 1 ? cleanDColors.first : cleanDColors;
      }

      final styles = styleSettings ?? (styleSetting != null ? [styleSetting] : []);
      final cleanStyles = styles.where((st) => st.isNotEmpty).toList();
      if (cleanStyles.isNotEmpty) {
        bodyJson['style_setting'] = cleanStyles.length == 1 ? cleanStyles.first : cleanStyles;
      }

      final szs = sizes ?? (size != null ? [size] : []);
      final cleanSizes = szs.where((sz) => sz.isNotEmpty).toList();
      if (cleanSizes.isNotEmpty) {
        bodyJson['size'] = cleanSizes.length == 1 ? cleanSizes.first : cleanSizes;
      }

      if (ctFrom != null || ctTo != null) {
        final minCt = ctFrom ?? 0.1;
        final maxCt = ctTo ?? 20.0;
        bodyJson['carat'] = '${minCt.toStringAsFixed(1)};${maxCt.toStringAsFixed(1)}';
      }

      if (priceFrom != null || priceTo != null) {
        final minP = priceFrom?.toInt() ?? 1;
        final maxP = priceTo?.toInt() ?? 100000;
        bodyJson['price'] = '$minP;$maxP';
      }

      if (search != null && search.isNotEmpty) {
        bodyJson['search'] = search;
      }

      final postHeaders = Map<String, String>.from(_headers)
        ..['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse(jewelryLoadMoreUrl),
        headers: postHeaders,
        body: json.encode(bodyJson),
      );

      if (response.statusCode == 200) {
        final rawJson = json.decode(response.body) as Map<String, dynamic>;

        dynamic dataField = rawJson['data'];
        List dataList = [];
        Map<String, dynamic> metaMap = rawJson;

        if (dataField is Map<String, dynamic>) {
          metaMap = dataField;
          if (dataField['records'] is List) {
            dataList = dataField['records'] as List;
          } else if (dataField['data'] is List) {
            dataList = dataField['data'] as List;
          }
        } else if (dataField is List) {
          dataList = dataField;
        }

        final items = dataList
            .map((e) => JewelryItem.fromJson(e as Map<String, dynamic>))
            .toList();

        final totalRec = int.tryParse(metaMap['total_records']?.toString() ?? '0') ?? items.length;
        final currentPage = int.tryParse(metaMap['page']?.toString() ?? '1') ?? page;
        final totalPages = int.tryParse(metaMap['total_pages']?.toString() ?? '1') ?? 1;
        final hasNext = metaMap['has_next_page'] == true || (currentPage < totalPages);

        return JewelryLoadMoreResult(
          items: items,
          totalRecords: totalRec,
          page: currentPage,
          totalPages: totalPages,
          hasNextPage: hasNext,
        );
      }
    } catch (e) {
      debugPrint('Error loading jewelry catalog: $e');
    }
    return JewelryLoadMoreResult.empty;
  }
}

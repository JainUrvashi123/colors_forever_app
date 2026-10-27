import 'dart:convert';
import 'package:flutter/material.dart';

enum MeleeStoneType { melee, birthstone }

enum MeleeViewMode { melee, solitaire }

class MeleeColorOption {
  final String name;
  final String assetPath;
  final Color primaryColor;
  final String? id;
  final String? value;
  final String? networkImgUrl;

  const MeleeColorOption({
    required this.name,
    required this.assetPath,
    required this.primaryColor,
    this.id,
    this.value,
    this.networkImgUrl,
  });
}

class MeleeShadeOption {
  final String name;
  final String colorName;
  final Color badgeColor;
  final String? matchingMonth;
  final String? id;
  final String? dcl;
  final String? pId;

  const MeleeShadeOption({
    required this.name,
    required this.colorName,
    required this.badgeColor,
    this.matchingMonth,
    this.id,
    this.dcl,
    this.pId,
  });
}

class BirthMonthOption {
  final String month;
  final String displayName;
  final String shadeName;
  final String colorName;
  final Color accentColor;
  final bool isDisabled;
  final String? id;
  final String? img;
  final String? dcl;

  const BirthMonthOption({
    required this.month,
    required this.displayName,
    required this.shadeName,
    required this.colorName,
    required this.accentColor,
    this.isDisabled = false,
    this.id,
    this.img,
    this.dcl,
  });
}

class MeleeCalculationResult {
  final String pricePerCarat;
  final String wtFrom;
  final String wtTo;
  final String priceFrom;
  final String priceTo;
  final bool isExceeded;

  const MeleeCalculationResult({
    required this.pricePerCarat,
    required this.wtFrom,
    required this.wtTo,
    required this.priceFrom,
    required this.priceTo,
    this.isExceeded = false,
  });

  factory MeleeCalculationResult.empty() {
    return const MeleeCalculationResult(
      pricePerCarat: '',
      wtFrom: '',
      wtTo: '',
      priceFrom: '',
      priceTo: '',
      isExceeded: false,
    );
  }
}

class MeleePreviewData {
  final String? img;
  final String? imgSol;
  final String? video;
  final String? videoSol;
  final String? videoThumb;
  final String? videoSolThumb;

  const MeleePreviewData({
    this.img,
    this.imgSol,
    this.video,
    this.videoSol,
    this.videoThumb,
    this.videoSolThumb,
  });

  factory MeleePreviewData.fromJson(Map<String, dynamic> json) {
    return MeleePreviewData(
      img: json['img']?.toString(),
      imgSol: json['img_sol']?.toString(),
      video: json['video']?.toString(),
      videoSol: json['video_sol']?.toString(),
      videoThumb: json['video_thumb']?.toString(),
      videoSolThumb: json['video_sol_thumb']?.toString(),
    );
  }
}

class MeleeCartItem {
  final String id;
  final MeleeStoneType stoneType;
  final String? month;
  final String color;
  final String shade;
  final String size;
  final String clarity;
  final int quantity;
  final String pricePerCarat;
  final String wtFrom;
  final String wtTo;
  final String priceFrom;
  final String priceTo;
  final String specialRequest;
  final String? previewImageUrl;
  final DateTime createdAt;

  MeleeCartItem({
    required this.id,
    required this.stoneType,
    this.month,
    required this.color,
    required this.shade,
    required this.size,
    required this.clarity,
    required this.quantity,
    required this.pricePerCarat,
    required this.wtFrom,
    required this.wtTo,
    required this.priceFrom,
    required this.priceTo,
    required this.specialRequest,
    this.previewImageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stoneType': stoneType.name,
      'month': month,
      'color': color,
      'shade': shade,
      'size': size,
      'clarity': clarity,
      'quantity': quantity,
      'pricePerCarat': pricePerCarat,
      'wtFrom': wtFrom,
      'wtTo': wtTo,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
      'specialRequest': specialRequest,
      'previewImageUrl': previewImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MeleeCartItem.fromJson(Map<String, dynamic> json) {
    return MeleeCartItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      stoneType: json['stoneType'] == 'birthstone' ? MeleeStoneType.birthstone : MeleeStoneType.melee,
      month: json['month']?.toString(),
      color: json['color']?.toString() ?? 'Blue',
      shade: json['shade']?.toString() ?? 'SKY BLUE',
      size: json['size']?.toString() ?? '0.8 MM',
      clarity: json['clarity']?.toString() ?? 'VS2-SI2',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      pricePerCarat: json['pricePerCarat']?.toString() ?? '',
      wtFrom: json['wtFrom']?.toString() ?? '0.0000',
      wtTo: json['wtTo']?.toString() ?? '0.0000',
      priceFrom: json['priceFrom']?.toString() ?? '',
      priceTo: json['priceTo']?.toString() ?? '',
      specialRequest: json['specialRequest']?.toString() ?? '',
      previewImageUrl: json['previewImageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  double get minWeight => double.tryParse(wtFrom) ?? 0.0;
  double get maxWeight => double.tryParse(wtTo) ?? 0.0;
  double get minPrice => double.tryParse(priceFrom.replaceAll(r'$', '').trim()) ?? 0.0;
  double get maxPrice => double.tryParse(priceTo.replaceAll(r'$', '').trim()) ?? 0.0;

  MeleeCartItem copyWith({
    String? id,
    MeleeStoneType? stoneType,
    String? month,
    String? color,
    String? shade,
    String? size,
    String? clarity,
    int? quantity,
    String? pricePerCarat,
    String? wtFrom,
    String? wtTo,
    String? priceFrom,
    String? priceTo,
    String? specialRequest,
    String? previewImageUrl,
  }) {
    return MeleeCartItem(
      id: id ?? this.id,
      stoneType: stoneType ?? this.stoneType,
      month: month ?? this.month,
      color: color ?? this.color,
      shade: shade ?? this.shade,
      size: size ?? this.size,
      clarity: clarity ?? this.clarity,
      quantity: quantity ?? this.quantity,
      pricePerCarat: pricePerCarat ?? this.pricePerCarat,
      wtFrom: wtFrom ?? this.wtFrom,
      wtTo: wtTo ?? this.wtTo,
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      specialRequest: specialRequest ?? this.specialRequest,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      createdAt: createdAt,
    );
  }
}

class MelleIndexResponse {
  final int status;
  final String message;
  final List<MelleApiCartItem> cartList;
  final MelleApiCartTotal? cartTotalValue;
  final List<MelleApiMonth> months;
  final List<MelleApiColor> colors;
  final List<MelleApiColorShade> colorShades;
  final List<MelleApiTicker> ticker;

  const MelleIndexResponse({
    required this.status,
    required this.message,
    required this.cartList,
    this.cartTotalValue,
    required this.months,
    required this.colors,
    required this.colorShades,
    required this.ticker,
  });

  String? get cleanTickerMessage {
    if (ticker.isEmpty) return null;
    for (final t in ticker) {
      final clean = t.cleanMessage;
      if (clean.isNotEmpty) return clean;
    }
    return null;
  }

  factory MelleIndexResponse.fromJson(Map<String, dynamic> json) {
    final cartListRaw = json['cart_list'];
    final List<MelleApiCartItem> cartItems = [];
    if (cartListRaw is List) {
      for (final item in cartListRaw) {
        if (item is Map<String, dynamic>) {
          cartItems.add(MelleApiCartItem.fromJson(item));
        } else if (item is Map) {
          cartItems.add(MelleApiCartItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    MelleApiCartTotal? cartTotal;
    if (json['cart_total_value'] is Map) {
      cartTotal = MelleApiCartTotal.fromJson(
          Map<String, dynamic>.from(json['cart_total_value'] as Map));
    }

    final monthsRaw = json['months'];
    final List<MelleApiMonth> monthsList = [];
    if (monthsRaw is List) {
      for (final m in monthsRaw) {
        if (m is Map) {
          monthsList.add(MelleApiMonth.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    final colorsRaw = json['colors'];
    final List<MelleApiColor> colorsList = [];
    if (colorsRaw is List) {
      for (final c in colorsRaw) {
        if (c is Map) {
          colorsList.add(MelleApiColor.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    final shadesRaw = json['colorShades'];
    final List<MelleApiColorShade> shadesList = [];
    if (shadesRaw is List) {
      for (final s in shadesRaw) {
        if (s is Map) {
          shadesList.add(MelleApiColorShade.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    final tickerRaw = json['ticker'];
    final List<MelleApiTicker> tickerList = [];
    if (tickerRaw is List) {
      for (final t in tickerRaw) {
        if (t is Map) {
          tickerList.add(MelleApiTicker.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }

    return MelleIndexResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      cartList: cartItems,
      cartTotalValue: cartTotal,
      months: monthsList,
      colors: colorsList,
      colorShades: shadesList,
      ticker: tickerList,
    );
  }
}

class MelleApiCartItem {
  final String? cartId;
  final String? stockId;
  final String? quantity;
  final String? splReq;
  final String? item;
  final String? size;
  final String? color;
  final String? grade;
  final String? wtFrom;
  final String? wtTo;
  final String? priceFrom;
  final String? priceTo;
  final String? tagPrice;
  final String? filterParam;

  const MelleApiCartItem({
    this.cartId,
    this.stockId,
    this.quantity,
    this.splReq,
    this.item,
    this.size,
    this.color,
    this.grade,
    this.wtFrom,
    this.wtTo,
    this.priceFrom,
    this.priceTo,
    this.tagPrice,
    this.filterParam,
  });

  factory MelleApiCartItem.fromJson(Map<String, dynamic> json) {
    return MelleApiCartItem(
      cartId: json['cart_id']?.toString() ??
          json['id']?.toString() ??
          json['cart_item_id']?.toString(),
      stockId: json['stock_id']?.toString(),
      quantity: json['quantity']?.toString(),
      splReq: json['spl_req']?.toString(),
      item: json['item']?.toString(),
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      grade: json['grade']?.toString(),
      wtFrom: json['wt_from']?.toString(),
      wtTo: json['wt_to']?.toString(),
      priceFrom: json['price_from']?.toString(),
      priceTo: json['price_to']?.toString(),
      tagPrice: json['tag_price']?.toString(),
      filterParam: json['filter_param']?.toString(),
    );
  }

  MeleeCartItem toMeleeCartItem() {
    var isBirthstone = false;
    String? shadeResolved;
    String? monthResolved;

    if (filterParam != null && filterParam!.isNotEmpty) {
      try {
        final decoded = json.decode(filterParam!);
        if (decoded is Map) {
          final stoneCheck = decoded['stoneTypeChecked']?.toString();
          if (stoneCheck == 'birthstone' || stoneCheck == 'type_birthstone') {
            isBirthstone = true;
          }
          if (decoded['color_ch'] != null) {
            shadeResolved = decoded['color_ch'].toString().toUpperCase();
          }
          if (decoded['month'] != null) {
            monthResolved = decoded['month'].toString();
          }
          if (shadeResolved == null && decoded['itemFilter'] != null) {
            final ifilter = decoded['itemFilter'];
            if (ifilter is Map && ifilter['color_ch'] != null) {
              shadeResolved = ifilter['color_ch'].toString().toUpperCase();
            } else if (ifilter is String) {
              final nested = json.decode(ifilter);
              if (nested is Map && nested['color_ch'] != null) {
                shadeResolved = nested['color_ch'].toString().toUpperCase();
              }
            }
          }
        }
      } catch (_) {}
    }

    if (shadeResolved == null || shadeResolved.isEmpty) {
      if (item != null && item!.contains('[')) {
        shadeResolved = item!.split('[').first.trim().toUpperCase();
      } else {
        shadeResolved = (color ?? 'BLUE').toUpperCase();
      }
    }

    final qty = int.tryParse(quantity ?? '1') ?? 1;
    final priceCaratFormatted = (tagPrice != null && tagPrice!.isNotEmpty)
        ? (tagPrice!.startsWith(r'$') ? tagPrice! : '\$$tagPrice')
        : '';
    final priceFromFormatted = (priceFrom != null && priceFrom!.isNotEmpty)
        ? (priceFrom!.startsWith(r'$') ? priceFrom! : '\$$priceFrom')
        : '';
    final priceToFormatted = (priceTo != null && priceTo!.isNotEmpty)
        ? (priceTo!.startsWith(r'$') ? priceTo! : '\$$priceTo')
        : '';

    return MeleeCartItem(
      id: cartId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      stoneType: isBirthstone ? MeleeStoneType.birthstone : MeleeStoneType.melee,
      month: monthResolved,
      color: color ?? 'Blue',
      shade: shadeResolved,
      size: size ?? '0.8 MM',
      clarity: grade ?? 'VS2-SI2',
      quantity: qty,
      pricePerCarat: priceCaratFormatted,
      wtFrom: wtFrom ?? '0.0000',
      wtTo: wtTo ?? '0.0000',
      priceFrom: priceFromFormatted,
      priceTo: priceToFormatted,
      specialRequest: splReq ?? '',
    );
  }
}

class MelleApiCartTotal {
  final String totalWtFrom;
  final String totalWtTo;
  final String totalPriceFrom;
  final String totalPriceTo;

  const MelleApiCartTotal({
    required this.totalWtFrom,
    required this.totalWtTo,
    required this.totalPriceFrom,
    required this.totalPriceTo,
  });

  factory MelleApiCartTotal.fromJson(Map<String, dynamic> json) {
    return MelleApiCartTotal(
      totalWtFrom: json['total_wt_from']?.toString() ?? '0.0000',
      totalWtTo: json['total_wt_to']?.toString() ?? '0.0000',
      totalPriceFrom: json['total_price_from']?.toString() ?? '0.00',
      totalPriceTo: json['total_price_to']?.toString() ?? '0.00',
    );
  }
}

class MelleApiMonth {
  final String id;
  final String name;
  final String value;
  final String img;
  final String dcl;

  const MelleApiMonth({
    required this.id,
    required this.name,
    required this.value,
    required this.img,
    required this.dcl,
  });

  factory MelleApiMonth.fromJson(Map<String, dynamic> json) {
    return MelleApiMonth(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      dcl: json['dcl']?.toString() ?? '',
    );
  }

  BirthMonthOption toBirthMonthOption() {
    final color = _resolveColorForMonth(value);
    final shade = _resolveShadeNameForMonth(value);

    return BirthMonthOption(
      month: value.toLowerCase(),
      displayName: name,
      shadeName: shade,
      colorName: color.$1,
      accentColor: color.$2,
      id: id,
      img: img,
      dcl: dcl,
    );
  }

  static (String, Color) _resolveColorForMonth(String monthVal) {
    switch (monthVal.toLowerCase()) {
      case 'january':
        return ('Orange', const Color(0xFFCA5615));
      case 'february':
        return ('Purple', const Color(0xFF8A1B63));
      case 'march':
        return ('Blue', const Color(0xFF85B5E1));
      case 'april':
        return ('White', const Color(0xFFFFFFFF));
      case 'may':
        return ('Green', const Color(0xFF12A023));
      case 'june':
        return ('Green', const Color(0xFF067E15));
      case 'july':
        return ('Red', const Color(0xFFA22F05));
      case 'august':
        return ('Green', const Color(0xFF7ED168));
      case 'september':
        return ('Blue', const Color(0xFF0A3A7B));
      case 'october':
        return ('Pink', const Color(0xFFD84CA1));
      case 'november':
        return ('Yellow', const Color(0xFFFFEA25));
      case 'december':
        return ('Blue', const Color(0xFF2B65B4));
      default:
        return ('Blue', const Color(0xFF0A3A7B));
    }
  }

  static String _resolveShadeNameForMonth(String monthVal) {
    switch (monthVal.toLowerCase()) {
      case 'january':
        return 'ORANGISH COGNAC';
      case 'february':
        return 'PURPLE';
      case 'march':
        return 'AQUA BLUE I';
      case 'april':
        return 'WHITE';
      case 'may':
        return 'EMERALD GREEN';
      case 'june':
        return 'FOREST GREEN';
      case 'july':
        return 'REDDISH COGNAC';
      case 'august':
        return 'ICE GREEN I';
      case 'september':
        return 'ROYAL BLUE';
      case 'october':
        return 'ROSE PINK';
      case 'november':
        return 'GOLDEN YELLOW';
      case 'december':
        return 'SKY BLUE';
      default:
        return 'AQUA BLUE I';
    }
  }
}

class MelleApiColor {
  final String id;
  final String name;
  final String value;
  final String img;

  const MelleApiColor({
    required this.id,
    required this.name,
    required this.value,
    required this.img,
  });

  factory MelleApiColor.fromJson(Map<String, dynamic> json) {
    return MelleApiColor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
    );
  }

  MeleeColorOption toMeleeColorOption() {
    final cName = name.isNotEmpty ? name : value;
    final asset = 'assets/colors/${cName.toLowerCase()}.jpg';
    final network = 'https://colorsforever.com/assets/images/$img';
    final primary = resolveColorByName(cName);

    return MeleeColorOption(
      name: cName,
      assetPath: asset,
      primaryColor: primary,
      id: id,
      value: value,
      networkImgUrl: network,
    );
  }
}

class MelleApiColorShade {
  final String id;
  final String name;
  final String value;
  final String dcl;
  final String pId;
  final String? month;

  const MelleApiColorShade({
    required this.id,
    required this.name,
    required this.value,
    required this.dcl,
    required this.pId,
    this.month,
  });

  factory MelleApiColorShade.fromJson(Map<String, dynamic> json) {
    return MelleApiColorShade(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      dcl: json['dcl']?.toString() ?? '',
      pId: json['p_id']?.toString() ?? '',
      month: json['month']?.toString(),
    );
  }

  MeleeShadeOption toMeleeShadeOption() {
    final cName = resolveColorNameFromPid(pId);
    final badge = resolveShadeBadgeColor(value);
    final m = (month != null && month!.isNotEmpty)
        ? month!.toLowerCase().replaceAll('idmonth', '')
        : null;

    return MeleeShadeOption(
      name: value.toUpperCase(),
      colorName: cName,
      badgeColor: badge,
      matchingMonth: m,
      id: id,
      dcl: dcl,
      pId: pId,
    );
  }
}

class MelleApiTicker {
  final String id;
  final String page;
  final String message;

  const MelleApiTicker({
    required this.id,
    required this.page,
    required this.message,
  });

  factory MelleApiTicker.fromJson(Map<String, dynamic> json) {
    return MelleApiTicker(
      id: json['id']?.toString() ?? '',
      page: json['page']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  String get cleanMessage => stripHtmlTags(message);
}

String stripHtmlTags(String html) {
  if (html.isEmpty) return '';
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

Color resolveColorByName(String name) {
  switch (name.toLowerCase()) {
    case 'blue':
      return const Color(0xFF0D47A1);
    case 'green':
      return const Color(0xFF1B5E20);
    case 'yellow':
      return const Color(0xFFE5A910);
    case 'pink':
      return const Color(0xFFD81B60);
    case 'purple':
      return const Color(0xFF6A1B9A);
    case 'red':
      return const Color(0xFFB71C1C);
    case 'orange':
      return const Color(0xFFE65100);
    case 'black':
      return const Color(0xFF212121);
    case 'white':
      return const Color(0xFFCFD8DC);
    default:
      return const Color(0xFFD4AF37);
  }
}

String resolveColorNameFromPid(String pId) {
  switch (pId.toLowerCase()) {
    case 'idcolorblue':
      return 'Blue';
    case 'idcolorgreen':
      return 'Green';
    case 'idcoloryellow':
      return 'Yellow';
    case 'idcolorpink':
      return 'Pink';
    case 'idcolorpurple':
      return 'Purple';
    case 'idcolorred':
      return 'Red';
    case 'idcolororange':
      return 'Orange';
    case 'idcolorblack':
      return 'Black';
    case 'idcolorwhite':
      return 'White';
    default:
      return 'Blue';
  }
}

Color resolveShadeBadgeColor(String shadeValue) {
  final v = shadeValue.toUpperCase();
  if (v.contains('AQUA BLUE I') && !v.contains('II')) return const Color(0xFF4FC3F7);
  if (v.contains('AQUA BLUE II')) return const Color(0xFF29B6F6);
  if (v.contains('SKY BLUE')) return const Color(0xFF0288D1);
  if (v.contains('OCEAN BLUE')) return const Color(0xFF01579B);
  if (v.contains('ROYAL BLUE')) return const Color(0xFF0D47A1);
  if (v.contains('PINE GREEN')) return const Color(0xFF2E7D32);
  if (v.contains('ICE GREEN I') && !v.contains('II')) return const Color(0xFF81C784);
  if (v.contains('ICE GREEN II')) return const Color(0xFF66BB6A);
  if (v.contains('EMERALD GREEN')) return const Color(0xFF1B5E20);
  if (v.contains('FOREST GREEN')) return const Color(0xFF004D40);
  if (v.contains('CANARY')) return const Color(0xFFFDD835);
  if (v.contains('GOLDEN')) return const Color(0xFFFFB300);
  if (v.contains('BABY PINK')) return const Color(0xFFF48FB1);
  if (v.contains('ROSE PINK')) return const Color(0xFFD81B60);
  if (v.contains('PURPLISH PINK')) return const Color(0xFFBA68C8);
  if (v.contains('PURPLE')) return const Color(0xFF6A1B9A);
  if (v.contains('REDDISH COGNAC')) return const Color(0xFFB71C1C);
  if (v.contains('ORANGISH COGNAC')) return const Color(0xFFE65100);
  if (v.contains('BLACK')) return const Color(0xFF212121);
  if (v.contains('WHITE')) return const Color(0xFFECEFF1);
  return const Color(0xFFD4AF37);
}

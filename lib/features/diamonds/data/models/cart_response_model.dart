import '../../domain/entities/cart_response.dart';

class SolitaireCartItemModel extends SolitaireCartItem {
  const SolitaireCartItemModel({
    required super.cartId,
    required super.stockId,
    required super.serialNo,
    required super.lab,
    required super.certNumber,
    required super.shape,
    required super.weight,
    required super.color,
    required super.grade,
    required super.cut,
    required super.polish,
    required super.symmetry,
    required super.fluorescence,
    required super.imageUrl,
    required super.pricePerCts,
    required super.available,
  });

  factory SolitaireCartItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        final cleaned = val.replaceAll(',', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    String parseString(dynamic val) {
      if (val == null) return '';
      return val.toString().trim();
    }

    double perCtPrice = parseDouble(json['N_CARAT']);
    if (perCtPrice == 0.0) perCtPrice = parseDouble(json['RETAIL_PRICE_PER_CTS']);
    if (perCtPrice == 0.0) perCtPrice = parseDouble(json['WHOLESALE_PRICE']);

    return SolitaireCartItemModel(
      cartId: parseString(json['cart_id']),
      stockId: parseString(json['stock_id']),
      serialNo: parseString(json['SN_SERIALNO']).isNotEmpty
          ? parseString(json['SN_SERIALNO'])
          : parseString(json['stock_id']),
      lab: parseString(json['SN_LAB']).toUpperCase(),
      certNumber: parseString(json['UDF4']),
      shape: parseString(json['shape_full']).toUpperCase(),
      weight: parseDouble(json['QT_WEIGHT']),
      color: parseString(json['SN_COLOR']),
      grade: parseString(json['SN_GRADE']).toUpperCase(),
      cut: parseString(json['cut_full']),
      polish: parseString(json['polish_ful'] ?? json['polish_full']),
      symmetry: parseString(json['symmetry_full']),
      fluorescence: parseString(json['fluor_full']),
      imageUrl: parseString(json['image_show'] ?? json['image']),
      pricePerCts: perCtPrice,
      available: parseInt(json['available']),
    );
  }
}

class CartResponseModel extends CartResponse {
  const CartResponseModel({
    required super.status,
    required super.message,
    required super.solitaireCartItems,
    required super.totalItems,
    super.emailInfo,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};

    final rawDCart = data['d_cart'] as List? ?? [];
    final dCartItems = rawDCart
        .map((item) => SolitaireCartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    SolitaireCartEmail? emailInfo;
    if (data['getEmail'] is Map<String, dynamic>) {
      final emailMap = data['getEmail'] as Map<String, dynamic>;
      emailInfo = SolitaireCartEmail(
        parentToEmail: (emailMap['parent_to_email'] ?? '').toString(),
        toEmail: (emailMap['to_email'] ?? '').toString(),
      );
    }

    int total = parseInt(data['total_item']);
    if (total == 0) total = dCartItems.length;

    return CartResponseModel(
      status: parseInt(json['status']),
      message: (json['message'] ?? '').toString(),
      solitaireCartItems: dCartItems,
      totalItems: total,
      emailInfo: emailInfo,
    );
  }
}

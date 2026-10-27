import '../../domain/entities/solitaire_index.dart';

class SolitaireColorModel extends SolitaireColor {
  const SolitaireColorModel({
    required super.id,
    required super.name,
    required super.value,
    required super.img,
  });

  factory SolitaireColorModel.fromJson(Map<String, dynamic> json) {
    return SolitaireColorModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      img: (json['img'] ?? '').toString(),
    );
  }
}

class SolitaireShadeModel extends SolitaireShade {
  const SolitaireShadeModel({
    required super.id,
    required super.name,
    required super.value,
    required super.dcl,
    required super.parentId,
  });

  factory SolitaireShadeModel.fromJson(Map<String, dynamic> json) {
    return SolitaireShadeModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      dcl: (json['dcl'] ?? '').toString(),
      parentId: (json['p_id'] ?? '').toString(),
    );
  }
}

class SolitaireShapeModel extends SolitaireShape {
  const SolitaireShapeModel({
    required super.id,
    required super.name,
    required super.value,
    required super.img,
  });

  factory SolitaireShapeModel.fromJson(Map<String, dynamic> json) {
    return SolitaireShapeModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      img: (json['img'] ?? '').toString(),
    );
  }
}

class SolitaireClarityModel extends SolitaireClarity {
  const SolitaireClarityModel({
    required super.id,
    required super.name,
    required super.value,
  });

  factory SolitaireClarityModel.fromJson(Map<String, dynamic> json) {
    return SolitaireClarityModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}

class SolitaireTickerModel extends SolitaireTicker {
  const SolitaireTickerModel({
    required super.id,
    required super.page,
    required super.message,
  });

  factory SolitaireTickerModel.fromJson(Map<String, dynamic> json) {
    return SolitaireTickerModel(
      id: (json['id'] ?? '').toString(),
      page: (json['page'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}

class SolitaireIndexModel extends SolitaireIndex {
  const SolitaireIndexModel({
    required super.status,
    required super.login,
    required super.isPriceHide,
    required super.ticker,
    required super.colors,
    required super.shades,
    required super.shapes,
    required super.clarities,
    required super.totalWishlist,
  });

  factory SolitaireIndexModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final rawTicker = json['ticker'] as List? ?? [];
    final rawColors = json['colors'] as List? ?? [];
    final rawShades = json['shades'] as List? ?? [];
    final rawShapes = json['shapes'] as List? ?? [];
    final rawClarities = json['clarities'] as List? ?? [];

    return SolitaireIndexModel(
      status: parseInt(json['status']),
      login: parseInt(json['login']),
      isPriceHide: parseInt(json['is_price_hide']),
      ticker: rawTicker.map((t) => SolitaireTickerModel.fromJson(t as Map<String, dynamic>)).toList(),
      colors: rawColors.map((c) => SolitaireColorModel.fromJson(c as Map<String, dynamic>)).toList(),
      shades: rawShades.map((s) => SolitaireShadeModel.fromJson(s as Map<String, dynamic>)).toList(),
      shapes: rawShapes.map((s) => SolitaireShapeModel.fromJson(s as Map<String, dynamic>)).toList(),
      clarities: rawClarities.map((c) => SolitaireClarityModel.fromJson(c as Map<String, dynamic>)).toList(),
      totalWishlist: parseInt(json['total_wishlist']),
    );
  }
}

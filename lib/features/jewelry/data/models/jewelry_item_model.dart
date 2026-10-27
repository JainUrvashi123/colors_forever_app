class JewelryItem {
  final String jewelryId;
  final String item;
  final String subItem;
  final String masterD;
  final String department;
  final String sec1;
  final String sec2;
  final String sec3;
  final String sec4;
  final String sec4A;
  final String goldKarat;
  final String goldColor;
  final String goldWeight;
  final String diamondClarity;
  final String diamondColor;
  final String totalDiamondWeight;
  final String centerDiamondWeight;
  final String quantity;
  final String tagPrice;
  final String wholePrice;
  final String? nTotal;
  final String description;
  final String stockId;
  final String? imageShow;
  final String? imageShow1;
  final String? imageShow2;
  final String? videoShow;

  const JewelryItem({
    required this.jewelryId,
    required this.item,
    required this.subItem,
    required this.masterD,
    required this.department,
    required this.sec1,
    required this.sec2,
    required this.sec3,
    required this.sec4,
    required this.sec4A,
    required this.goldKarat,
    required this.goldColor,
    required this.goldWeight,
    required this.diamondClarity,
    required this.diamondColor,
    required this.totalDiamondWeight,
    required this.centerDiamondWeight,
    required this.quantity,
    required this.tagPrice,
    required this.wholePrice,
    this.nTotal,
    required this.description,
    required this.stockId,
    this.imageShow,
    this.imageShow1,
    this.imageShow2,
    this.videoShow,
  });

  factory JewelryItem.fromJson(Map<String, dynamic> json) {
    return JewelryItem(
      jewelryId: json['jewelry_id']?.toString() ?? '',
      item: json['item']?.toString() ?? '',
      subItem: json['sub_item']?.toString() ?? '',
      masterD: json['master_d']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      sec1: json['sec_1']?.toString() ?? '',
      sec2: json['sec_2']?.toString() ?? '',
      sec3: json['sec_3']?.toString() ?? '',
      sec4: json['sec_4']?.toString() ?? '',
      sec4A: json['sec_4A']?.toString() ?? '',
      goldKarat: json['gold_karat']?.toString() ?? '',
      goldColor: json['gold_color']?.toString() ?? '',
      goldWeight: json['gold_weight']?.toString() ?? '',
      diamondClarity: json['diamond_clarity']?.toString() ?? '',
      diamondColor: json['diamond_color']?.toString() ?? '',
      totalDiamondWeight: json['total_diamond_weight']?.toString() ?? '0',
      centerDiamondWeight: json['center_diamond_weight']?.toString() ?? '0',
      quantity: json['quantity']?.toString() ?? '1',
      tagPrice: json['tag_price']?.toString() ?? '0',
      wholePrice: json['whole_price']?.toString() ?? '0',
      nTotal: json['N_TOTAL']?.toString(),
      description: json['description']?.toString() ?? '',
      stockId: json['stock_id']?.toString() ?? '',
      imageShow: json['image_show']?.toString(),
      imageShow1: json['image_show_1']?.toString(),
      imageShow2: json['image_show_2']?.toString(),
      videoShow: json['video_show']?.toString(),
    );
  }

  double get parsedPrice {
    if (nTotal != null && nTotal!.isNotEmpty) {
      final cleanN = nTotal!.replaceAll(RegExp(r'[^0-9.]'), '');
      final valN = double.tryParse(cleanN);
      if (valN != null && valN > 0) return valN;
    }
    final cleanTag = tagPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final valTag = double.tryParse(cleanTag);
    if (valTag != null && valTag > 0) return valTag;

    final cleanWhole = wholePrice.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanWhole) ?? 0.0;
  }

  double get parsedCarat {
    final clean = totalDiamondWeight.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  String get displayTitle {
    if (description.isNotEmpty) return description;
    final parts = <String>[];
    if (goldKarat.isNotEmpty) parts.add(goldKarat);
    if (goldColor.isNotEmpty) parts.add(goldColor);
    if (sec1.isNotEmpty) parts.add(sec1);
    if (department.isNotEmpty) parts.add(department);
    return parts.isEmpty ? item : parts.join(' ');
  }
}

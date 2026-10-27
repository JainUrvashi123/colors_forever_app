class JewelryDepartmentCategory {
  final String department;
  final List<String> subCategories;

  const JewelryDepartmentCategory({
    required this.department,
    required this.subCategories,
  });

  factory JewelryDepartmentCategory.fromJson(Map<String, dynamic> json) {
    final dept = json['department']?.toString() ?? '';
    final secList = json['sec_1'] as List? ?? [];
    final subs = secList
        .map((e) => (e as Map<String, dynamic>)['sec_1']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return JewelryDepartmentCategory(
      department: dept,
      subCategories: subs,
    );
  }
}

class JewelryIndexFilterItem {
  final String label;
  final String? goldKarat;
  final String? goldColor;
  final String? diamondColor;
  final String? item;

  const JewelryIndexFilterItem({
    required this.label,
    this.goldKarat,
    this.goldColor,
    this.diamondColor,
    this.item,
  });

  factory JewelryIndexFilterItem.fromJson(Map<String, dynamic> json, String labelKey) {
    return JewelryIndexFilterItem(
      label: json[labelKey]?.toString() ?? '',
      goldKarat: json['gold_karat']?.toString(),
      goldColor: json['gold_color']?.toString(),
      diamondColor: json['diamond_color']?.toString(),
      item: json['item']?.toString(),
    );
  }
}

class JewelryIndexResponse {
  final List<JewelryDepartmentCategory> categories;
  final List<JewelryIndexFilterItem> sizes;
  final List<JewelryIndexFilterItem> metalTypes;
  final List<JewelryIndexFilterItem> metalColors;
  final List<JewelryIndexFilterItem> diamondColors;
  final List<JewelryIndexFilterItem> styleSettings;
  final String titleHead;

  const JewelryIndexResponse({
    required this.categories,
    required this.sizes,
    required this.metalTypes,
    required this.metalColors,
    required this.diamondColors,
    required this.styleSettings,
    required this.titleHead,
  });

  static const JewelryIndexResponse empty = JewelryIndexResponse(
    categories: [],
    sizes: [],
    metalTypes: [],
    metalColors: [],
    diamondColors: [],
    styleSettings: [],
    titleHead: 'Jewelry',
  );

  factory JewelryIndexResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final catList = (data['category'] as List? ?? [])
        .map((e) => JewelryDepartmentCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    final sizesList = (data['size'] as List? ?? [])
        .map((e) => JewelryIndexFilterItem.fromJson(e as Map<String, dynamic>, 'sub_item'))
        .toList();

    final metalTypesList = (data['metal_type'] as List? ?? [])
        .map((e) => JewelryIndexFilterItem.fromJson(e as Map<String, dynamic>, 'gold_karat_filter'))
        .toList();

    final metalColorsList = (data['metal_color'] as List? ?? [])
        .map((e) => JewelryIndexFilterItem.fromJson(e as Map<String, dynamic>, 'gold_color_filter'))
        .toList();

    final diamondColorsList = (data['diamond_color'] as List? ?? [])
        .map((e) => JewelryIndexFilterItem.fromJson(e as Map<String, dynamic>, 'diamond_color_filter'))
        .toList();

    final styleSettingsList = (data['style_setting'] as List? ?? [])
        .map((e) => JewelryIndexFilterItem.fromJson(e as Map<String, dynamic>, 'style_setting'))
        .toList();

    return JewelryIndexResponse(
      categories: catList,
      sizes: sizesList,
      metalTypes: metalTypesList,
      metalColors: metalColorsList,
      diamondColors: diamondColorsList,
      styleSettings: styleSettingsList,
      titleHead: data['title_head']?.toString() ?? 'Jewelry',
    );
  }
}

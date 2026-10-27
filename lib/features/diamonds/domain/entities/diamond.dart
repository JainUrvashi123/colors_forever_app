class Diamond {
  final String serialNo;
  final String shape;
  final double weight;
  final String color;
  final String labColor;
  final String grade; // Clarity
  final String cut;
  final String polish;
  final String symmetry;
  final String fluorescence;
  final double depth;
  final double table;
  final double retailPricePerCts;
  final double totalRetailPrice;
  final double wholesalePrice;
  final double totalWholesalePrice;
  final String lab;
  final String certNumber;
  final String measurements;
  final String location;
  final String imageUrl;
  final String videoUrl;
  final String certUrl;
  final bool isFavorite;
  final List<String> imageArray;
  final List<String> videoArray;
  final List<String> certificateArray;
  final List<Diamond> similarDiamonds;

  const Diamond({
    required this.serialNo,
    required this.shape,
    required this.weight,
    required this.color,
    required this.labColor,
    required this.grade,
    required this.cut,
    required this.polish,
    required this.symmetry,
    required this.fluorescence,
    required this.depth,
    required this.table,
    required this.retailPricePerCts,
    required this.totalRetailPrice,
    required this.wholesalePrice,
    required this.totalWholesalePrice,
    required this.lab,
    required this.certNumber,
    required this.measurements,
    required this.location,
    required this.imageUrl,
    required this.videoUrl,
    required this.certUrl,
    this.isFavorite = false,
    this.imageArray = const [],
    this.videoArray = const [],
    this.certificateArray = const [],
    this.similarDiamonds = const [],
  });

  double get wholesalePricePerCts => wholesalePrice;

  Diamond copyWith({
    String? serialNo,
    String? shape,
    double? weight,
    String? color,
    String? labColor,
    String? grade,
    String? cut,
    String? polish,
    String? symmetry,
    String? fluorescence,
    double? depth,
    double? table,
    double? retailPricePerCts,
    double? totalRetailPrice,
    double? wholesalePrice,
    double? totalWholesalePrice,
    String? lab,
    String? certNumber,
    String? measurements,
    String? location,
    String? imageUrl,
    String? videoUrl,
    String? certUrl,
    bool? isFavorite,
    List<String>? imageArray,
    List<String>? videoArray,
    List<String>? certificateArray,
    List<Diamond>? similarDiamonds,
  }) {
    return Diamond(
      serialNo: serialNo ?? this.serialNo,
      shape: shape ?? this.shape,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      labColor: labColor ?? this.labColor,
      grade: grade ?? this.grade,
      cut: cut ?? this.cut,
      polish: polish ?? this.polish,
      symmetry: symmetry ?? this.symmetry,
      fluorescence: fluorescence ?? this.fluorescence,
      depth: depth ?? this.depth,
      table: table ?? this.table,
      retailPricePerCts: retailPricePerCts ?? this.retailPricePerCts,
      totalRetailPrice: totalRetailPrice ?? this.totalRetailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      totalWholesalePrice: totalWholesalePrice ?? this.totalWholesalePrice,
      lab: lab ?? this.lab,
      certNumber: certNumber ?? this.certNumber,
      measurements: measurements ?? this.measurements,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      certUrl: certUrl ?? this.certUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      imageArray: imageArray ?? this.imageArray,
      videoArray: videoArray ?? this.videoArray,
      certificateArray: certificateArray ?? this.certificateArray,
      similarDiamonds: similarDiamonds ?? this.similarDiamonds,
    );
  }
}

import '../../domain/entities/diamond.dart';

class DiamondModel extends Diamond {
  const DiamondModel({
    required super.serialNo,
    required super.shape,
    required super.weight,
    required super.color,
    required super.labColor,
    required super.grade,
    required super.cut,
    required super.polish,
    required super.symmetry,
    required super.fluorescence,
    required super.depth,
    required super.table,
    required super.retailPricePerCts,
    required super.totalRetailPrice,
    required super.wholesalePrice,
    required super.totalWholesalePrice,
    required super.lab,
    required super.certNumber,
    required super.measurements,
    required super.location,
    required super.imageUrl,
    required super.videoUrl,
    required super.certUrl,
    super.isFavorite,
    super.imageArray,
    super.videoArray,
    super.certificateArray,
    super.similarDiamonds,
  });

  factory DiamondModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        final cleaned = val.replaceAll(',', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    String parseString(dynamic val) {
      if (val == null) return '';
      return val.toString().trim();
    }

    final serial = parseString(json['SN_SERIALNO']);
    var imgUrl = parseString(json['image_show']);
    if (imgUrl.isEmpty) {
      imgUrl = parseString(json['image']);
    }

    var videoUrl = parseString(json['video_show']);
    if (videoUrl.isEmpty) {
      videoUrl = parseString(json['video']);
    }

    var certUrl = parseString(json['cert_show']);
    if (certUrl.isEmpty) {
      certUrl = parseString(json['cert']);
    }

    final weightVal = parseDouble(json['QT_WEIGHT']);

    final nTotal = parseDouble(json['N_TOTAL']);
    final nCarat = parseDouble(json['N_CARAT']);

    double totalRetail = nTotal > 0.0 ? nTotal : parseDouble(json['TOTAL_RETAIL_PRICE']);
    if (totalRetail == 0.0) totalRetail = parseDouble(json['TOTAL_PRICE']);

    double totalWholesale = nTotal > 0.0 ? nTotal : parseDouble(json['TOTAL_WHOLESALE_PRICE']);
    if (totalWholesale == 0.0) totalWholesale = parseDouble(json['PRICE_B']);

    double retailPerCts = nCarat > 0.0 ? nCarat : parseDouble(json['RETAIL_PRICE_PER_CTS']);
    double wholesalePerCts = nCarat > 0.0 ? nCarat : parseDouble(json['WHOLESALE_PRICE']);

    // Perform smart reciprocal calculations if per-carat or total values are missing
    if (retailPerCts == 0.0 && totalRetail > 0.0 && weightVal > 0.0) {
      retailPerCts = totalRetail / weightVal;
    } else if (totalRetail == 0.0 && retailPerCts > 0.0 && weightVal > 0.0) {
      totalRetail = retailPerCts * weightVal;
    }

    if (wholesalePerCts == 0.0 && totalWholesale > 0.0 && weightVal > 0.0) {
      wholesalePerCts = totalWholesale / weightVal;
    } else if (totalWholesale == 0.0 && wholesalePerCts > 0.0 && weightVal > 0.0) {
      totalWholesale = wholesalePerCts * weightVal;
    }

    return DiamondModel(
      serialNo: serial,
      shape: parseString(json['shape_full']).toUpperCase(),
      weight: weightVal,
      color: parseString(json['SN_COLOR']),
      labColor: parseString(json['LAB_COLOR']),
      grade: parseString(json['SN_GRADE']).toUpperCase(),
      cut: parseString(json['cut_full']),
      polish: parseString(json['polish_full']),
      symmetry: parseString(json['symmetry_full']),
      fluorescence: parseString(json['fluor_full']),
      depth: parseDouble(json['PC_DEPTH']),
      table: parseDouble(json['PC_TABLE']),
      retailPricePerCts: retailPerCts,
      totalRetailPrice: totalRetail,
      wholesalePrice: wholesalePerCts,
      totalWholesalePrice: totalWholesale,
      lab: parseString(json['SN_LAB']).toUpperCase(),
      certNumber: parseString(json['UDF4']),
      measurements: parseString(json['MEAS']),
      location: parseString(json['LOCATION']).toUpperCase(),
      imageUrl: imgUrl,
      videoUrl: videoUrl,
      certUrl: certUrl,
      isFavorite: json['is_fav'] == 1 || json['is_fav'] == true || json['is_fav'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SN_SERIALNO': serialNo,
      'shape_full': shape,
      'QT_WEIGHT': weight,
      'SN_COLOR': color,
      'LAB_COLOR': labColor,
      'SN_GRADE': grade,
      'cut_full': cut,
      'polish_full': polish,
      'symmetry_full': symmetry,
      'fluor_full': fluorescence,
      'PC_DEPTH': depth,
      'PC_TABLE': table,
      'RETAIL_PRICE_PER_CTS': retailPricePerCts,
      'TOTAL_RETAIL_PRICE': totalRetailPrice,
      'WHOLESALE_PRICE': wholesalePrice,
      'TOTAL_WHOLESALE_PRICE': totalWholesalePrice,
      'SN_LAB': lab,
      'UDF4': certNumber,
      'MEAS': measurements,
      'LOCATION': location,
      'image_show': imageUrl,
      'video_show': videoUrl,
      'cert_show': certUrl,
      'is_fav': isFavorite ? 1 : 0,
    };
  }
}

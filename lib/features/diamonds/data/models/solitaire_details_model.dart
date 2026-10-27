import '../../domain/entities/solitaire_details.dart';
import 'diamond_model.dart';

class SolitaireDetailsModel extends SolitaireDetails {
  const SolitaireDetailsModel({
    required super.diamond,
    required super.similarDiamonds,
    required super.imageArray,
    required super.videoArray,
    required super.certificateArray,
    required super.isPriceHide,
    required super.login,
  });

  factory SolitaireDetailsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};

    final rawRecords = data['records'] as List? ?? [];
    final mainModel = rawRecords.isNotEmpty
        ? DiamondModel.fromJson(rawRecords.first as Map<String, dynamic>)
        : const DiamondModel(
            serialNo: '',
            shape: '',
            weight: 0,
            color: '',
            labColor: '',
            grade: '',
            cut: '',
            polish: '',
            symmetry: '',
            fluorescence: '',
            depth: 0,
            table: 0,
            retailPricePerCts: 0,
            totalRetailPrice: 0,
            wholesalePrice: 0,
            totalWholesalePrice: 0,
            lab: '',
            certNumber: '',
            measurements: '',
            location: '',
            imageUrl: '',
            videoUrl: '',
            certUrl: '',
          );

    final rawSimilar = data['similar_records'] as List? ?? [];
    final similarModels = rawSimilar
        .map((item) => DiamondModel.fromJson(item as Map<String, dynamic>))
        .toList();

    List<String> parseStringList(dynamic rawList) {
      if (rawList is List) {
        return rawList.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    final images = parseStringList(data['image_array']);
    final videos = parseStringList(data['video_array']);
    final certs = parseStringList(data['certificate_array']);

    // Enrich main diamond with gallery lists if present
    final enrichedDiamond = mainModel.copyWith(
      imageArray: images.isNotEmpty ? images : (mainModel.imageUrl.isNotEmpty ? [mainModel.imageUrl] : []),
      videoArray: videos.isNotEmpty ? videos : (mainModel.videoUrl.isNotEmpty ? [mainModel.videoUrl] : []),
      certificateArray: certs.isNotEmpty ? certs : (mainModel.certUrl.isNotEmpty ? [mainModel.certUrl] : []),
      similarDiamonds: similarModels,
    );

    return SolitaireDetailsModel(
      diamond: enrichedDiamond,
      similarDiamonds: similarModels,
      imageArray: images,
      videoArray: videos,
      certificateArray: certs,
      isPriceHide: parseInt(data['is_price_hide'] ?? json['is_price_hide']),
      login: parseInt(data['login'] ?? json['login']),
    );
  }
}

import '../datasources/melee_remote_data_source.dart';
import '../../domain/models/melee_model.dart';

class MeleeRepository {
  final MeleeRemoteDataSource remoteDataSource;

  MeleeRepository({MeleeRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? MeleeRemoteDataSource();

  final Map<String, List<String>> _sizesCache = {};
  final Map<String, List<String>> _gradesCache = {};
  MelleIndexResponse? _melleIndexCache;

  Future<MelleIndexResponse> getMelleIndex({bool forceRefresh = false}) async {
    if (!forceRefresh && _melleIndexCache != null) {
      return _melleIndexCache!;
    }
    final response = await remoteDataSource.fetchMelleIndex();
    _melleIndexCache = response;
    return response;
  }

  Future<List<String>> getSizes({
    required String color,
    required String shade,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    final cacheKey = '$color|$shade|${stoneType.name}|$month';
    if (_sizesCache.containsKey(cacheKey)) {
      return _sizesCache[cacheKey]!;
    }
    final sizes = await remoteDataSource.fetchSizes(
      color: color,
      shade: shade,
      stoneType: stoneType,
      month: month,
    );
    _sizesCache[cacheKey] = sizes;
    return sizes;
  }

  Future<List<String>> getGrades({
    required String color,
    required String shade,
    required String size,
    required MeleeStoneType stoneType,
    String? month,
  }) async {
    final cacheKey = '$color|$shade|$size|${stoneType.name}|$month';
    if (_gradesCache.containsKey(cacheKey)) {
      return _gradesCache[cacheKey]!;
    }
    final grades = await remoteDataSource.fetchGrades(
      color: color,
      shade: shade,
      size: size,
      stoneType: stoneType,
      month: month,
    );
    _gradesCache[cacheKey] = grades;
    return grades;
  }

  Future<MeleeCalculationResult> calculateParcel({
    required String color,
    required String shade,
    required String size,
    required String grade,
    required int quantity,
    required MeleeStoneType stoneType,
    String? month,
  }) {
    return remoteDataSource.fetchItemEstimate(
      color: color,
      shade: shade,
      size: size,
      grade: grade,
      quantity: quantity,
      stoneType: stoneType,
      month: month,
    );
  }

  Future<MeleePreviewData?> getPreview({
    required String color,
    required String shade,
    required MeleeStoneType stoneType,
    String? month,
  }) {
    return remoteDataSource.fetchPreview(
      color: color,
      shade: shade,
      stoneType: stoneType,
      month: month,
    );
  }

  Future<Map<String, dynamic>> addMelleCart({
    required String color,
    required String shade,
    required String size,
    required String grade,
    required int quantity,
    required String specialRequest,
    required MeleeStoneType stoneType,
    String? month,
  }) {
    return remoteDataSource.addMelleCart(
      color: color,
      shade: shade,
      size: size,
      grade: grade,
      quantity: quantity,
      specialRequest: specialRequest,
      stoneType: stoneType,
      month: month,
    );
  }

  Future<Map<String, dynamic>> removeMelleCart({required String cartId}) {
    return remoteDataSource.removeMelleCart(cartId: cartId);
  }

  Future<Map<String, dynamic>> emailMelleCart({
    required String recEmail,
    required String message,
  }) {
    return remoteDataSource.emailMelleCart(
      recEmail: recEmail,
      message: message,
    );
  }

  Future<Map<String, dynamic>> placeMelleOrder({
    required String contactPerson,
    required String message,
    required String shippingOption,
    required String shippingAddress,
    String? recEmail,
  }) {
    return remoteDataSource.placeMelleOrder(
      contactPerson: contactPerson,
      message: message,
      shippingOption: shippingOption,
      shippingAddress: shippingAddress,
      recEmail: recEmail,
    );
  }
}

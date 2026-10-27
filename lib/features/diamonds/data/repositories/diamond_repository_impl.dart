import 'package:flutter/foundation.dart';
import '../../domain/entities/diamond_filter.dart';
import '../../domain/entities/solitaire_index.dart';
import '../../domain/entities/solitaire_details.dart';
import '../../domain/entities/cart_response.dart';
import '../../domain/repositories/diamond_repository.dart';
import '../datasources/diamond_remote_data_source.dart';
import '../datasources/diamond_local_data_source.dart';

class DiamondRepositoryImpl implements DiamondRepository {
  final DiamondRemoteDataSource remoteDataSource;
  final DiamondLocalDataSource localDataSource;

  DiamondRepositoryImpl({
    DiamondRemoteDataSource? remoteDataSource,
    DiamondLocalDataSource? localDataSource,
  })  : remoteDataSource = remoteDataSource ?? DiamondRemoteDataSource(),
        localDataSource = localDataSource ?? DiamondLocalDataSource();

  @override
  Future<SolitaireIndex> getSolitaireIndex() async {
    try {
      return await remoteDataSource.fetchSolitaireIndex();
    } catch (_) {
      return await localDataSource.getSolitaireIndex();
    }
  }

  @override
  Future<DiamondCatalogResult> getDiamonds({
    required DiamondFilter filter,
    int page = 1,
    int perPage = 16,
  }) async {
    try {
      final remoteResult = await remoteDataSource.fetchDiamonds(
        filter: filter,
        page: page,
        perPage: perPage,
      );
      return DiamondCatalogResult(
        diamonds: remoteResult.records,
        totalRecords: remoteResult.totalRecords,
        isFromCache: false,
      );
    } catch (e, stack) {
      debugPrint('DiamondRepositoryImpl: fetchDiamonds error => $e\n$stack');
      final localResult = await localDataSource.getFilteredDiamonds(
        filter: filter,
        page: page,
        perPage: perPage,
      );
      return DiamondCatalogResult(
        diamonds: localResult.records,
        totalRecords: localResult.totalRecords,
        isFromCache: true,
      );
    }
  }

  @override
  Future<SolitaireDetails> getDiamondDetails(String inventoryId, {String? vdGroupId}) async {
    try {
      return await remoteDataSource.fetchDiamondDetails(inventoryId, vdGroupId: vdGroupId);
    } catch (_) {
      return await localDataSource.getDiamondDetails(inventoryId, vdGroupId: vdGroupId);
    }
  }

  @override
  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds) async {
    try {
      return await remoteDataSource.addToCart(inventoryIds);
    } catch (_) {
      return await localDataSource.addToCart(inventoryIds);
    }
  }

  @override
  Future<CartResponse> getCart({String? userId}) async {
    try {
      return await remoteDataSource.fetchCart(userId: userId);
    } catch (_) {
      return await localDataSource.fetchCart(userId: userId);
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCart({
    required List<String> cartIds,
    String? userId,
  }) async {
    try {
      return await remoteDataSource.deleteCart(cartIds: cartIds, userId: userId);
    } catch (_) {
      return await localDataSource.deleteCart(cartIds: cartIds, userId: userId);
    }
  }

  @override
  Future<Map<String, dynamic>> sendCartEmail({
    required String targetCart,
    required String requestType,
    required String recEmail,
    String contactPerson = '',
    String type = '',
    String shippingOption = '',
    String message = '',
    String markupD = '10',
    String? userId,
    String? groupId,
  }) async {
    try {
      return await remoteDataSource.sendCartEmail(
        targetCart: targetCart,
        requestType: requestType,
        recEmail: recEmail,
        contactPerson: contactPerson,
        type: type,
        shippingOption: shippingOption,
        message: message,
        markupD: markupD,
        userId: userId,
        groupId: groupId,
      );
    } catch (_) {
      return await localDataSource.sendCartEmail(
        targetCart: targetCart,
        requestType: requestType,
        recEmail: recEmail,
        contactPerson: contactPerson,
        type: type,
        shippingOption: shippingOption,
        message: message,
        markupD: markupD,
        userId: userId,
        groupId: groupId,
      );
    }
  }
}

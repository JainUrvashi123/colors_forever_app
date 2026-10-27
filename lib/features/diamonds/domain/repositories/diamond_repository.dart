import '../entities/diamond.dart';
import '../entities/diamond_filter.dart';
import '../entities/solitaire_index.dart';
import '../entities/solitaire_details.dart';
import '../entities/cart_response.dart';

class DiamondCatalogResult {
  final List<Diamond> diamonds;
  final int totalRecords;
  final bool isFromCache;

  const DiamondCatalogResult({
    required this.diamonds,
    required this.totalRecords,
    this.isFromCache = false,
  });
}

abstract class DiamondRepository {
  Future<SolitaireIndex> getSolitaireIndex();

  Future<DiamondCatalogResult> getDiamonds({
    required DiamondFilter filter,
    int page = 1,
    int perPage = 16,
  });

  Future<SolitaireDetails> getDiamondDetails(String inventoryId, {String? vdGroupId});

  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds);

  Future<CartResponse> getCart({String? userId});

  Future<Map<String, dynamic>> deleteCart({
    required List<String> cartIds,
    String? userId,
  });

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
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/views/solitaire_catalog_screen.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_filter_provider.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/features/diamonds/domain/repositories/diamond_repository.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/diamond.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/diamond_filter.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/solitaire_index.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/solitaire_details.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/cart_response.dart';

class MockDiamondRepository implements DiamondRepository {
  final List<Diamond> testDiamonds;

  MockDiamondRepository(this.testDiamonds);

  @override
  Future<DiamondCatalogResult> getDiamonds({
    required DiamondFilter filter,
    int page = 1,
    int perPage = 16,
  }) async {
    return DiamondCatalogResult(
      diamonds: testDiamonds,
      totalRecords: testDiamonds.length,
      isFromCache: false,
    );
  }

  @override
  Future<SolitaireIndex> getSolitaireIndex() async {
    return SolitaireIndex.empty;
  }

  @override
  Future<SolitaireDetails> getDiamondDetails(String inventoryId, {String? vdGroupId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> addToCart(List<String> inventoryIds) async {
    return {'status': 1, 'message': 'Added to cart'};
  }

  @override
  Future<CartResponse> getCart({String? userId}) async {
    return CartResponse.empty;
  }

  @override
  Future<Map<String, dynamic>> deleteCart({
    required List<String> cartIds,
    String? userId,
  }) async {
    return {'status': 1, 'message': 'Deleted'};
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
    return {'status': 1, 'message': 'Emailed'};
  }
}

void main() {
  testWidgets('WhatsApp share button shows warning SnackBar when 0 diamonds are selected', (tester) async {
    final mockRepo = MockDiamondRepository([
      const Diamond(
        serialNo: 'TEST-001',
        shape: 'ROUND',
        weight: 1.0,
        color: 'BLUE',
        labColor: 'NATURAL BLUE',
        grade: 'VS1',
        cut: 'Ideal',
        polish: 'EX',
        symmetry: 'EX',
        fluorescence: 'NONE',
        depth: 61.0,
        table: 57.0,
        retailPricePerCts: 1000.0,
        totalRetailPrice: 1000.0,
        wholesalePrice: 900.0,
        totalWholesalePrice: 900.0,
        lab: 'GIA',
        certNumber: '123456',
        measurements: '6.5x6.5x4.0',
        location: 'NY',
        imageUrl: '',
        videoUrl: '',
        certUrl: '',
      ),
    ]);

    final catalogProvider = DiamondCatalogProvider(repository: mockRepo);
    final filterProvider = DiamondFilterProvider();
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DiamondCatalogProvider>.value(value: catalogProvider),
          ChangeNotifierProvider<DiamondFilterProvider>.value(value: filterProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: SolitaireCatalogScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 1 diamond loaded
    expect(find.textContaining('1 Solitaire Diamonds Available'), findsOneWidget);

    // Tap WhatsApp share icon in toolbar without selecting any diamond
    final whatsappBtn = find.byTooltip('Share via WhatsApp');
    expect(whatsappBtn, findsOneWidget);
    await tester.tap(whatsappBtn);
    await tester.pump();

    // Verify SnackBar appears saying "Please select at least one diamond first."
    expect(find.text('Please select at least one diamond first.'), findsOneWidget);

    // Verify WhatsAppShareDialog is NOT opened
    expect(find.text('Share to WhatsApp'), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/features/melee/domain/models/melee_model.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';
import 'package:colors_forever_app/features/melee/data/repositories/melee_repository.dart';
import 'package:colors_forever_app/features/melee/data/datasources/melee_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Melee Cart Persistence & API Sync Tests', () {
    test('MeleeCartItem serializes to and from JSON accurately', () {
      final item = MeleeCartItem(
        id: 'cart-123',
        stoneType: MeleeStoneType.melee,
        color: 'Green',
        shade: 'EMERALD GREEN',
        size: '0.9 MM',
        clarity: 'VVS1-VS2',
        quantity: 5,
        pricePerCarat: r'$940',
        wtFrom: '0.0150',
        wtTo: '0.0250',
        priceFrom: r'$14.10',
        priceTo: r'$23.50',
        specialRequest: 'Special request note',
      );

      final jsonMap = item.toJson();
      expect(jsonMap['id'], 'cart-123');
      expect(jsonMap['stoneType'], 'melee');
      expect(jsonMap['color'], 'Green');
      expect(jsonMap['shade'], 'EMERALD GREEN');
      expect(jsonMap['quantity'], 5);

      final restored = MeleeCartItem.fromJson(jsonMap);
      expect(restored.id, 'cart-123');
      expect(restored.color, 'Green');
      expect(restored.shade, 'EMERALD GREEN');
      expect(restored.size, '0.9 MM');
      expect(restored.clarity, 'VVS1-VS2');
      expect(restored.quantity, 5);
      expect(restored.specialRequest, 'Special request note');
    });

    test('Adding item to Melee cart saves to local storage and invokes melle_add_cart API', () async {
      bool apiCalled = false;
      final mockClient = MockClient((request) async {
        if (request.url.toString() == MeleeRemoteDataSource.melleGetAttributeUrl && request.body.contains('attrType=cart')) {
          apiCalled = true;
          return http.Response(
            '{"status": 1, "message": "Attribute data fetched successfully", "data": {"item": "server-999", "cart_total_value": {"total_wt_from": "0.015", "total_wt_to": "0.025", "total_price_from": "15.00", "total_price_to": "25.00"}}}',
            200,
          );
        }
        return http.Response('{"status": 1}', 200);
      });

      final repo = MeleeRepository(
        remoteDataSource: MeleeRemoteDataSource(client: mockClient),
      );

      final provider = MeleeProvider(repository: repo, autoLoad: false);
      provider.selectColor('Green');
      provider.selectShade('EMERALD GREEN');
      provider.selectSize('0.9 MM');
      provider.selectGrade('VVS1-VS2');
      provider.setQuantity(5);
      provider.setSpecialRequest('Special request note');

      final success = provider.addToCart();
      expect(success, true);
      expect(provider.cartCount, 1);

      // Allow microtask async API call to execute
      await Future.delayed(Duration.zero);
      expect(apiCalled, true);

      // Verify item was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('melee_cart_items_cache');
      expect(savedStr, isNotNull);
      expect(savedStr, contains('EMERALD GREEN'));

      // Simulate App Restart with a new provider instance
      final restartedProvider = MeleeProvider(repository: repo, autoLoad: false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(restartedProvider.cartCount, 1);
      expect(restartedProvider.cartItems.first.shade, 'EMERALD GREEN');
      expect(restartedProvider.cartItems.first.quantity, 5);
    });
  });
}

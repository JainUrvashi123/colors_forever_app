import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:colors_forever_app/features/melee/data/datasources/melee_remote_data_source.dart';
import 'package:colors_forever_app/features/melee/data/repositories/melee_repository.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';

void main() {
  const removeResponseJson = '''
{
    "status": 1,
    "message": "Cart item removed successfully",
    "cart_total_value": {
        "total_wt_from": "0.0000",
        "total_wt_to": "0.0000",
        "total_price_from": "0.00",
        "total_price_to": "0.00"
    }
}
''';

  group('Melle Remove Cart API Integration Tests', () {
    test('removeMelleCart posts cart_id payload to melle_remove_cart endpoint', () async {
      late String postedUrl;
      late String postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = request.body;
        return http.Response(removeResponseJson, 200, headers: {'content-type': 'application/json'});
      });

      final dataSource = MeleeRemoteDataSource(client: mockClient);
      final res = await dataSource.removeMelleCart(cartId: '25');

      expect(postedUrl, 'https://colorsforever.com/api/melle_remove_cart');
      expect(json.decode(postedBody), {'cart_id': '25'});
      expect(res['status'], 1);
      expect(res['message'], 'Cart item removed successfully');
      expect(res['cart_total_value']['total_price_from'], '0.00');
    });

    test('MeleeRepository removeMelleCart delegates to remote data source', () async {
      final mockClient = MockClient((request) async {
        return http.Response(removeResponseJson, 200, headers: {'content-type': 'application/json'});
      });

      final repository = MeleeRepository(
        remoteDataSource: MeleeRemoteDataSource(client: mockClient),
      );

      final res = await repository.removeMelleCart(cartId: '25');
      expect(res['status'], 1);
      expect(res['message'], 'Cart item removed successfully');
    });

    test('MeleeProvider removeFromCart calls API and updates cart items and totals', () async {
      final mockClient = MockClient((request) async {
        return http.Response(removeResponseJson, 200, headers: {'content-type': 'application/json'});
      });

      final provider = MeleeProvider(
        repository: MeleeRepository(
          remoteDataSource: MeleeRemoteDataSource(client: mockClient),
        ),
        autoLoad: false,
      );

      // Populate test cart item
      provider.selectColor('Green');
      provider.selectShade('EMERALD GREEN');
      provider.selectSize('0.8 MM');
      provider.selectGrade('VS2-SI2');
      provider.setQuantity(2);
      provider.addToCart();

      expect(provider.cartCount, 1);
      final item = provider.cartItems.first;

      final res = await provider.removeFromCart(item.id);

      expect(provider.cartCount, 0);
      expect(res['status'], 1);
      expect(res['message'], 'Cart item removed successfully');
      expect(provider.serverCartTotal?.totalPriceFrom, '0.00');
    });
  });

  group('Melle Email Cart API Integration Tests', () {
    test('emailMelleCart posts rec_email and message payload to melle_email_cart endpoint', () async {
      late String postedUrl;
      late String postedBody;

      const emailResponseJson = '''
{
    "status": 1,
    "message": "Cart emailed successfully"
}
''';

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = request.body;
        return http.Response(emailResponseJson, 200, headers: {'content-type': 'application/json'});
      });

      final dataSource = MeleeRemoteDataSource(client: mockClient);
      final res = await dataSource.emailMelleCart(
        recEmail: 'urvashi@braintreeproducts.com',
        message: 'Please check this Melle diamond cart.',
      );

      expect(postedUrl, 'https://colorsforever.com/api/melle_email_cart');
      expect(json.decode(postedBody), {
        'rec_email': 'urvashi@braintreeproducts.com',
        'message': 'Please check this Melle diamond cart.',
      });
      expect(res['status'], 1);
      expect(res['message'], 'Cart emailed successfully');
    });

    test('MeleeProvider emailCart delegates email request to repository', () async {
      const emailResponseJson = '''
{
    "status": 1,
    "message": "Cart emailed successfully"
}
''';

      final mockClient = MockClient((request) async {
        return http.Response(emailResponseJson, 200, headers: {'content-type': 'application/json'});
      });

      final provider = MeleeProvider(
        repository: MeleeRepository(
          remoteDataSource: MeleeRemoteDataSource(client: mockClient),
        ),
        autoLoad: false,
      );

      final res = await provider.emailCart(
        recEmail: 'urvashi@braintreeproducts.com',
        message: 'Please check this Melle diamond cart.',
      );

      expect(res['status'], 1);
      expect(res['message'], 'Cart emailed successfully');
    });
  });
}

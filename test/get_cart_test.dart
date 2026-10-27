import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:colors_forever_app/features/diamonds/data/datasources/diamond_remote_data_source.dart';
import 'package:colors_forever_app/features/diamonds/data/repositories/diamond_repository_impl.dart';

void main() {
  group('Get Cart API Integration Tests', () {
    test('fetchCart posts user_id to get_cart and parses d_cart structure accurately', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/get_cart');
        expect(request.method, 'POST');

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['user_id'], '25');
        expect(body['group_id'], '4');

        return http.Response(
          json.encode({
            'status': 1,
            'message': 'Cart fetched successfully',
            'data': {
              'd_cart': [
                {
                  'cart_id': '6224',
                  'stock_id': '10301-2934',
                  'SN_LAB': 'GIA',
                  'UDF4': '1358453957',
                  'SN_SERIALNO': '10301-2934',
                  'N_CARAT': '17750',
                  'shape_full': 'ROUND',
                  'QT_WEIGHT': '12.53',
                  'SN_COLOR': 'AQUA BLUE I',
                  'SN_GRADE': 'IF',
                  'cut_full': '',
                  'polish_ful': 'Excellent',
                  'symmetry_full': 'Excellent',
                  'fluor_full': 'None',
                  'image_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/10301-2934.jpg',
                  'available': 1
                },
                {
                  'cart_id': '6225',
                  'stock_id': '10291-3982',
                  'SN_LAB': '',
                  'UDF4': ' ',
                  'SN_SERIALNO': '10291-3982',
                  'N_CARAT': '4950',
                  'shape_full': 'ROUND',
                  'QT_WEIGHT': '0.96',
                  'SN_COLOR': 'AQUA BLUE I',
                  'SN_GRADE': 'VS1',
                  'cut_full': '',
                  'polish_ful': '',
                  'symmetry_full': '',
                  'fluor_full': '',
                  'image_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/10291-3982.jpg',
                  'available': 1
                }
              ],
              'j_cart': [],
              'm_cart': [],
              'd_is_price_hide': '0',
              'j_is_price_hide': '0',
              'm_is_price_hide': '0',
              'getEmail': {
                'parent_to_email': 'support@colorsforever.com',
                'to_email': 'praveen@braintreeproducts.com'
              },
              'total_item': 2
            }
          }),
          200,
        );
      });

      final repo = DiamondRepositoryImpl(remoteDataSource: DiamondRemoteDataSource(client: mockClient));
      final cartResponse = await repo.getCart(userId: '25');

      expect(cartResponse.status, 1);
      expect(cartResponse.totalItems, 2);
      expect(cartResponse.solitaireCartItems.length, 2);

      final item1 = cartResponse.solitaireCartItems.first;
      expect(item1.cartId, '6224');
      expect(item1.stockId, '10301-2934');
      expect(item1.shape, 'ROUND');
      expect(item1.weight, 12.53);
      expect(item1.color, 'AQUA BLUE I');
      expect(item1.grade, 'IF');
      expect(item1.pricePerCts, 17750.0);
      expect(item1.imageUrl, 'https://lotuscolor.s3.us-east-1.amazonaws.com/10301-2934.jpg');

      final item2 = cartResponse.solitaireCartItems[1];
      expect(item2.cartId, '6225');
      expect(item2.serialNo, '10291-3982');
      expect(item2.weight, 0.96);
      expect(item2.grade, 'VS1');
      expect(item2.pricePerCts, 4950.0);
    });

    test('deleteCart posts user_id and cart_id comma separated list to delete_cart', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/delete_cart');
        expect(request.method, 'POST');

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['user_id'], '25');
        expect(body['cart_id'], '6224,6552');

        return http.Response(
          json.encode({
            'status': 1,
            'message': 'Cart item deleted successfully!',
            'deleted_count': 2,
            'cart_count': '2'
          }),
          200,
        );
      });

      final repo = DiamondRepositoryImpl(remoteDataSource: DiamondRemoteDataSource(client: mockClient));
      final res = await repo.deleteCart(cartIds: ['6224', '6552'], userId: '25');

      expect(res['status'], 1);
      expect(res['message'], 'Cart item deleted successfully!');
      expect(res['deleted_count'], 2);
      expect(res['cart_count'], '2');
    });
  });
}

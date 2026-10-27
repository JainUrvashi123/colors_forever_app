import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:colors_forever_app/features/diamonds/data/datasources/diamond_remote_data_source.dart';
import 'package:colors_forever_app/features/diamonds/data/repositories/diamond_repository_impl.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/diamond_filter.dart';

void main() {
  group('Solitaire API Integration Tests', () {
    test('fetchSolitaireIndex parses colors, shades, shapes, clarities', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/solitaire_index');
        return http.Response(
          json.encode({
            'status': 1,
            'login': 0,
            'is_price_hide': 0,
            'save_search': [],
            'ticker': [
              {'id': '1', 'page': 'solitaire', 'message': 'Welcome to Solitaire'}
            ],
            'compare_diamond': [],
            'colors': [
              {'id': 'idColorBlue', 'name': 'Blue', 'value': 'Blue', 'img': 'blue.jpg'}
            ],
            'shades': [
              {'id': 'idaqua_blue', 'name': 'Aqua Blue', 'value': 'AQUA BLUE', 'dcl': 'aqua_blue', 'p_id': 'idColorBlue'}
            ],
            'shapes': [
              {'id': 'idshaperound', 'name': 'Round', 'value': 'ROUND', 'img': 'icon-diamond-round'}
            ],
            'clarities': [
              {'id': 'FL', 'name': 'FL', 'value': 'FL'}
            ],
            'total_wishlist': 0,
          }),
          200,
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final index = await dataSource.fetchSolitaireIndex();

      expect(index.status, 1);
      expect(index.colors.length, 1);
      expect(index.colors.first.name, 'Blue');
      expect(index.shades.first.name, 'Aqua Blue');
      expect(index.shapes.first.name, 'Round');
      expect(index.clarities.first.name, 'FL');
    });

    test('fetchDiamonds posts default carat 0;100 and price 0;500000 when no filter applied', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/solitaire_load_more_data');
        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['carat'], '0;100');
        expect(body['price'], '0;500000');
        expect(body['checkbox'], isEmpty);
        expect(body['color'], isEmpty);
        expect(body['page'], 0);
        return http.Response(
          json.encode({
            'status': 1,
            'records': [],
            'total_records': 1137,
            'login': 0,
            'is_price_hide': 0,
          }),
          200,
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final response = await dataSource.fetchDiamonds(
        filter: DiamondFilter.initial,
        page: 1,
        perPage: 16,
      );

      expect(response.totalRecords, 1137);
    });

    test('fetchDiamonds posts filters to solitaire_load_more_data correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/solitaire_load_more_data');
        expect(request.method, 'POST');

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['per_page'], 16);
        expect(body['page'], 0);
        expect(body['carat'], '1;50');
        expect(body['price'], '1;500000');
        expect(body['cert'], equals(['GIA', 'IGI']));

        return http.Response(
          json.encode({
            'status': 1,
            'records': [
              {
                'shape_full': 'CUSHION',
                'SN_SERIALNO': 'N7009-2382',
                'QT_WEIGHT': '1.01',
                'SN_COLOR': 'S',
                'SN_GRADE': 'VS2',
                'cut_full': '',
                'polish_full': 'Very Good',
                'symmetry_full': 'Very Good',
                'fluor_full': '',
                'PC_DEPTH': '0.00',
                'PC_TABLE': '67.00',
                'RETAIL_PRICE_PER_CTS': '1336.00',
                'TOTAL_RETAIL_PRICE': '1349.36',
                'WHOLESALE_PRICE': '1330.00',
                'TOTAL_WHOLESALE_PRICE': '1343.30',
                'SN_LAB': 'GIA',
                'UDF4': '2196467451',
                'MEAS': '5.50x5.45x3.98',
                'LOCATION': 'NY',
                'LAB_COLOR': 'NATURAL',
                'TYPE': 'Natural',
                'image_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/N7009-2382.jpg',
                'video_show': '',
                'cert_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/cert/2196467451.pdf',
              }
            ],
            'total_records': 299,
            'login': 0,
            'is_price_hide': 0
          }),
          200,
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final response = await dataSource.fetchDiamonds(
        filter: const DiamondFilter(minCarat: 1.0, maxCarat: 50.0, minPrice: 1.0, maxPrice: 500000.0, selectedLabs: ['GIA', 'IGI']),
        page: 1,
        perPage: 16,
      );

      expect(response.totalRecords, 299);
      expect(response.records.length, 1);
      expect(response.records.first.serialNo, 'N7009-2382');
      expect(response.records.first.totalRetailPrice, 1349.36);
    });

    test('fetchDiamondDetails posts inventory_id, user_id, and vd_group_id to solitaire_diamond_details', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/solitaire_diamond_details');
        expect(request.method, 'POST');

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['inventory_id'], '3049-4314');
        expect(body['vd_group_id'], '4');

        return http.Response(
          json.encode({
            'status': 1,
            'message': 'Diamond details fetched successfully',
            'data': {
              'records': [
                {
                  'shape_full': 'PRINCESS',
                  'SN_SERIALNO': '3049-4314',
                  'QT_WEIGHT': '0.90',
                  'SN_COLOR': 'ICE GREEN',
                  'SN_GRADE': 'VS2',
                  'cut_full': '',
                  'polish_full': '',
                  'symmetry_full': '',
                  'fluor_full': '',
                  'PC_DEPTH': '0.00',
                  'PC_TABLE': '0.00',
                  'RETAIL_PRICE_PER_CTS': '2750.00',
                  'TOTAL_RETAIL_PRICE': '2475.00',
                  'WHOLESALE_PRICE': '2610.00',
                  'TOTAL_WHOLESALE_PRICE': '2349.00',
                  'SN_LAB': '',
                  'UDF4': ' ',
                  'MEAS': '5.23x5.07x3.77',
                  'LOCATION': 'NY',
                  'LAB_COLOR': ' FANCY VIVID YELLOWISH GREEN',
                  'image': 'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314.jpg',
                  'video': 'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314.mp4',
                  'cert': '',
                }
              ],
              'similar_records': [],
              'image_array': [
                'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314.jpg',
                'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314_1.jpg'
              ],
              'sample_image_array': [],
              'video_array': [
                'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314.mp4'
              ],
              'certificate_array': [],
              'image_link': [],
              'video_link': [],
              'is_price_hide': '1',
              'login': 1
            }
          }),
          200,
        );
      });

      final repo = DiamondRepositoryImpl(remoteDataSource: DiamondRemoteDataSource(client: mockClient));
      final details = await repo.getDiamondDetails('3049-4314', vdGroupId: '4');

      expect(details.diamond.serialNo, '3049-4314');
      expect(details.imageArray.length, 2);
      expect(details.videoArray.first, 'https://lotuscolor.s3.us-east-1.amazonaws.com/3049-4314.mp4');
      expect(details.isPriceHide, 1);
      expect(details.login, 1);
    });

    test('addToCart posts all_id to solitaire_add_cart', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/solitaire_add_cart');
        expect(request.method, 'POST');

        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['all_id'], equals(['10291-3982']));

        return http.Response(
          json.encode({
            'status': 1,
            'message': 'Cart added successfully!',
            'cart_count': '2'
          }),
          200,
        );
      });

      final repo = DiamondRepositoryImpl(remoteDataSource: DiamondRemoteDataSource(client: mockClient));
      final res = await repo.addToCart(['10291-3982']);

      expect(res['status'], 1);
      expect(res['message'], 'Cart added successfully!');
      expect(res['cart_count'], '2');
    });
  });
}

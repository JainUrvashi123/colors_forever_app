import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:colors_forever_app/features/melee/data/datasources/melee_remote_data_source.dart';
import 'package:colors_forever_app/features/melee/data/repositories/melee_repository.dart';
import 'package:colors_forever_app/features/melee/domain/models/melee_model.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';

void main() {
  final sampleMap = <String, dynamic>{
    'status': 1,
    'message': 'Melle data fetched successfully',
    'cart_list': [
      {
        'spl_req': 'hiii',
        'cart_id': '6207',
        'stock_id': '1231FG-0.750000',
        'quantity': '2',
        'filter_param': json.encode({
          'quantity': '2',
          'solitaireForm': json.encode({
            'shape': [],
            'clarity': [],
            'color': ['Pink'],
            'color_ch': [],
            'size': '0;20',
            'carat': '0.01;100',
            'price': '1;300000',
            'search': '',
            'cert': [],
            'sort_by': 'weight_h',
            'location': '',
          }),
          'spl_req': 'hiii',
          'gradeFilterChecked': 'VS2-SI2',
          'sizeFilterChecked': '0.8 MM',
          'colorChecked': 'idColorGreen',
          'stoneTypeChecked': 'type_mellee',
          'color_ch': 'EMERALD GREEN',
        }),
        'item': 'Emerald Green [Green] 0.8 MM VS2-SI2',
        'size': '0.8 MM',
        'color': 'Green',
        'grade': 'VS2-SI2',
        'wt_from': '0.0160',
        'wt_to': '0.0160',
        'price_from': '32.00',
        'price_to': '32.00',
        'tag_price': '2000.00',
      }
    ],
    'cart_total_value': {
      'total_wt_from': '0.0160',
      'total_wt_to': '0.0160',
      'total_price_from': '32.00',
      'total_price_to': '32.00',
    },
    'months': [
      {
        'id': 'idmonthjanuary',
        'name': 'January',
        'value': 'january',
        'img': 'january.png',
        'dcl': 'orangish_cognac_o',
      },
      {
        'id': 'idmonthmay',
        'name': 'May',
        'value': 'may',
        'img': 'may.png',
        'dcl': 'emerald_green',
      }
    ],
    'colors': [
      {
        'id': 'idColorBlue',
        'name': 'Blue',
        'value': 'Blue',
        'img': 'blue.jpg',
      },
      {
        'id': 'idColorGreen',
        'name': 'Green',
        'value': 'Green',
        'img': 'green.jpg',
      }
    ],
    'colorShades': [
      {
        'id': 'idaqua_blue_1',
        'name': 'Aqua Blue I',
        'value': 'AQUA BLUE I',
        'dcl': 'aqua_blue',
        'p_id': 'idColorBlue',
        'month': 'idmonthmarch',
      },
      {
        'id': 'idemerald_green',
        'name': 'Emerald Green',
        'value': 'EMERALD GREEN',
        'dcl': 'emerald_green',
        'p_id': 'idColorGreen',
        'month': 'idmonthmay',
      }
    ],
    'ticker': [
      {
        'id': '2',
        'page': 'melle',
        'message':
            '<h3 style="font-family: "><b><font face="Poppins, sans-serif" color="#ff0000"><span style="font-size: 14px;">PLEASE TRY AND AVOID THE FOLLOWING PREMIUM SIZES: 1.0 mm, 1.3 mm, 1.5mm, 2.0 mm, 2.5 mm,3.0mm,and 3.5mm.&nbsp;&nbsp;FOR FANCY SHAPES UNDER 1 CARAT, PLEASE CALL US AS THEY ARE NOT LISTED HERE</span></font></b></h3>',
      }
    ],
  };

  final sampleJson = json.encode(sampleMap);

  group('melle_index Data Models', () {
    test('MelleIndexResponse parses JSON accurately', () {
      final response = MelleIndexResponse.fromJson(sampleMap);

      expect(response.status, 1);
      expect(response.message, 'Melle data fetched successfully');
      expect(response.cartList.length, 1);
      expect(response.months.length, 2);
      expect(response.colors.length, 2);
      expect(response.colorShades.length, 2);
      expect(response.ticker.length, 1);
      expect(response.cartTotalValue?.totalPriceFrom, '32.00');

      // Ticker HTML stripping
      expect(response.cleanTickerMessage, isNotNull);
      expect(response.cleanTickerMessage, contains('PLEASE TRY AND AVOID THE FOLLOWING PREMIUM SIZES'));
      expect(response.cleanTickerMessage, isNot(contains('<h3')));
      expect(response.cleanTickerMessage, isNot(contains('&nbsp;')));
    });

    test('MelleApiCartItem converts to MeleeCartItem correctly', () {
      final response = MelleIndexResponse.fromJson(sampleMap);
      final apiCartItem = response.cartList.first;
      final cartItem = apiCartItem.toMeleeCartItem();

      expect(cartItem.id, '6207');
      expect(cartItem.color, 'Green');
      expect(cartItem.shade, 'EMERALD GREEN');
      expect(cartItem.size, '0.8 MM');
      expect(cartItem.clarity, 'VS2-SI2');
      expect(cartItem.quantity, 2);
      expect(cartItem.wtFrom, '0.0160');
      expect(cartItem.wtTo, '0.0160');
      expect(cartItem.priceFrom, r'$32.00');
      expect(cartItem.priceTo, r'$32.00');
      expect(cartItem.pricePerCarat, r'$2000.00');
      expect(cartItem.specialRequest, 'hiii');
      expect(cartItem.stoneType, MeleeStoneType.melee);
    });

    test('MelleApiMonth converts to BirthMonthOption with accent color', () {
      final response = MelleIndexResponse.fromJson(sampleMap);
      final mayMonth = response.months.firstWhere((m) => m.value == 'may');
      final option = mayMonth.toBirthMonthOption();

      expect(option.month, 'may');
      expect(option.displayName, 'May');
      expect(option.shadeName, 'EMERALD GREEN');
      expect(option.colorName, 'Green');
      expect(option.accentColor, const Color(0xFF12A023));
    });

    test('MelleApiColor converts to MeleeColorOption with network URL', () {
      final response = MelleIndexResponse.fromJson(sampleMap);
      final blueColor = response.colors.firstWhere((c) => c.name == 'Blue');
      final option = blueColor.toMeleeColorOption();

      expect(option.name, 'Blue');
      expect(option.assetPath, 'assets/colors/blue.jpg');
      expect(option.networkImgUrl, 'https://colorsforever.com/assets/images/blue.jpg');
      expect(option.primaryColor, const Color(0xFF0D47A1));
    });

    test('stripHtmlTags removes all tags and normalizes whitespace', () {
      const html = '<p><b>Warning:</b>&nbsp;Avoid 1.0mm <br/><span>and 1.3mm.</span></p>';
      expect(stripHtmlTags(html), 'Warning: Avoid 1.0mm and 1.3mm.');
    });
  });

  group('MeleeRemoteDataSource & Repository melle_index tests', () {
    test('fetchMelleIndex parses response from HTTP 200', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString() == MeleeRemoteDataSource.melleIndexUrl) {
          return http.Response(sampleJson, 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = MeleeRemoteDataSource(client: mockClient);
      final response = await dataSource.fetchMelleIndex();

      expect(response.status, 1);
      expect(response.colors.length, 2);
      expect(response.cleanTickerMessage, isNotNull);
    });

    test('fetchMelleIndex falls back gracefully on network failure', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network disconnected');
      });

      final dataSource = MeleeRemoteDataSource(client: mockClient);
      final response = await dataSource.fetchMelleIndex();

      expect(response.status, 1);
      expect(response.colors, isNotEmpty);
      expect(response.months, isNotEmpty);
      expect(response.cleanTickerMessage, isNotNull);
    });

    test('MeleeRepository caches getMelleIndex results', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(sampleJson, 200, headers: {'content-type': 'application/json'});
      });

      final repo = MeleeRepository(
        remoteDataSource: MeleeRemoteDataSource(client: mockClient),
      );

      final res1 = await repo.getMelleIndex();
      final res2 = await repo.getMelleIndex();

      expect(res1.status, 1);
      expect(res2.status, 1);
      expect(callCount, 1); // Cached, only 1 remote call
    });
  });

  group('MeleeProvider Data Hydration', () {
    test('loadInitialData synchronizes ticker, colors, shades, and cart items', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleJson, 200, headers: {'content-type': 'application/json'});
      });
      final repo = MeleeRepository(
        remoteDataSource: MeleeRemoteDataSource(client: mockClient),
      );

      final provider = MeleeProvider(repository: repo, autoLoad: false);
      expect(provider.hasTicker, isFalse);
      expect(provider.cartCount, 0);

      await provider.loadInitialData();

      expect(provider.hasTicker, isTrue);
      expect(provider.tickerMessage, contains('PREMIUM SIZES'));
      expect(provider.colors.length, 2);
      expect(provider.allShades.length, 2);
      expect(provider.birthMonths.length, 2);
      expect(provider.cartCount, 1);
      expect(provider.cartItems.first.shade, 'EMERALD GREEN');
      expect(provider.cartItems.first.quantity, 2);

      // Dismiss ticker
      provider.dismissTicker();
      expect(provider.hasTicker, isFalse);
      expect(provider.tickerMessage, isNull);
    });
  });
}

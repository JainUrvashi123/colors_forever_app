import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:colors_forever_app/features/diamonds/data/datasources/diamond_remote_data_source.dart';
import 'package:colors_forever_app/features/diamonds/data/repositories/diamond_repository_impl.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/widgets/cart_request_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Email Cart & Request Memo API Integration Tests', () {
    test('1. Diamond — Email Cart sends payload to email_diamond_cart_api', () async {
      String? postedUrl;
      Map<String, dynamic>? postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({'status': 1, 'message': 'Diamond cart emailed successfully'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final res = await dataSource.sendCartEmail(
        targetCart: 'Loose Diamond Cart',
        requestType: 'Email Cart',
        recEmail: 'customer@example.com',
        contactPerson: '',
        type: '',
        shippingOption: '',
        message: 'Please check my diamond cart',
        markupD: '10',
        userId: '123',
        groupId: '4',
      );

      expect(postedUrl, 'https://colorsforever.com/api/email_diamond_cart_api');
      expect(postedBody?['user_id'], '123');
      expect(postedBody?['group_id'], '4');
      expect(postedBody?['contact_person'], '');
      expect(postedBody?['type'], '');
      expect(postedBody?['request_type'], 'Email Cart');
      expect(postedBody?['shipping_option'], '');
      expect(postedBody?['rec_email'], 'customer@example.com');
      expect(postedBody?['message'], 'Please check my diamond cart');
      expect(postedBody?['markup_d'], '10');
      expect(res['status'], 1);
    });

    test('2. Diamond — Request Memo sends payload to email_diamond_cart_api', () async {
      String? postedUrl;
      Map<String, dynamic>? postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({'status': 1, 'message': 'Diamond memo request processed'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final res = await dataSource.sendCartEmail(
        targetCart: 'Loose Diamond Cart',
        requestType: 'Request Memo',
        recEmail: 'customer@example.com',
        contactPerson: 'John',
        type: 'Wholesale',
        shippingOption: 'Overnight',
        message: 'Please process this diamond memo',
        markupD: '10',
        userId: '123',
        groupId: '4',
      );

      expect(postedUrl, 'https://colorsforever.com/api/email_diamond_cart_api');
      expect(postedBody?['user_id'], '123');
      expect(postedBody?['group_id'], '4');
      expect(postedBody?['contact_person'], 'John');
      expect(postedBody?['type'], 'Wholesale');
      expect(postedBody?['request_type'], 'Request Memo');
      expect(postedBody?['shipping_option'], 'Overnight');
      expect(postedBody?['rec_email'], 'customer@example.com');
      expect(postedBody?['message'], 'Please process this diamond memo');
      expect(postedBody?['markup_d'], '10');
      expect(res['status'], 1);
    });

    test('3. Jewelry — Email Cart sends payload to email_jewelry_cart_api', () async {
      String? postedUrl;
      Map<String, dynamic>? postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({'status': 1, 'message': 'Jewelry cart emailed successfully'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final res = await dataSource.sendCartEmail(
        targetCart: 'Jewelry Cart',
        requestType: 'Email Cart',
        recEmail: 'customer@example.com',
        contactPerson: '',
        type: '',
        shippingOption: '',
        message: 'Please check my jewelry cart',
        markupD: '10',
        userId: '123',
        groupId: '4',
      );

      expect(postedUrl, 'https://colorsforever.com/api/email_jewelry_cart_api');
      expect(postedBody?['user_id'], '123');
      expect(postedBody?['group_id'], '4');
      expect(postedBody?['request_type'], 'Email Cart');
      expect(postedBody?['rec_email'], 'customer@example.com');
      expect(postedBody?['message'], 'Please check my jewelry cart');
      expect(postedBody?['markup_d'], '10');
      expect(res['status'], 1);
    });

    test('4. Jewelry — Request Memo sends payload to email_jewelry_cart_api', () async {
      String? postedUrl;
      Map<String, dynamic>? postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({'status': 1, 'message': 'Jewelry memo request processed'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final res = await dataSource.sendCartEmail(
        targetCart: 'Jewelry Cart',
        requestType: 'Request Memo',
        recEmail: 'customer@example.com',
        contactPerson: 'John',
        type: 'Wholesale',
        shippingOption: 'Overnight',
        message: 'Please process this jewelry memo',
        markupD: '10',
        userId: '123',
        groupId: '4',
      );

      expect(postedUrl, 'https://colorsforever.com/api/email_jewelry_cart_api');
      expect(postedBody?['user_id'], '123');
      expect(postedBody?['group_id'], '4');
      expect(postedBody?['contact_person'], 'John');
      expect(postedBody?['type'], 'Wholesale');
      expect(postedBody?['request_type'], 'Request Memo');
      expect(postedBody?['shipping_option'], 'Overnight');
      expect(postedBody?['rec_email'], 'customer@example.com');
      expect(postedBody?['message'], 'Please process this jewelry memo');
      expect(postedBody?['markup_d'], '10');
      expect(res['status'], 1);
    });

    test('5. All Cart — Email Cart sends payload to email_all_cart_api', () async {
      String? postedUrl;
      Map<String, dynamic>? postedBody;

      final mockClient = MockClient((request) async {
        postedUrl = request.url.toString();
        postedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({'status': 1, 'message': 'All cart emailed successfully'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = DiamondRemoteDataSource(client: mockClient);
      final res = await dataSource.sendCartEmail(
        targetCart: 'All Cart',
        requestType: 'Email Cart',
        recEmail: 'customer@example.com',
        contactPerson: '',
        type: '',
        shippingOption: '',
        message: 'Please check my complete cart',
        markupD: '10',
        userId: '25',
        groupId: '4',
      );

      expect(postedUrl, 'https://colorsforever.com/api/email_all_cart_api');
      expect(postedBody?['user_id'], '25');
      expect(postedBody?['group_id'], '4');
      expect(postedBody?['request_type'], 'Email Cart');
      expect(postedBody?['rec_email'], 'customer@example.com');
      expect(postedBody?['message'], 'Please check my complete cart');
      expect(postedBody?['markup_d'], '10');
      expect(res['status'], 1);
    });
  });

  group('CartRequestDialog Widget Tests', () {
    testWidgets('CartRequestDialog renders Request Memo layout and hides shipping option on Hold', (tester) async {
      final repository = DiamondRepositoryImpl();
      final provider = DiamondCatalogProvider(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiamondCatalogProvider>.value(
              value: provider,
              child: const CartRequestDialog(
                initialRequestType: 'Request Memo',
                initialCart: 'All Cart',
              ),
            ),
          ),
        ),
      );

      expect(find.text('REQUEST MEMO/HOLD'), findsOneWidget);
      expect(find.text('CART'), findsOneWidget);
      expect(find.text('CONTACT PERSON'), findsOneWidget);
      expect(find.text('MESSAGE'), findsOneWidget);
      expect(find.text('REQUEST TYPE'), findsOneWidget);
      expect(find.text('SHIPPING OPTION'), findsOneWidget);

      // Select 'Hold' from REQUEST TYPE dropdown
      await tester.tap(find.text('Memo').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hold').last);
      await tester.pumpAndSettle();

      // Verify SHIPPING OPTION is now HIDDEN
      expect(find.text('SHIPPING OPTION'), findsNothing);
    });

    testWidgets('CartRequestDialog renders Email Cart layout showing only CART, EMAIL, MESSAGE', (tester) async {
      final repository = DiamondRepositoryImpl();
      final provider = DiamondCatalogProvider(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiamondCatalogProvider>.value(
              value: provider,
              child: const CartRequestDialog(
                initialRequestType: 'Email Cart',
                initialCart: 'All Cart',
              ),
            ),
          ),
        ),
      );

      expect(find.text('EMAIL CART'), findsOneWidget);
      expect(find.text('CART'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('MESSAGE'), findsOneWidget);
      expect(find.text('CONTACT PERSON'), findsNothing);
      expect(find.text('REQUEST TYPE'), findsNothing);
      expect(find.text('SHIPPING OPTION'), findsNothing);
      expect(find.text('Send'), findsOneWidget);
    });
  });
}

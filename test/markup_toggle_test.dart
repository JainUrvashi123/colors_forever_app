import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:colors_forever_app/features/auth/data/models/user_model.dart';
import 'package:colors_forever_app/features/auth/data/repositories/auth_repository.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/features/auth/presentation/widgets/markup_toggle_switch.dart';
import 'package:colors_forever_app/features/auth/presentation/widgets/markup_toggle_dialog.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  // Exact JSON from Postman screenshot
  const postmanResponseJson = '''{
    "status": 1,
    "message": "Markup updated successfully",
    "details": {
      "user_id": "25",
      "is_markup": 1,
      "updated": [
        "diamond",
        "jewelry",
        "melle"
      ]
    }
  }''';

  const enableResponseJson = '''{
    "status": 1,
    "message": "Markup enabled successfully",
    "details": {
      "user_id": 25,
      "is_markup": 1
    }
  }''';

  const disableResponseJson = '''{
    "status": 1,
    "message": "Markup updated successfully",
    "details": {
      "user_id": "25",
      "is_markup": 0,
      "updated": [
        "diamond",
        "jewelry",
        "melle"
      ]
    }
  }''';

  const errorResponseJson = '''{
    "status": 0,
    "message": "Username or Password is Incorrect!"
  }''';

  group('MarkupToggleResponse Model Tests', () {
    test('parses exact Postman response correctly', () {
      final json = jsonDecode(postmanResponseJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(json);

      expect(response.status, 1);
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Markup updated successfully');
      expect(response.details, isNotNull);
      expect(response.details!.userId, '25');
      expect(response.details!.isMarkup, 1);
      expect(response.details!.isMarkupActive, isTrue);
      expect(response.details!.updated, ['diamond', 'jewelry', 'melle']);
    });

    test('parses enabled response with int userId and no updated list', () {
      final json = jsonDecode(enableResponseJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(json);

      expect(response.status, 1);
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Markup enabled successfully');
      expect(response.details, isNotNull);
      expect(response.details!.userId, '25');
      expect(response.details!.isMarkup, 1);
      expect(response.details!.isMarkupActive, isTrue);
      expect(response.details!.updated, isEmpty);
    });

    test('parses disabled response with is_markup: 0', () {
      final json = jsonDecode(disableResponseJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(json);

      expect(response.status, 1);
      expect(response.details!.isMarkup, 0);
      expect(response.details!.isMarkupActive, isFalse);
    });

    test('parses error response safely', () {
      final json = jsonDecode(errorResponseJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(json);

      expect(response.status, 0);
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Username or Password is Incorrect!');
      expect(response.details, isNull);
    });
  });

  group('AuthRemoteDataSource & Repository toggleMarkup Unit Tests', () {
    test('AuthRemoteDataSource sends exact payload matching Postman screenshot', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/toggle');
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['is_diamond_work2'], 1);
        expect(body['toggle_cheacked'], 0);
        expect(body['emailInput'], 'praveen@braintreeproducts.com');
        expect(body['passwordInput'], '12345');
        expect(body['vd_user_id'], 25);

        return http.Response(postmanResponseJson, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.toggleMarkup(
        isDiamondWork2: 1,
        toggleChecked: 0,
        emailInput: 'praveen@braintreeproducts.com',
        passwordInput: '12345',
        vdUserId: '25',
      );

      expect(response.isSuccess, isTrue);
      expect(response.message, 'Markup updated successfully');
      expect(response.details!.updated, contains('diamond'));
    });

    test('AuthRepository preserves session credentials and passes to toggleMarkup', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('login')) {
          return http.Response('''{
            "status": 1,
            "message": "Login Successfully",
            "details": {
              "user_id": "25",
              "parent_id": "20",
              "fullname": "Pankaj",
              "active": "1",
              "company": "Braintree",
              "logo": "",
              "group": 1
            }
          }''', 200);
        } else if (request.url.toString().contains('toggle')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['vd_user_id'], 25);
          expect(body['emailInput'], 'praveen@braintreeproducts.com');
          return http.Response(enableResponseJson, 200);
        }
        return http.Response('Not Found', 404);
      });

      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      await repo.login(username: 'praveen@braintreeproducts.com', password: '12345');

      expect(repo.isAuthenticated, isTrue);
      expect(repo.savedUsername, 'praveen@braintreeproducts.com');
      expect(repo.savedPassword, '12345');
      expect(repo.currentUser?.userId, '25');

      final toggleResponse = await repo.toggleMarkup(
        toggleChecked: 1,
        emailInput: repo.savedUsername!,
        passwordInput: repo.savedPassword!,
      );

      expect(toggleResponse.isSuccess, isTrue);
      expect(toggleResponse.message, 'Markup enabled successfully');
    });
  });

  group('AuthProvider State Management Tests', () {
    test('quickToggleMarkup activates markup and updates state', () async {
      final mockClient = MockClient((request) async {
        return http.Response(enableResponseJson, 200);
      });

      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);
      provider.setSavedCredentials('praveen@braintreeproducts.com', '12345');

      expect(provider.hasSavedCredentials, isTrue);
      expect(provider.isMarkupEnabled, isFalse);

      final success = await provider.quickToggleMarkup(true);

      expect(success, isTrue);
      expect(provider.isMarkupEnabled, isTrue);
      expect(provider.successMessage, 'Markup enabled successfully');
    });

    test('quickToggleMarkup deactivates markup and updates state', () async {
      final mockClient = MockClient((request) async {
        return http.Response(disableResponseJson, 200);
      });

      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);
      provider.setSavedCredentials('praveen@braintreeproducts.com', '12345');

      final success = await provider.quickToggleMarkup(false);

      expect(success, isTrue);
      expect(provider.isMarkupEnabled, isFalse);
    });

    test('quickToggleMarkup returns false if credentials missing', () async {
      final provider = AuthProvider();
      expect(provider.hasSavedCredentials, isFalse);

      final result = await provider.quickToggleMarkup(true);
      expect(result, isFalse);
    });
  });

  group('MarkupToggleSwitch Widget Tests', () {
    testWidgets('MarkupToggleSwitch displays ON when active and OFF when inactive', (tester) async {
      final mockClient = MockClient((request) async => http.Response(enableResponseJson, 200));
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: MarkupToggleSwitch()),
            ),
          ),
        ),
      );

      // Initially OFF
      expect(find.text('OFF'), findsOneWidget);
      expect(find.text('ON'), findsNothing);

      // Set credentials & activate
      authProvider.setSavedCredentials('test@example.com', '12345');
      await authProvider.quickToggleMarkup(true);
      await tester.pumpAndSettle();

      // Now ON
      expect(find.text('ON'), findsOneWidget);
      expect(find.text('OFF'), findsNothing);
    });

    testWidgets('MarkupToggleSwitch tap opens verify password popup and verifies toggle', (tester) async {
      int apiCallCount = 0;
      final mockClient = MockClient((request) async {
        apiCallCount++;
        return http.Response(enableResponseJson, 200);
      });

      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final authProvider = AuthProvider(repository: repo);
      authProvider.setSavedCredentials('praveen@braintreeproducts.com', '12345');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: MarkupToggleSwitch()),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MarkupToggleSwitch));
      await tester.pumpAndSettle();

      // PASSWORD VERIFY popup is displayed
      expect(find.byType(MarkupToggleDialog), findsOneWidget);
      expect(find.text('PASSWORD VERIFY'), findsOneWidget);
      expect(find.text('ENTER PASSWORD'), findsOneWidget);

      // Enter password and tap VERIFY
      await tester.enterText(find.byType(TextFormField).first, '12345');
      await tester.pump();
      await tester.tap(find.text('VERIFY'));
      await tester.pumpAndSettle();

      expect(apiCallCount, 1);
      expect(authProvider.isMarkupEnabled, isTrue);
    });

    testWidgets('MarkupToggleSwitch tap without credentials opens MarkupToggleDialog', (tester) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: MarkupToggleSwitch()),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MarkupToggleSwitch));
      await tester.pumpAndSettle();

      // Dialog with MarkupToggleDialog should be opened
      expect(find.byType(MarkupToggleDialog), findsOneWidget);
      expect(find.text('PASSWORD VERIFY'), findsOneWidget);
      expect(find.text('ENTER PASSWORD'), findsOneWidget);
      expect(find.text('VERIFY'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });
  });
}

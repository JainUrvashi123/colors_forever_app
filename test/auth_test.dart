import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/core/theme/app_theme.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:colors_forever_app/features/auth/data/models/user_model.dart';
import 'package:colors_forever_app/features/auth/data/repositories/auth_repository.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/core/widgets/recaptcha_box.dart';
import 'package:colors_forever_app/features/auth/presentation/views/login_screen.dart';
import 'package:colors_forever_app/features/auth/presentation/widgets/markup_toggle_dialog.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_filter_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  const successJson = '''{
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
  }''';

  const failureJson = '''{
    "status": 0,
    "message": "Username or Password is Incorrect!",
    "details": []
  }''';

  group('UserModel & LoginResponse Model Tests', () {
    test('LoginResponse parses success response with details Map', () {
      final data = jsonDecode(successJson) as Map<String, dynamic>;
      final response = LoginResponse.fromJson(data);

      expect(response.status, 1);
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Login Successfully');
      expect(response.user, isNotNull);
      expect(response.user!.userId, '25');
      expect(response.user!.parentId, '20');
      expect(response.user!.fullName, 'Pankaj');
      expect(response.user!.company, 'Braintree');
      expect(response.user!.active, '1');
      expect(response.user!.isActive, isTrue);
      expect(response.user!.group, 1);
    });

    test('LoginResponse parses failure response with details List safely', () {
      final data = jsonDecode(failureJson) as Map<String, dynamic>;
      final response = LoginResponse.fromJson(data);

      expect(response.status, 0);
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Username or Password is Incorrect!');
      expect(response.user, isNull);
    });

    test('UserModel toJson and copyWith work properly', () {
      final user = UserModel(
        userId: '25',
        parentId: '20',
        fullName: 'Pankaj',
        active: '1',
        company: 'Braintree',
        logo: '',
        group: 1,
      );

      final json = user.toJson();
      expect(json['user_id'], '25');
      expect(json['fullname'], 'Pankaj');

      final updated = user.copyWith(fullName: 'Pankaj Kumar');
      expect(updated.fullName, 'Pankaj Kumar');
      expect(updated.userId, '25');
    });
  });

  group('AuthRemoteDataSource & Repository Unit Tests', () {
    test('AuthRemoteDataSource sends correct request and parses success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/login');
        expect(request.method, 'POST');
        expect(request.headers['content-type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['username'], 'praveen@braintreeproducts.com');
        expect(body['password'], '12345');
        expect(body['remember'], 1);

        return http.Response(successJson, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.login(
        username: 'praveen@braintreeproducts.com',
        password: '12345',
        remember: true,
      );

      expect(response.isSuccess, isTrue);
      expect(response.user?.fullName, 'Pankaj');
    });

    test('AuthRemoteDataSource handles 401 Unauthorized gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(failureJson, 401);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.login(
        username: 'wrong@test.com',
        password: 'badpassword',
      );

      expect(response.isSuccess, isFalse);
      expect(response.message, 'Username or Password is Incorrect!');
    });

    test('AuthRepository coordinates login and session cache', () async {
      final mockClient = MockClient((request) async {
        return http.Response(successJson, 200);
      });

      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);

      final response = await repo.login(username: 'test', password: 'pwd');
      expect(response.isSuccess, isTrue);
      expect(repo.isAuthenticated, isTrue);
      expect(repo.currentUser?.fullName, 'Pankaj');

      await repo.logout();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);
    });
  });

  group('AuthProvider State Management Tests', () {
    test('login succeeds and updates authentication state', () async {
      final mockClient = MockClient((request) async {
        return http.Response(successJson, 200);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);

      final success = await provider.login('praveen@braintreeproducts.com', '12345');
      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.fullName, 'Pankaj');
      expect(provider.currentUser?.company, 'Braintree');
      expect(provider.errorMessage, isNull);

      await provider.logout();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
    });

    test('AuthRemoteDataSource sends logout request to https://colorsforever.com/api/logout', () async {
      const logoutSuccessJson = '''{
        "status": 1,
        "message": "Logout Successfully"
      }''';

      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/logout');
        expect(request.method, 'POST');
        return http.Response(logoutSuccessJson, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.logout();

      expect(response.isSuccess, isTrue);
      expect(response.message, 'Logout Successfully');
    });

    test('login failure updates errorMessage and keeps isAuthenticated false', () async {
      final mockClient = MockClient((request) async {
        return http.Response(failureJson, 401);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);

      final success = await provider.login('wrong', 'wrong');
      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Username or Password is Incorrect!');
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders fields, quick fill and triggers login', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(successJson, 200);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider(create: (_) => DiamondCatalogProvider()),
            ChangeNotifierProvider(create: (_) => DiamondFilterProvider()),
            ChangeNotifierProvider(create: (_) => MeleeProvider(autoLoad: false)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Verify branding and title
      expect(find.text('Colors Forever'), findsOneWidget);
      expect(find.text('Wholesale Diamond & Melee Portal'), findsOneWidget);

      // Verify inputs
      expect(find.text('USERNAME OR EMAIL'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byType(TextFormField).first, 'praveen@braintreeproducts.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.pump();

      // Tap reCAPTCHA verification and wait for checkmark
      await tester.tap(find.byType(RecaptchaBox));
      await tester.pump(const Duration(milliseconds: 1300));

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.fullName, 'Pankaj');
    });

    testWidgets('LoginScreen displays Forgot Password? button and opens ForgotPasswordSheet', (tester) async {
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource());
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });
  });

  group('Forgot Password API & Flow Tests', () {
    const forgotSuccessJson = '''{
      "status": 1,
      "message": "Please check your email for password reset."
    }''';

    const forgotFailureJson = '''{
      "status": 0,
      "message": "Invalid email id please check again."
    }''';

    test('ForgotPasswordResponse parses success response correctly', () {
      final data = jsonDecode(forgotSuccessJson) as Map<String, dynamic>;
      final response = ForgotPasswordResponse.fromJson(data);

      expect(response.status, 1);
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Please check your email for password reset.');
    });

    test('ForgotPasswordResponse parses failure response correctly', () {
      final data = jsonDecode(forgotFailureJson) as Map<String, dynamic>;
      final response = ForgotPasswordResponse.fromJson(data);

      expect(response.status, 0);
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Invalid email id please check again.');
    });

    test('AuthRemoteDataSource sends forgot_password request properly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/forgot_password');
        expect(request.method, 'POST');
        expect(request.headers['content-type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['username'], 'praveen@braintreeproducts.com');

        return http.Response(forgotSuccessJson, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.forgotPassword(username: 'praveen@braintreeproducts.com');

      expect(response.isSuccess, isTrue);
      expect(response.message, 'Please check your email for password reset.');
    });

    test('AuthProvider.forgotPassword updates success and error state', () async {
      final successClient = MockClient((request) async {
        return http.Response(forgotSuccessJson, 200);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: successClient));
      final provider = AuthProvider(repository: repo);

      final successResp = await provider.forgotPassword('praveen@braintreeproducts.com');
      expect(successResp.isSuccess, isTrue);
      expect(provider.successMessage, 'Please check your email for password reset.');
      expect(provider.errorMessage, isNull);

      final failClient = MockClient((request) async {
        return http.Response(forgotFailureJson, 200);
      });
      final failRepo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: failClient));
      final failProvider = AuthProvider(repository: failRepo);

      final failResp = await failProvider.forgotPassword('unknown@mail.com');
      expect(failResp.isSuccess, isFalse);
      expect(failProvider.errorMessage, 'Invalid email id please check again.');
    });
  });

  group('Markup Toggle API & Flow Tests', () {
    const toggleSuccessJson = '''{
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

    const toggleFailureJson = '''{
      "status": 0,
      "message": "Username or Password is Incorrect!"
    }''';

    test('MarkupToggleResponse parses success response with details and updated categories', () {
      final data = jsonDecode(toggleSuccessJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(data);

      expect(response.status, 1);
      expect(response.isSuccess, isTrue);
      expect(response.message, 'Markup updated successfully');
      expect(response.details, isNotNull);
      expect(response.details!.userId, '25');
      expect(response.details!.isMarkup, 1);
      expect(response.details!.isMarkupActive, isTrue);
      expect(response.details!.updated, containsAll(['diamond', 'jewelry', 'melle']));
    });

    test('MarkupToggleResponse parses failure response gracefully', () {
      final data = jsonDecode(toggleFailureJson) as Map<String, dynamic>;
      final response = MarkupToggleResponse.fromJson(data);

      expect(response.status, 0);
      expect(response.isSuccess, isFalse);
      expect(response.message, 'Username or Password is Incorrect!');
      expect(response.details, isNull);
    });

    test('AuthRemoteDataSource sends toggleMarkup request properly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://colorsforever.com/api/toggle');
        expect(request.method, 'POST');
        expect(request.headers['content-type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['is_diamond_work2'], 1);
        expect(body['toggle_cheacked'], 0);
        expect(body['emailInput'], 'praveen@braintreeproducts.com');
        expect(body['passwordInput'], '12345');

        return http.Response(toggleSuccessJson, 200);
      });

      final dataSource = AuthRemoteDataSource(client: mockClient);
      final response = await dataSource.toggleMarkup(
        isDiamondWork2: 1,
        toggleChecked: 0,
        emailInput: 'praveen@braintreeproducts.com',
        passwordInput: '12345',
      );

      expect(response.isSuccess, isTrue);
      expect(response.details?.updated, hasLength(3));
    });

    test('AuthProvider.toggleMarkup updates markup state and categories', () async {
      final mockClient = MockClient((request) async {
        return http.Response(toggleSuccessJson, 200);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);

      expect(provider.isMarkupEnabled, isFalse);
      expect(provider.markupCategories, isEmpty);

      final resp = await provider.toggleMarkup(
        toggleChecked: 0,
        emailInput: 'praveen@braintreeproducts.com',
        passwordInput: '12345',
      );

      expect(resp.isSuccess, isTrue);
      expect(provider.isMarkupEnabled, isTrue);
      expect(provider.markupCategories, contains('melle'));
    });

    testWidgets('MarkupToggleDialog renders PASSWORD VERIFY and takes email from session', (tester) async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['emailInput'], 'test@user.com');
        expect(body['passwordInput'], 'secret');
        return http.Response(toggleSuccessJson, 200);
      });
      final repo = AuthRepository(remoteDataSource: AuthRemoteDataSource(client: mockClient));
      final provider = AuthProvider(repository: repo);
      provider.setSavedCredentials('test@user.com', '');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: MarkupToggleDialog(initialEmail: 'test@user.com'),
            ),
          ),
        ),
      );

      expect(find.text('PASSWORD VERIFY'), findsOneWidget);
      expect(find.text('ENTER PASSWORD'), findsOneWidget);
      expect(find.text('VERIFY'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);

      // Email field is omitted because email is taken directly from session
      expect(find.text('ENTER EMAIL / USERNAME'), findsNothing);

      // Enter password
      await tester.enterText(find.byType(TextFormField).first, 'secret');
      await tester.pump();

      // Tap verify
      await tester.tap(find.text('VERIFY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Markup updated successfully'), findsOneWidget);
    });
  });
}

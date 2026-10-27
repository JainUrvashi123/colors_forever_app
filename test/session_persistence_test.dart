import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/main.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:colors_forever_app/features/auth/data/models/user_model.dart';
import 'package:colors_forever_app/features/auth/data/repositories/auth_repository.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/features/navigation/views/main_shell_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testUser = UserModel(
    userId: '25',
    parentId: '20',
    fullName: 'Pankaj Kumar',
    active: '1',
    company: 'Braintree Products',
    logo: 'logo.png',
    group: 1,
  );

  const loginSuccessJson = '''{
    "status": 1,
    "message": "Login Successfully",
    "details": {
      "user_id": "25",
      "parent_id": "20",
      "fullname": "Pankaj Kumar",
      "active": "1",
      "company": "Braintree Products",
      "logo": "logo.png",
      "group": 1
    }
  }''';

  const toggleMarkupSuccessJson = '''{
    "status": 1,
    "message": "Markup enabled successfully",
    "details": {
      "user_id": "25",
      "is_markup": 1,
      "updated": ["diamond", "jewelry"]
    }
  }''';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthLocalDataSource Unit Tests', () {
    test('saveUserSession and getUserSession persist and restore UserModel correctly', () async {
      final localDataSource = AuthLocalDataSource();

      expect(await localDataSource.hasActiveSession(), isFalse);
      expect(await localDataSource.getUserSession(), isNull);

      await localDataSource.saveUserSession(testUser);

      expect(await localDataSource.hasActiveSession(), isTrue);
      final restoredUser = await localDataSource.getUserSession();
      expect(restoredUser, isNotNull);
      expect(restoredUser!.userId, '25');
      expect(restoredUser.fullName, 'Pankaj Kumar');
      expect(restoredUser.company, 'Braintree Products');
      expect(restoredUser.isActive, isTrue);
    });

    test('saveCredentials and getSavedCredentials persist login info and remember flag', () async {
      final localDataSource = AuthLocalDataSource();

      await localDataSource.saveCredentials(
        'praveen@braintreeproducts.com',
        'secret123',
        remember: true,
      );

      final creds = await localDataSource.getSavedCredentials();
      expect(creds['username'], 'praveen@braintreeproducts.com');
      expect(creds['password'], 'secret123');
      expect(await localDataSource.getRememberMe(), isTrue);
    });

    test('saveMarkupState and getMarkupState persist dealer toggle settings', () async {
      final localDataSource = AuthLocalDataSource();

      await localDataSource.saveMarkupState(
        isEnabled: true,
        categories: ['diamond', 'jewelry', 'melle'],
      );

      expect(await localDataSource.getMarkupState(), isTrue);
      final categories = await localDataSource.getMarkupCategories();
      expect(categories, contains('diamond'));
      expect(categories, contains('jewelry'));
      expect(categories, contains('melle'));
    });

    test('clearSession purges active session while preserving optional username', () async {
      final localDataSource = AuthLocalDataSource();

      await localDataSource.saveUserSession(testUser);
      await localDataSource.saveCredentials('praveen@test.com', 'pwd123', remember: true);
      await localDataSource.saveMarkupState(isEnabled: true, categories: ['diamond']);

      // Clear session keeping username
      await localDataSource.clearSession(keepSavedUsername: true);

      expect(await localDataSource.hasActiveSession(), isFalse);
      expect(await localDataSource.getUserSession(), isNull);
      expect(await localDataSource.getMarkupState(), isNull);

      final creds = await localDataSource.getSavedCredentials();
      expect(creds['username'], 'praveen@test.com');
      expect(creds['password'], isNull);

      // Full clear
      await localDataSource.clearSession(keepSavedUsername: false);
      final credsAfter = await localDataSource.getSavedCredentials();
      expect(credsAfter['username'], isNull);
    });
  });

  group('AuthRepository Session Integration Tests', () {
    test('login automatically saves session to local storage', () async {
      final mockClient = MockClient((request) async {
        return http.Response(loginSuccessJson, 200);
      });

      final remoteDataSource = AuthRemoteDataSource(client: mockClient);
      final localDataSource = AuthLocalDataSource();
      final repository = AuthRepository(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );

      final result = await repository.login(
        username: 'praveen@braintreeproducts.com',
        password: '12345',
        remember: true,
      );

      expect(result.isSuccess, isTrue);
      expect(repository.isAuthenticated, isTrue);

      // Verify local data source has the session saved
      final savedUser = await localDataSource.getUserSession();
      expect(savedUser, isNotNull);
      expect(savedUser!.fullName, 'Pankaj Kumar');

      final savedCreds = await localDataSource.getSavedCredentials();
      expect(savedCreds['username'], 'praveen@braintreeproducts.com');
      expect(savedCreds['password'], '12345');
    });

    test('restoreSession restores logged in user across new repository instances', () async {
      final localDataSource = AuthLocalDataSource();
      await localDataSource.saveUserSession(testUser);
      await localDataSource.saveCredentials('praveen@braintreeproducts.com', '12345');

      // Create brand new repository representing app relaunch
      final newRepository = AuthRepository(localDataSource: localDataSource);
      expect(newRepository.isAuthenticated, isFalse);

      final restored = await newRepository.restoreSession();
      expect(restored, isNotNull);
      expect(newRepository.isAuthenticated, isTrue);
      expect(newRepository.currentUser?.fullName, 'Pankaj Kumar');
      expect(newRepository.savedUsername, 'praveen@braintreeproducts.com');
      expect(newRepository.savedPassword, '12345');
    });

    test('toggleMarkup updates persisted markup state', () async {
      final mockClient = MockClient((request) async {
        return http.Response(toggleMarkupSuccessJson, 200);
      });

      final localDataSource = AuthLocalDataSource();
      final repository = AuthRepository(
        remoteDataSource: AuthRemoteDataSource(client: mockClient),
        localDataSource: localDataSource,
      );

      final response = await repository.toggleMarkup(
        toggleChecked: 1,
        emailInput: 'praveen@braintreeproducts.com',
        passwordInput: '12345',
      );

      expect(response.isSuccess, isTrue);
      expect(await localDataSource.getMarkupState(), isTrue);
      expect(await localDataSource.getMarkupCategories(), contains('diamond'));
    });
  });

  group('AuthProvider Session & Auto-Login Provider Tests', () {
    test('initSession auto-logs in user and restores markup state', () async {
      final localDataSource = AuthLocalDataSource();
      await localDataSource.saveUserSession(testUser);
      await localDataSource.saveCredentials('praveen@braintreeproducts.com', '12345');
      await localDataSource.saveMarkupState(
        isEnabled: true,
        categories: ['diamond', 'jewelry'],
      );

      final repository = AuthRepository(localDataSource: localDataSource);
      final provider = AuthProvider(repository: repository);

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isMarkupEnabled, isFalse);

      await provider.initSession();

      expect(provider.isInitialized, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.fullName, 'Pankaj Kumar');
      expect(provider.savedUsername, 'praveen@braintreeproducts.com');
      expect(provider.hasSavedCredentials, isTrue);
      expect(provider.isMarkupEnabled, isTrue);
      expect(provider.markupCategories, contains('diamond'));
    });

    test('logout clears persistent session and resets provider state', () async {
      final localDataSource = AuthLocalDataSource();
      await localDataSource.saveUserSession(testUser);
      await localDataSource.saveCredentials('praveen@braintreeproducts.com', '12345');

      final repository = AuthRepository(localDataSource: localDataSource);
      final provider = AuthProvider(repository: repository);
      await provider.initSession();

      expect(provider.isAuthenticated, isTrue);

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.isMarkupEnabled, isFalse);
      expect(await localDataSource.hasActiveSession(), isFalse);
    });
  });

  group('ColorsForeverApp Auto-Login Widget Flow', () {
    testWidgets('App renders logged-in user in boutique header when session is restored', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final localDataSource = AuthLocalDataSource();
      await localDataSource.saveUserSession(testUser);
      await localDataSource.saveCredentials('praveen@braintreeproducts.com', '12345');

      final repository = AuthRepository(localDataSource: localDataSource);
      final authProvider = AuthProvider(repository: repository);
      await authProvider.initSession();

      // Launch app with restored session
      await tester.pumpWidget(ColorsForeverApp(authProvider: authProvider));
      await tester.pump(const Duration(milliseconds: 3500));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      // Verify MainShellScreen is rendered when logged in
      expect(find.byType(MainShellScreen), findsOneWidget);
    });

    testWidgets('App renders LOGIN for unauthenticated user on home screen', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = AuthRepository();
      final authProvider = AuthProvider(repository: repository);

      await tester.pumpWidget(ColorsForeverApp(authProvider: authProvider));
      await tester.pump(const Duration(milliseconds: 3500));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(find.byType(MainShellScreen), findsOneWidget);
    });
  });
}

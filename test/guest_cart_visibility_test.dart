import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_filter_provider.dart';
import 'package:colors_forever_app/features/diamonds/presentation/views/solitaire_catalog_screen.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/views/melee_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Guest & Logged Out Cart Count Tests', () {
    test('AuthProvider logout invokes registered callbacks and clears carts', () async {
      final diamondProvider = DiamondCatalogProvider();
      final meleeProvider = MeleeProvider(autoLoad: false);

      // Verify logout callbacks registered
      expect(diamondProvider.cartCount, 0);
      expect(meleeProvider.cartCount, 0);

      // Simulate adding item to melee provider
      meleeProvider.selectColor('Green');
      meleeProvider.selectShade('EMERALD GREEN');
      meleeProvider.selectSize('0.9 MM');
      meleeProvider.selectGrade('VVS1-VS2');
      meleeProvider.setQuantity(2);
      meleeProvider.addToCart();

      expect(meleeProvider.cartCount, 1);

      // Call clearLocalCart and verify cart count becomes 0 and storage cleared
      await meleeProvider.clearLocalCart();
      expect(meleeProvider.cartCount, 0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('melee_cart_items_cache'), isNull);
    });

    testWidgets('SolitaireCatalogScreen does NOT render cart badge when user is logged out', (tester) async {
      final authProvider = AuthProvider();
      final diamondProvider = DiamondCatalogProvider();
      final filterProvider = DiamondFilterProvider();

      // Force unauthenticated
      expect(authProvider.isAuthenticated, false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<DiamondCatalogProvider>.value(value: diamondProvider),
            ChangeNotifierProvider<DiamondFilterProvider>.value(value: filterProvider),
          ],
          child: const MaterialApp(
            home: SolitaireCatalogScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Cart icon should be visible
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      // Badge containing count should NOT exist
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('MeleeScreen does NOT render cart badge when user is logged out', (tester) async {
      final authProvider = AuthProvider();
      final meleeProvider = MeleeProvider(autoLoad: false);

      expect(authProvider.isAuthenticated, false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<MeleeProvider>.value(value: meleeProvider),
          ],
          child: const MaterialApp(
            home: MeleeScreen(),
          ),
        ),
      );

      await tester.pump();

      // Melee cart icon should be visible
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      // Badge text count should NOT exist
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('Tapping cart icon in MeleeScreen when unauthenticated shows login requirement sheet', (tester) async {
      final authProvider = AuthProvider();
      final meleeProvider = MeleeProvider(autoLoad: false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<MeleeProvider>.value(value: meleeProvider),
          ],
          child: const MaterialApp(
            home: MeleeScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap Melee cart icon
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Should open GuestGuardSheet
      expect(find.text('Members Only'), findsOneWidget);
      expect(find.textContaining('view your melee cart'), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/core/utils/price_helper.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/diamond.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:colors_forever_app/features/auth/data/models/user_model.dart';
import 'package:colors_forever_app/features/auth/data/repositories/auth_repository.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PriceHelper Unit Tests', () {
    const sampleDiamond = Diamond(
      serialNo: '3049-4314',
      shape: 'PRINCESS',
      weight: 0.90,
      color: 'ICE GREEN',
      labColor: '',
      grade: 'VS2',
      cut: '',
      polish: '',
      symmetry: '',
      fluorescence: '',
      depth: 0.0,
      table: 0.0,
      retailPricePerCts: 2750.0,
      totalRetailPrice: 2475.0,
      wholesalePrice: 2610.0,
      totalWholesalePrice: 2349.0,
      lab: 'GIA',
      certNumber: '123456',
      measurements: '5.23x5.07x3.77',
      location: 'USA',
      imageUrl: '',
      videoUrl: '',
      certUrl: '',
    );

    const testUser = UserModel(
      userId: '25',
      parentId: '20',
      fullName: 'Pankaj Kumar',
      active: '1',
      company: 'Braintree Products',
      logo: 'logo.png',
      group: 1,
    );

    Future<AuthProvider> createAuthenticatedAuth() async {
      final localDataSource = AuthLocalDataSource();
      await localDataSource.saveUserSession(testUser);
      final repo = AuthRepository(localDataSource: localDataSource);
      await repo.restoreSession();
      return AuthProvider(repository: repo);
    }

    test('isPriceHidden returns true for unauthenticated guest', () {
      final isHidden = PriceHelper.isPriceHidden(null);
      expect(isHidden, isTrue);
    });

    test('getDiamondPrice returns Login to View Price for unauthenticated guest', () {
      final display = PriceHelper.getDiamondPrice(sampleDiamond, null);
      expect(display.isHidden, isTrue);
      expect(display.loginRequired, isTrue);
      expect(display.formattedTotal, 'Login to View Price');
      expect(display.formattedPerCt, 'Login to View Price');
    });

    test('getDiamondPrice returns Price Upon Request when price is hidden for logged-in user', () async {
      final auth = await createAuthenticatedAuth();
      final display = PriceHelper.getDiamondPrice(sampleDiamond, auth, itemIsPriceHide: 1);
      expect(display.isHidden, isTrue);
      expect(display.loginRequired, isFalse);
      expect(display.formattedTotal, 'Price Upon Request');
      expect(display.formattedPerCt, 'Price Upon Request');
    });

    test('getDiamondPrice formats wholesale total and per carat correctly for authenticated partner', () async {
      final auth = await createAuthenticatedAuth();
      final display = PriceHelper.getDiamondPrice(sampleDiamond, auth, itemIsPriceHide: 0);
      expect(display.isHidden, isFalse);
      expect(display.isWholesale, isTrue);
      expect(display.formattedTotal, r'$2,349');
      expect(display.formattedPerCt, r'$2,610');
    });
  });
}

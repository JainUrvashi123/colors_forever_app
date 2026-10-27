import 'package:flutter_test/flutter_test.dart';
import 'package:colors_forever_app/features/melee/domain/models/melee_constants.dart';
import 'package:colors_forever_app/features/melee/domain/models/melee_model.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';

void main() {
  group('MeleeProvider Unit Tests', () {
    late MeleeProvider provider;

    setUp(() {
      provider = MeleeProvider();
    });

    test('initial state has correct defaults without autoset', () {
      expect(provider.stoneType, MeleeStoneType.melee);
      expect(provider.viewMode, MeleeViewMode.melee);
      expect(provider.selectedColor, isNull);
      expect(provider.selectedShade, isNull);
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);
      expect(provider.quantity, 0);
      expect(provider.hasQuantity, isFalse);
      expect(provider.cartCount, 0);
      expect(provider.availableSizes, isEmpty);
    });

    test('selectColor sets color without auto-setting shade, and toggling off clears color', () {
      provider.selectColor('Blue');

      expect(provider.selectedColor, 'Blue');
      expect(provider.selectedShade, isNull);
      expect(provider.currentShades, isNotEmpty);

      // Deselect color by selecting same color
      provider.selectColor('Blue');
      expect(provider.selectedColor, isNull);
      expect(provider.selectedShade, isNull);
    });

    test('selectShade sets shade without auto-setting size or grade', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');

      expect(provider.selectedShade, 'SKY BLUE');
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);

      // Deselect shade
      provider.selectShade('SKY BLUE');
      expect(provider.selectedShade, isNull);
    });

    test('selectSize sets size without auto-setting grade, and toggling off clears size', () {
      provider.selectSize('1.0 MM');
      expect(provider.selectedSize, '1.0 MM');
      expect(provider.selectedGrade, isNull);

      // Deselect size
      provider.selectSize('1.0 MM');
      expect(provider.selectedSize, isNull);
    });

    test('selectGrade sets grade and toggling off clears grade', () {
      provider.selectGrade('VVS1-VS2');
      expect(provider.selectedGrade, 'VVS1-VS2');

      provider.selectGrade('VVS1-VS2');
      expect(provider.selectedGrade, isNull);
    });

    test('premium size is accurately detected', () {
      provider.selectSize('1.0 MM');
      expect(provider.isPremiumSizeSelected, isTrue);

      provider.selectSize('0.9 MM');
      expect(provider.isPremiumSizeSelected, isFalse);
    });

    test('quantity modification updates quantity correctly', () {
      expect(provider.hasQuantity, isFalse);
      provider.setQuantity(5);
      expect(provider.quantity, 5);
      expect(provider.hasQuantity, isTrue);

      provider.incrementQuantity();
      expect(provider.quantity, 6);

      provider.decrementQuantity();
      expect(provider.quantity, 5);

      // Clearing / zero resets to 0 and hasQuantity false
      provider.setQuantity(0);
      expect(provider.quantity, 0);
      expect(provider.hasQuantity, isFalse);
    });

    test('addToCart adds parcel item and computes cart totals', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');
      provider.selectSize('0.9 MM');
      provider.selectGrade('VVS1-VS2');
      provider.setQuantity(3);
      provider.setSpecialRequest('Eye clean calibration');

      final success = provider.addToCart();
      expect(success, isTrue);
      expect(provider.cartCount, 1);

      final item = provider.cartItems.first;
      expect(item.color, 'Blue');
      expect(item.shade, 'SKY BLUE');
      expect(item.size, '0.9 MM');
      expect(item.clarity, 'VVS1-VS2');
      expect(item.quantity, 3);
      expect(item.specialRequest, 'Eye clean calibration');
      expect(provider.cartTotalStones, 3);
      expect(provider.cartTotalMinWeight, greaterThan(0.0));
      expect(provider.cartTotalMinPrice, greaterThan(0.0));
    });

    test('cart item removal and clear cart', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');
      provider.selectSize('0.9 MM');
      provider.selectGrade('VVS1-VS2');
      provider.setQuantity(2);
      provider.addToCart();

      expect(provider.cartCount, 1);
      final id = provider.cartItems.first.id;

      provider.removeFromCart(id);
      expect(provider.cartCount, 0);
    });

    test('birthstone selection updates month and shade without autoset', () {
      provider.setStoneType(MeleeStoneType.birthstone);
      expect(provider.stoneType, MeleeStoneType.birthstone);

      final may = MeleeConstants.birthMonths.firstWhere((m) => m.month == 'may');
      provider.selectMonth(may);

      expect(provider.selectedMonth?.month, 'may');
      expect(provider.selectedShade, 'EMERALD GREEN');
      expect(provider.selectedColor, 'Green');
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);

      // Deselect month
      provider.selectMonth(may);
      expect(provider.selectedMonth, isNull);
      expect(provider.selectedShade, isNull);
      expect(provider.selectedColor, isNull);
    });

    test('shade changes clear downstream size, clarity, quantity, and calculations', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');
      provider.selectSize('1.4 MM');
      provider.selectGrade('SI-1');
      provider.setQuantity(5);

      expect(provider.selectedSize, '1.4 MM');
      expect(provider.selectedGrade, 'SI-1');
      expect(provider.quantity, 5);

      // Switch to AQUA BLUE II
      provider.selectShade('AQUA BLUE II');

      // Downstream attributes must be cleanly reset
      expect(provider.selectedShade, 'AQUA BLUE II');
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);
      expect(provider.quantity, 0);
      expect(provider.hasQuantity, isFalse);
    });

    test('color changes clear downstream shade, size, clarity, and quantity', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');
      provider.selectSize('1.2 MM');
      provider.selectGrade('VVS1-VS2');
      provider.setQuantity(3);

      expect(provider.selectedSize, '1.2 MM');
      expect(provider.selectedGrade, 'VVS1-VS2');

      // Switch to Green
      provider.selectColor('Green');

      expect(provider.selectedColor, 'Green');
      expect(provider.selectedShade, isNull);
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);
      expect(provider.quantity, 0);
    });

    test('resetFilter restores initial clean state', () {
      provider.selectColor('Blue');
      provider.selectShade('SKY BLUE');
      provider.selectSize('0.9 MM');
      provider.setQuantity(4);

      provider.resetFilter();

      expect(provider.stoneType, MeleeStoneType.melee);
      expect(provider.selectedColor, isNull);
      expect(provider.selectedShade, isNull);
      expect(provider.selectedSize, isNull);
      expect(provider.selectedGrade, isNull);
      expect(provider.quantity, 0);
      expect(provider.hasQuantity, isFalse);
    });
  });
}

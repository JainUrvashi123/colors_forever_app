import 'package:flutter_test/flutter_test.dart';
import 'package:colors_forever_app/features/diamonds/data/models/diamond_model.dart';
import 'package:colors_forever_app/features/diamonds/domain/entities/diamond_filter.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_filter_provider.dart';

void main() {
  group('DiamondModel Tests', () {
    test('fromJson parses live Colors Forever API json structure correctly', () {
      final json = {
        'shape_full': 'ROUND',
        'SN_SERIALNO': '10301-4422',
        'QT_WEIGHT': '5.52',
        'SN_COLOR': 'AQUA BLUE I',
        'SN_GRADE': 'VVS1',
        'cut_full': 'Ideal',
        'polish_full': 'Excellent',
        'symmetry_full': 'Excellent',
        'fluor_full': 'None',
        'PC_DEPTH': '61.5',
        'PC_TABLE': '60.00',
        'RETAIL_PRICE_PER_CTS': '11500.00',
        'TOTAL_RETAIL_PRICE': '63480.00',
        'WHOLESALE_PRICE': '10930.00',
        'TOTAL_WHOLESALE_PRICE': '60333.60',
        'SN_LAB': 'GIA',
        'UDF4': '1485859720',
        'MEAS': '11.33x11.39x6.98',
        'LOCATION': 'NY',
        'LAB_COLOR': 'FANCY INTENSE GREENISH BLUE',
        'image_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/10301-4422.jpg',
        'video_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/10301-4422.mp4',
        'cert_show': 'https://lotuscolor.s3.us-east-1.amazonaws.com/cert/1485859720.pdf',
        'is_fav': 1,
      };

      final diamond = DiamondModel.fromJson(json);

      expect(diamond.serialNo, '10301-4422');
      expect(diamond.shape, 'ROUND');
      expect(diamond.weight, 5.52);
      expect(diamond.color, 'AQUA BLUE I');
      expect(diamond.grade, 'VVS1');
      expect(diamond.cut, 'Ideal');
      expect(diamond.polish, 'Excellent');
      expect(diamond.symmetry, 'Excellent');
      expect(diamond.fluorescence, 'None');
      expect(diamond.depth, 61.5);
      expect(diamond.table, 60.0);
      expect(diamond.retailPricePerCts, 11500.0);
      expect(diamond.totalRetailPrice, 63480.0);
      expect(diamond.lab, 'GIA');
      expect(diamond.certNumber, '1485859720');
      expect(diamond.measurements, '11.33x11.39x6.98');
      expect(diamond.location, 'NY');
      expect(diamond.isFavorite, true);
    });

    test('fromJson prioritizes N_TOTAL and N_CARAT over base retail and wholesale prices', () {
      final json = {
        'shape_full': 'ROUND',
        'SN_SERIALNO': '10301-2934',
        'QT_WEIGHT': '12.53',
        'SN_COLOR': 'AQUA BLUE I',
        'SN_GRADE': 'IF',
        'RETAIL_PRICE_PER_CTS': '17750.00',
        'TOTAL_RETAIL_PRICE': '222407.50',
        'WHOLESALE_PRICE': '17750.00',
        'TOTAL_WHOLESALE_PRICE': '222407.50',
        'N_CARAT': '18546',
        'N_TOTAL': '232381.38',
      };

      final diamond = DiamondModel.fromJson(json);

      expect(diamond.totalRetailPrice, 232381.38);
      expect(diamond.retailPricePerCts, 18546.0);
      expect(diamond.totalWholesalePrice, 232381.38);
      expect(diamond.wholesalePricePerCts, 18546.0);
    });
  });

  group('DiamondFilter & Provider Tests', () {
    test('Dynamic shades populate according to selected colors', () {
      final provider = DiamondFilterProvider();
      expect(provider.availableShades, isEmpty);

      // Select Blue
      provider.toggleColor('Blue');
      expect(provider.filter.selectedColors, contains('Blue'));
      expect(provider.availableShades, contains('AQUA BLUE'));
      expect(provider.availableShades, contains('SKY BLUE'));
      expect(provider.availableShades, contains('ROYAL BLUE'));

      // Select Yellow
      provider.toggleColor('Yellow');
      expect(provider.availableShades, contains('CANARY YELLOW'));

      // Toggle shade
      provider.toggleShade('AQUA BLUE');
      expect(provider.filter.selectedShades, contains('AQUA BLUE'));

      // Deselect Blue should remove Blue shades
      provider.toggleColor('Blue');
      expect(provider.filter.selectedColors, isNot(contains('Blue')));
      expect(provider.filter.selectedShades, isNot(contains('AQUA BLUE')));
    });

    test('DiamondFilter activeFilterCount calculates accurately', () {
      var filter = const DiamondFilter();
      expect(filter.hasActiveFilters, false);
      expect(filter.activeFilterCount, 0);

      filter = filter.copyWith(
        selectedColors: ['Pink'],
        selectedShapes: ['ROUND', 'OVAL'],
        minCarat: 1.5,
        location: 'NY',
      );

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 5); // 1 color + 2 shapes + 1 carat + 1 location
    });
  });
}

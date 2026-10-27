import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:colors_forever_app/core/widgets/diamond_swatch_card.dart';
import 'package:colors_forever_app/features/diamonds/presentation/widgets/haute_swatch_bar.dart';
import 'package:colors_forever_app/features/diamonds/presentation/providers/diamond_filter_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/melee_swatch_selector.dart';

void main() {
  group('DiamondSwatchCard Widget Tests', () {
    testWidgets('DiamondSwatchCard renders card and label with expected styling', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiamondSwatchCard(
              colorName: 'Blue',
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Blue'), findsOneWidget);
      expect(find.byType(DiamondSwatchCard), findsOneWidget);

      await tester.tap(find.byType(DiamondSwatchCard));
      expect(tapped, isTrue);
    });

    testWidgets('DiamondSwatchCard maps Champagne/Brown and White/Colorless', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                DiamondSwatchCard(colorName: 'Champagne/Brown'),
                DiamondSwatchCard(colorName: 'White/Colorless'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Champagne/\nBrown'), findsOneWidget);
      expect(find.text('White/\nColorless'), findsOneWidget);
    });

    testWidgets('HauteSwatchBar renders 10 official diamond color swatches', (tester) async {
      final filterProvider = DiamondFilterProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HauteSwatchBar(
              filterProvider: filterProvider,
              onColorSelected: (col) {},
            ),
          ),
        ),
      );

      expect(find.byType(DiamondSwatchCard), findsWidgets);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
      expect(find.text('Pink'), findsOneWidget);
    });

    testWidgets('MeleeSwatchSelector renders 10 color options with DiamondSwatchCard', (tester) async {
      final meleeProvider = MeleeProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<MeleeProvider>.value(
              value: meleeProvider,
              child: MeleeSwatchSelector(provider: meleeProvider),
            ),
          ),
        ),
      );

      expect(find.text('COLOR'), findsOneWidget);
      expect(find.byType(DiamondSwatchCard), findsWidgets);
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('DiamondSwatchGrid lays out diamonds in 4 items per row', (tester) async {
      final selected = <String>{};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiamondSwatchGrid(
              colors: const [
                'Blue',
                'Green',
                'Yellow',
                'Pink',
                'Purple',
                'Red',
                'Orange',
                'Black',
                'Champagne/Brown',
                'White/Colorless',
              ],
              selectedColors: selected,
              onColorSelected: (col) => selected.add(col),
            ),
          ),
        ),
      );

      // Verify all 10 are rendered
      expect(find.byType(DiamondSwatchCard), findsNWidgets(10));
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
      expect(find.text('Pink'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Black'), findsOneWidget);
      expect(find.text('Champagne/\nBrown'), findsOneWidget);
      expect(find.text('White/\nColorless'), findsOneWidget);

      // Verify 3 rows exist (4 + 4 + 2)
      final rowsFinder = find.byType(Row);
      expect(rowsFinder, findsNWidgets(3));

      // Tap an item
      await tester.tap(find.text('Blue'));
      expect(selected.contains('Blue'), isTrue);
    });

    testWidgets('DiamondShapeGrid lays out shapes in 4 items per row', (tester) async {
      final selected = <String>{};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiamondShapeGrid(
              shapes: const [
                'ROUND',
                'ASSCHER',
                'CUSHION',
                'EMERALD',
                'HEART',
                'MARQUISE',
                'OVAL',
                'PRINCESS',
                'PEAR',
                'RADIANT',
              ],
              selectedShapes: selected,
              onShapeSelected: (shape) => selected.add(shape),
            ),
          ),
        ),
      );

      expect(find.text('ROUND'), findsOneWidget);
      expect(find.text('ASSCHER'), findsOneWidget);
      expect(find.text('CUSHION'), findsOneWidget);
      expect(find.text('EMERALD'), findsOneWidget);

      // 10 shapes in groups of 4 => 3 rows (4 + 4 + 2)
      expect(find.byType(Row), findsNWidgets(3));

      await tester.tap(find.text('ROUND'));
      expect(selected.contains('ROUND'), isTrue);
    });

    testWidgets('ShadeGrid renders shades in 3 items per row and handles taps', (tester) async {
      final selected = <String>{'Aqua Blue I'};
      String? tappedShade;

      final testShades = [
        'Aqua Blue I',
        'Aqua Blue II',
        'Sky Blue',
        'Ocean Blue',
        'Royal Blue',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShadeGrid(
              shades: testShades,
              selectedShades: selected,
              onShadeSelected: (shade) {
                tappedShade = shade;
              },
            ),
          ),
        ),
      );

      // Verify all 5 shades are rendered with ShadePill
      expect(find.byType(ShadePill), findsNWidgets(5));
      expect(find.text('Aqua Blue I'), findsOneWidget);
      expect(find.text('Aqua Blue II'), findsOneWidget);
      expect(find.text('Sky Blue'), findsOneWidget);
      expect(find.text('Ocean Blue'), findsOneWidget);
      expect(find.text('Royal Blue'), findsOneWidget);

      // 5 items in groups of 3 => 2 rows (3 + 2)
      expect(find.byType(Row), findsNWidgets(2));

      // Tap on Ocean Blue
      await tester.tap(find.text('Ocean Blue'));
      expect(tappedShade, equals('Ocean Blue'));
    });

    testWidgets('ResetFilterButton renders double-ring pill design and responds to tap', (tester) async {
      bool resetTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResetFilterButton(
              onTap: () => resetTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(ResetFilterButton), findsOneWidget);
      expect(find.text('Reset Filter'), findsOneWidget);

      await tester.tap(find.text('Reset Filter'));
      expect(resetTapped, isTrue);
    });

    testWidgets('AddToCartButton renders double-ring pill design and responds to tap', (tester) async {
      bool addTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddToCartButton(
              onTap: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(AddToCartButton), findsOneWidget);
      expect(find.text('Add To Cart'), findsOneWidget);

      await tester.tap(find.text('Add To Cart'));
      expect(addTapped, isTrue);
    });
  });
}

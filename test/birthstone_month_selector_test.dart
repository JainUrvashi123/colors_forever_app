import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:colors_forever_app/features/melee/domain/models/melee_model.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/birthstone_month_selector.dart';

void main() {
  Widget createTestWidget(MeleeProvider provider) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<MeleeProvider>.value(
          value: provider,
          child: BirthstoneMonthSelector(provider: provider),
        ),
      ),
    );
  }

  testWidgets('BirthstoneMonthSelector renders MONTH header and all 12 months', (tester) async {
    final provider = MeleeProvider();
    provider.setStoneType(MeleeStoneType.birthstone);

    await tester.pumpWidget(createTestWidget(provider));
    await tester.pumpAndSettle();

    expect(find.text('MONTH'), findsOneWidget);
    expect(find.text('January'), findsOneWidget);
    expect(find.text('February'), findsOneWidget);
    expect(find.text('March'), findsOneWidget);
    expect(find.text('April'), findsOneWidget);
    expect(find.text('May'), findsOneWidget);
    expect(find.text('June'), findsOneWidget);
    expect(find.text('July'), findsOneWidget);
    expect(find.text('August'), findsOneWidget);
    expect(find.text('September'), findsOneWidget);
    expect(find.text('October'), findsOneWidget);
    expect(find.text('November'), findsOneWidget);
    expect(find.text('December'), findsOneWidget);
  });

  testWidgets('Tapping November selects November and updates provider', (tester) async {
    final provider = MeleeProvider();
    provider.setStoneType(MeleeStoneType.birthstone);

    await tester.pumpWidget(createTestWidget(provider));
    await tester.pumpAndSettle();

    final novFinder = find.text('November');
    await tester.tap(novFinder);
    await tester.pumpAndSettle();

    expect(provider.selectedMonth?.month, 'november');
    expect(find.text('November • GOLDEN YELLOW'), findsOneWidget);
  });
}

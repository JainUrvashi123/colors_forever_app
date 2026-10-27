import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/main.dart';
import 'package:colors_forever_app/features/navigation/views/main_shell_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Colors Forever app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorsForeverApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(find.byType(ColorsForeverApp), findsOneWidget);
    expect(find.byType(MainShellScreen), findsOneWidget);
  });

  testWidgets('Home screen has search bar and category chips commented out till our collections', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorsForeverApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    // Search bar and quick category pills are commented out
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Solitaire Catalog'), findsNothing);
    expect(find.text('Concierge'), findsNothing);
  });

  testWidgets('Home screen renders official collection sections without hero banner carousel', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorsForeverApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    // Banner carousel PageView is commented out
    expect(find.byType(PageView), findsNothing);

    // Verify Collections headline directly on home screen
    expect(find.text('Our Collections'), findsOneWidget);
    expect(find.text('The Colors Forever Distinction'), findsOneWidget);
    expect(find.text('100% Natural Diamonds'), findsOneWidget);
  });

  testWidgets('Tapping Browse Solitaires collection card switches to Solitaire tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorsForeverApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    // Tap on Solitaire Diamonds collection card
    final solitaireCard = find.text('Browse Solitaires');
    expect(solitaireCard, findsOneWidget);
    await tester.tap(solitaireCard);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify we navigated to Solitaire tab (index 2)
    final mainShell = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(mainShell.index, equals(2));
  });

  testWidgets('Tapping Melee Diamonds collection card switches to Melee screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorsForeverApp());
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    final meleeCard = find.text('Shop Melee Parcels');
    expect(meleeCard, findsOneWidget);
    await tester.tap(meleeCard);
    await tester.pump(const Duration(milliseconds: 300));

    final mainShell = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(mainShell.index, equals(1));
  });
}


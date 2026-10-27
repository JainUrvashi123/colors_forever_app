import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:colors_forever_app/core/theme/app_theme.dart';
import 'package:colors_forever_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/providers/melee_provider.dart';
import 'package:colors_forever_app/features/melee/presentation/views/melee_screen.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/melee_calculator_section.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/melee_cart_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colors_forever_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:colors_forever_app/features/auth/data/models/user_model.dart';
import 'package:colors_forever_app/features/auth/data/repositories/auth_repository.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/melee_preview_card.dart';
import 'package:colors_forever_app/features/melee/presentation/widgets/melee_swatch_selector.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({bool authenticated = false}) {
    final user = authenticated
        ? const UserModel(
            userId: '25',
            parentId: '20',
            fullName: 'Test User',
            active: '1',
            company: 'Test Co',
            logo: '',
            group: 1,
          )
        : null;
    final authRepo = AuthRepository(currentUser: user);
    final authProvider = AuthProvider(repository: authRepo);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MeleeProvider(autoLoad: false)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MeleeScreen(),
      ),
    );
  }

  testWidgets('MeleeScreen renders complete mobile workflow and UI controls', (tester) async {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(authenticated: true));
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Verify Top Bar and Switcher
    expect(find.text('Melee Diamonds'), findsOneWidget);
    expect(find.text('Melee'), findsWidgets);
    expect(find.text('Birth Stone'), findsOneWidget);
    expect(find.text('COLOR'), findsOneWidget);

    // 2. Verify Colors (MeleeSwatchSelector & Tooltips)
    expect(find.byType(MeleeSwatchSelector), findsOneWidget);
    expect(find.byTooltip('Blue'), findsOneWidget);
    expect(find.byTooltip('Green'), findsOneWidget);
    expect(find.byTooltip('Yellow'), findsOneWidget);

    // 3. Verify Bottom Action Buttons in initial State (Only Reset Filter)
    expect(find.text('Reset Filter'), findsOneWidget);
    expect(find.text('Add To Cart'), findsNothing);

    // 4. Select "Blue" color
    final provider = tester.element(find.byType(MeleeScreen)).read<MeleeProvider>();
    provider.selectColor('Blue');
    await tester.pump(const Duration(milliseconds: 200));

    // 5. Verify Shade row appears (Size/Clarity not yet shown without shade)
    expect(find.text('SHADE'), findsOneWidget);
    expect(find.text('Aqua Blue I'), findsWidgets);
    expect(find.text('Sky Blue'), findsWidgets);
    expect(find.text('SIZE'), findsNothing);

    // 6. Select Shade "Sky Blue" -> Size row appears
    provider.selectShade('Sky Blue');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('SIZE'), findsOneWidget);
    expect(find.text('CLARITY'), findsNothing);

    // 7. Select Size "1.1 MM" via Size Dropdown -> Clarity row appears
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('0.9 MM'), findsWidgets);
    expect(find.text('1.1 MM'), findsWidgets);
    await tester.tap(find.text('1.1 MM').last);
    await tester.pumpAndSettle();
    expect(provider.selectedSize, '1.1 MM');
    expect(find.text('CLARITY'), findsOneWidget);
    expect(find.text('NUMBER OF\nDIAMONDS'), findsNothing);

    // 8. Select Clarity "VVS1-VS2" via Clarity Dropdown -> Number of Diamonds appears
    await tester.ensureVisible(find.byKey(const Key('clarity_dropdown')));
    await tester.tap(find.byKey(const Key('clarity_dropdown')));
    await tester.pumpAndSettle();
    expect(find.text('VVS1-VS2'), findsWidgets);
    await tester.tap(find.text('VVS1-VS2').last);
    await tester.pumpAndSettle();
    expect(provider.selectedGrade, 'VVS1-VS2');
    expect(find.text('NUMBER OF\nDIAMONDS'), findsOneWidget);

    // State 1: Quantity empty -> calculations & Add To Cart hidden
    expect(find.byType(RedHandOutlinePointer), findsNothing);
    expect(find.text('PRICE PER\nCARAT'), findsNothing);
    expect(find.text('ESTIMATE\nCARAT WEIGHT'), findsNothing);
    expect(find.text('ESTIMATE\nVALUE USD'), findsNothing);
    expect(find.text('Add To Cart'), findsNothing);

    // Enter quantity '5' to transition to State 2
    final qtyFinder = find.byType(TextField).first;
    await tester.enterText(qtyFinder, '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));

    // State 2: calculations and Add To Cart visible
    expect(find.byType(RedHandOutlinePointer), findsNothing);
    expect(find.text('PRICE PER\nCARAT'), findsOneWidget);
    expect(find.text('ESTIMATE\nCARAT WEIGHT'), findsOneWidget);
    expect(find.text('ESTIMATE\nVALUE USD'), findsOneWidget);
    expect(find.text('Add To Cart'), findsOneWidget);

    // Test removing quantity -> estimates and Add To Cart overall remove!
    await tester.enterText(qtyFinder, '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(RedHandOutlinePointer), findsNothing);
    expect(find.text('PRICE PER\nCARAT'), findsNothing);
    expect(find.text('ESTIMATE\nCARAT WEIGHT'), findsNothing);
    expect(find.text('ESTIMATE\nVALUE USD'), findsNothing);
    expect(find.text('Add To Cart'), findsNothing);

    // Re-enter quantity for subsequent cart test
    await tester.enterText(qtyFinder, '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));

    // 7. Scroll and tap "Add To Cart"
    await tester.ensureVisible(find.text('Add To Cart').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Add To Cart').last);
    await tester.pump(const Duration(milliseconds: 200));

    // Verify cart badge count is 1
    expect(find.text('1'), findsWidgets);

    // 8. Open Melee Cart
    MeleeCartSheet.show(tester.element(find.byType(MeleeScreen)), provider);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Cart bottom sheet displays
    expect(find.text('Melee Cart (1)'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
    expect(find.text('Request Memo / Email'), findsOneWidget);
  });


  testWidgets('MeleeScreen does not display warning note banner above preview', (tester) async {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.campaign_outlined), findsNothing);
    expect(find.textContaining('PLEASE TRY AND AVOID'), findsNothing);
  });

  testWidgets('Deselecting size or clarity cleanly overall removes lower sections', (tester) async {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 100));

    final provider = tester.element(find.byType(MeleeScreen)).read<MeleeProvider>();
    provider.selectColor('Blue');
    await tester.pump(const Duration(milliseconds: 200));

    // Initially without shade, lower sections are not shown
    expect(find.text('SHADE'), findsOneWidget);
    expect(find.text('SIZE'), findsNothing);

    // Select shade
    provider.selectShade('Sky Blue');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('SIZE'), findsOneWidget);

    // Select size 0.9 MM
    provider.selectSize('0.9 MM');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('CLARITY'), findsOneWidget);

    // Select clarity VVS1-VS2 via clarity dropdown
    await tester.ensureVisible(find.byKey(const Key('clarity_dropdown')));
    await tester.tap(find.byKey(const Key('clarity_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VVS1-VS2').last);
    await tester.pumpAndSettle();
    expect(provider.selectedGrade, 'VVS1-VS2');
    expect(find.text('NUMBER OF\nDIAMONDS'), findsOneWidget);

    // Clear clarity to deselect clarity
    provider.selectGrade(null);
    await tester.pump(const Duration(milliseconds: 100));
    expect(provider.selectedGrade, isNull);

    // When clarity is removed, NUMBER OF DIAMONDS is overall removed!
    expect(find.text('NUMBER OF\nDIAMONDS'), findsNothing);

    // Re-select clarity via dropdown
    await tester.ensureVisible(find.byKey(const Key('clarity_dropdown')));
    await tester.tap(find.byKey(const Key('clarity_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VVS1-VS2').last);
    await tester.pumpAndSettle();
    expect(provider.selectedGrade, 'VVS1-VS2');
    expect(find.text('NUMBER OF\nDIAMONDS'), findsOneWidget);

    // Clear size to deselect size
    provider.selectSize(null);
    await tester.pump(const Duration(milliseconds: 100));
    expect(provider.selectedSize, isNull);

    // When size is removed, CLARITY and NUMBER OF DIAMONDS are overall removed!
    expect(find.text('CLARITY'), findsNothing);
    expect(find.text('NUMBER OF\nDIAMONDS'), findsNothing);
  });

  testWidgets('MeleePreviewCard top image is commented out in Melee screen', (tester) async {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 100));

    // Top image card is commented out as requested
    expect(find.byType(MeleePreviewCard), findsNothing);

    // Switch to Birth Stone mode
    await tester.tap(find.text('Birth Stone'));
    await tester.pump(const Duration(milliseconds: 200));

    // Birth Month selector is shown
    expect(find.text('MONTH'), findsOneWidget);

    // Switch back to Melee mode
    await tester.tap(find.text('Melee').first);
    await tester.pump(const Duration(milliseconds: 200));

    // Color Swatches are shown without top preview card
    expect(find.text('COLOR'), findsOneWidget);
    expect(find.byType(MeleePreviewCard), findsNothing);
  });

  testWidgets('Entering quantity updates calculations after typing pause or keyboard close', (tester) async {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 100));

    final provider = tester.element(find.byType(MeleeScreen)).read<MeleeProvider>();
    provider.selectColor('Blue');
    provider.selectShade('Sky Blue');
    provider.selectSize('0.9 MM');
    provider.selectGrade('VVS1-VS2');
    await tester.pumpAndSettle();

    expect(find.text('NUMBER OF\nDIAMONDS'), findsOneWidget);
    expect(find.text('PRICE PER\nCARAT'), findsNothing);

    // Enter text "2" without pressing done button
    final qtyFinder = find.byType(TextField).first;
    await tester.enterText(qtyFinder, '2');
    await tester.pump(const Duration(milliseconds: 100));

    // Advance timer by 1500ms debounce
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('PRICE PER\nCARAT'), findsOneWidget);
    expect(provider.quantity, 2);
  });
}

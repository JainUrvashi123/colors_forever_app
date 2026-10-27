import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colors_forever_app/core/constants/app_assets.dart';
import 'package:colors_forever_app/core/widgets/app_background.dart';

void main() {
  group('Background Image Integration Tests', () {
    test('AppAssets.backgroundImage points to assets/images/colorsfor.jpg', () {
      expect(AppAssets.backgroundImage, equals('assets/images/colorsfor.jpg'));
    });

    testWidgets('AppBackground renders colorsfor.jpg with BoxFit.cover behind child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: Text('Test Content')),
            ),
          ),
        ),
      );

      // Verify the content is visible
      expect(find.text('Test Content'), findsOneWidget);

      // Verify AppBackground contains an Image widget with assets/images/colorsfor.jpg
      final imageWidgets = tester.widgetList<Image>(find.byType(Image));
      expect(imageWidgets, isNotEmpty);
      final Image imageWidget = imageWidgets.first;
      expect(imageWidget.image, isA<AssetImage>());
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/colorsfor.jpg'));
      expect(imageWidget.fit, equals(BoxFit.cover));
    });
  });
}

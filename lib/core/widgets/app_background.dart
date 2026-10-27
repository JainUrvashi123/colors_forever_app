import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// A full-bleed luxury wallpaper widget that displays [colorsfor.jpg]
/// behind all screen content, matching the fixed background behavior of
/// Colors Forever (https://colorsforever.com/melle-diamond).
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image matching `background: url(...) cover fixed`
        Image.asset(
          AppAssets.backgroundImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        // Foreground UI Content
        child,
      ],
    );
  }
}

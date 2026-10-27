import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/diamonds/presentation/providers/diamond_filter_provider.dart';
import 'features/diamonds/presentation/providers/diamond_catalog_provider.dart';
import 'features/melee/presentation/providers/melee_provider.dart';
import 'features/jewelry/presentation/providers/jewelry_provider.dart';
import 'features/splash/presentation/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.initSession();
  runApp(ColorsForeverApp(authProvider: authProvider));
}

class ColorsForeverApp extends StatelessWidget {
  final AuthProvider? authProvider;

  const ColorsForeverApp({super.key, this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (authProvider != null)
          ChangeNotifierProvider.value(value: authProvider!)
        else
          ChangeNotifierProvider(create: (_) => AuthProvider()..initSession()),
        ChangeNotifierProvider(create: (_) => DiamondFilterProvider()),
        ChangeNotifierProvider(create: (_) => DiamondCatalogProvider()),
        ChangeNotifierProvider(create: (_) => MeleeProvider()),
        ChangeNotifierProvider(create: (_) => JewelryProvider()),
      ],
      child: MaterialApp(
        title: 'Colors Forever',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

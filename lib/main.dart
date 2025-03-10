import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/config/app_theme.dart';
import 'package:qlz_flash_cards_ui/core/managers/cubit_manager.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize CubitManager
  await CubitManager().initialize();

  runApp(const QlzFlashCardsApp());
}

final class QlzFlashCardsApp extends StatelessWidget {
  const QlzFlashCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = CubitManager().globalProviders;

    final app = MaterialApp(
      title: 'Quizlet Flash Cards',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark theme vì design là dark mode
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: WebScrollBehavior(),
          child: child!,
        );
      },
    );

    // Chỉ sử dụng MultiBlocProvider khi có providers
    if (providers.isEmpty) {
      return app;
    }

    return MultiBlocProvider(
      providers: providers,
      child: app,
    );
  }
}

// Custom scroll behavior for web support
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
      };
}

// lib/main.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/config/app_theme.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Khởi tạo SharedPreferences để sử dụng với Riverpod
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // Đặt ProviderScope ở mức cao nhất của ứng dụng
    ProviderScope(
      // Override SharedPreferences provider với instance thực
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const QlzFlashCardsApp(),
    ),
  );
}

final class QlzFlashCardsApp extends StatelessWidget {
  const QlzFlashCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
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

    // Trả về app trực tiếp vì các providers đã được cung cấp bởi ProviderScope ở mức cao nhất
    return app;
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

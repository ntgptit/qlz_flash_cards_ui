// lib/features/dashboard/dashboard_module.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/dashboard_repository.dart';
import 'logic/cubit/dashboard_cubit.dart';

/// Module that provides the dashboard feature with necessary dependencies
class DashboardModule {
  /// Creates the dashboard screen with all dependencies
  static Widget create() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            color: Color(0xFF0A092D),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final sharedPrefs = snapshot.data!;
        final repository = DashboardRepository(Dio(), sharedPrefs);

        return RepositoryProvider.value(
          value: repository,
          child: BlocProvider(
            create: (context) => DashboardCubit(repository),
            child: const DashboardScreen(),
          ),
        );
      },
    );
  }
}

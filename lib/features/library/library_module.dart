// lib/features/library/library_module.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/library_repository.dart';
import 'logic/cubit/classes_cubit.dart';
import 'logic/cubit/folders_cubit.dart';
import 'logic/cubit/study_sets_cubit.dart';
import 'presentation/screens/library_screen.dart';

/// A simplified approach to providing all dependencies for the library feature
class LibraryModule extends StatelessWidget {
  const LibraryModule({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final repository = LibraryRepository(Dio(), snapshot.data!);
        
        return MultiBlocProvider(
          providers: [
            BlocProvider<StudySetsCubit>(
              create: (_) => StudySetsCubit(repository)..loadStudySets(),
            ),
            BlocProvider<FoldersCubit>(
              create: (_) => FoldersCubit(repository)..loadFolders(),
            ),
            BlocProvider<ClassesCubit>(
              create: (_) => ClassesCubit(repository)..loadClasses(),
            ),
          ],
          child: const LibraryScreen(),
        );
      },
    );
  }

  /// Static factory method to create the module
  static Widget create() {
    return const LibraryModule();
  }
}
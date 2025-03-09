// // lib/features/library/library_launcher.dart
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'data/repositories/library_repository.dart';
// import 'logic/cubit/classes_cubit.dart';
// import 'logic/cubit/folders_cubit.dart';
// import 'logic/cubit/study_sets_cubit.dart';
// import 'presentation/screens/library_screen.dart';

// /// A simple function to launch the Library feature
// /// This can be called directly from buttons or menu items
// Future<void> launchLibrary(BuildContext context) async {
//   // Get SharedPreferences
//   final prefs = await SharedPreferences.getInstance();
//   final repository = LibraryRepository(Dio(), prefs);

//   // Create all cubits
//   final studySetsCubit = StudySetsCubit(repository);
//   final foldersCubit = FoldersCubit(repository);
//   final classesCubit = ClassesCubit(repository);
  
//   // Pre-fetch data
//   studySetsCubit.loadStudySets();
//   foldersCubit.loadFolders();
//   classesCubit.loadClasses();

//   // Navigate to library screen with all providers
//   if (!context.mounted) return;
  
//   await Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => MultiBlocProvider(
//         providers: [
//           BlocProvider.value(value: studySetsCubit),
//           BlocProvider.value(value: foldersCubit),
//           BlocProvider.value(value: classesCubit),
//         ],
//         child: const LibraryScreen(),
//       ),
//     ),
//   );
  
//   // Dispose resources when screen is popped
//   studySetsCubit.close();
//   foldersCubit.close();
//   classesCubit.close();
// }
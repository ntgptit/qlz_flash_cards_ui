// lib/features/library/presentation/tabs/classes_tab.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_error_view.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/class_model.dart';
import '../../data/repositories/library_repository.dart';
import '../../logic/cubit/classes_cubit.dart';
import '../../logic/states/classes_state.dart';
import '../widgets/class_item.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  late ClassesCubit _cubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  Future<void> _initCubit() async {
    // Khởi tạo repository và cubit
    final prefs = await SharedPreferences.getInstance();
    final repository = LibraryRepository(Dio(), prefs);
    _cubit = ClassesCubit(repository);
    
    // Đánh dấu là đã khởi tạo và load dữ liệu
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _cubit.loadClasses();
    }
  }

  @override
  void dispose() {
    // Đảm bảo đóng cubit khi widget bị hủy
    if (_isInitialized) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return BlocProvider<ClassesCubit>.value(
      value: _cubit,
      child: BlocBuilder<ClassesCubit, ClassesState>(
        builder: (context, state) {
          if (state.status == ClassesStatus.loading && state.classes.isEmpty) {
            return const QlzLoadingState(
              type: QlzLoadingType.circular,
              message: '로딩 중...', // "Loading..." in Korean
            );
          }

          if (state.status == ClassesStatus.failure) {
            return QlzErrorView(
              message: state.errorMessage ?? 'Failed to load classes',
              onRetry: () => _cubit.refreshClasses(),
            );
          }

          if (state.classes.isEmpty) {
            return QlzEmptyState(
              title: '수업이 없습니다', // "No classes" in Korean
              message: '아직 참여한 수업이 없습니다. 수업을 만들거나 참여해보세요.', 
              // "You haven't joined any classes yet. Create or join a class."
              icon: Icons.people_outlined,
              actionLabel: '수업 만들기', // "Create class" in Korean
              onAction: () => Navigator.pushNamed(context, AppRoutes.createClass),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _cubit.refreshClasses(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                if (state.status == ClassesStatus.loading && state.classes.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // Wrap the list items in a Column to prevent overflow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.classes.map((classModel) => 
                    ClassItem(
                      classModel: classModel,
                      onTap: () => _onClassTap(context, classModel),
                    ),
                  ).toList(),
                ),
                // Add some bottom padding
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onClassTap(BuildContext context, ClassModel classModel) {
    // Navigate to class detail or implement this based on your requirements
    debugPrint('Navigating to class ${classModel.name}');
  }
}
// lib/features/library/presentation/tabs/study_sets_tab.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/module/screens/module_detail_screen.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_error_view.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/header/qlz_section_header.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/study_set_model.dart';
import '../../data/repositories/library_repository.dart';
import '../../logic/cubit/study_sets_cubit.dart';
import '../../logic/states/study_sets_state.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/study_set_item.dart';

class StudySetsTab extends StatefulWidget {
  const StudySetsTab({super.key});

  @override
  State<StudySetsTab> createState() => _StudySetsTabState();
}

class _StudySetsTabState extends State<StudySetsTab> {
  late StudySetsCubit _cubit;
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
    _cubit = StudySetsCubit(repository);
    
    // Đánh dấu là đã khởi tạo và load dữ liệu
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _cubit.loadStudySets();
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

    return BlocProvider<StudySetsCubit>.value(
      value: _cubit,
      child: BlocBuilder<StudySetsCubit, StudySetsState>(
        builder: (context, state) {
          if (state.status == StudySetsStatus.loading && state.studySets.isEmpty) {
            return const QlzLoadingState(
              type: QlzLoadingType.circular,
              message: '로딩 중...', // "Loading..." in Korean
            );
          }

          if (state.status == StudySetsStatus.failure) {
            return QlzErrorView(
              message: state.errorMessage ?? 'Failed to load study sets',
              onRetry: () => _cubit.refreshStudySets(),
            );
          }

          if (state.studySets.isEmpty) {
            return QlzEmptyState.noData(
              title: '학습 세트가 없습니다', // "No study sets" in Korean
              message: '학습 세트를 만들어 단어를 공부해보세요.', // "Create a study set to study vocabulary" in Korean
              actionLabel: '세트 만들기', // "Create set" in Korean
              onAction: () => Navigator.pushNamed(
                context, 
                AppRoutes.createStudyModule
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _cubit.refreshStudySets(),
            child: _buildStudySetsList(context, state),
          );
        },
      ),
    );
  }

  Widget _buildStudySetsList(BuildContext context, StudySetsState state) {
    final filterOptions = ['모두', '내가 만든 세트', '학습함', '다운로드됨'];
    final selectedFilter = state.filter ?? filterOptions.first;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        FilterDropdown(
          options: filterOptions,
          selectedOption: selectedFilter,
          onSelected: (value) {
            _cubit.applyFilter(value);
          },
        ),
        const SizedBox(height: 16),
        QlzTextField.search(
          hintText: '검색어를 입력하세요...',
          onChanged: (value) {
            // Add search functionality later
          },
        ),
        const SizedBox(height: 16),
        const QlzSectionHeader(
          title: '이번 주', // "This week" in Korean
        ),
        const SizedBox(height: 8),
        if (state.status == StudySetsStatus.loading && state.studySets.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        // Wrap the list items in a Column with CrossAxisAlignment.start
        // to prevent overflow
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.studySets.map((studySet) => 
            StudySetItem(
              studySet: studySet,
              onTap: () => _onStudySetTap(context, studySet),
            ),
          ).toList(),
        ),
        // Add some bottom padding
        const SizedBox(height: 16),
      ],
    );
  }

  void _onStudySetTap(BuildContext context, StudySet studySet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleDetailScreen(
          id: studySet.id,
          name: studySet.title,
        ),
      ),
    );
  }
}
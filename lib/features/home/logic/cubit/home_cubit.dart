import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/features/home/logic/states/home_state.dart';

/// Cubit that manages the home screen state
class HomeCubit extends Cubit<HomeState> {
  /// Constructor initializes with default state
  HomeCubit() : super(const HomeState());

  /// Changes the currently selected tab
  /// Only emits new state if the tab is actually changing
  void changeTab(int index) {
    if (state.selectedTabIndex != index) {
      emit(state.copyWith(selectedTabIndex: index));
    }
  }
}

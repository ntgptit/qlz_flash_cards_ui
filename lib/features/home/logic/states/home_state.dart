import 'package:equatable/equatable.dart';

/// State for the home screen
class HomeState extends Equatable {
  /// The index of the currently selected tab
  final int selectedTabIndex;

  /// Default constructor with selectedTabIndex defaulting to 0 (home tab)
  const HomeState({this.selectedTabIndex = 0});

  /// Creates a copy of the current state with specified properties replaced
  HomeState copyWith({int? selectedTabIndex}) {
    return HomeState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [selectedTabIndex];
}

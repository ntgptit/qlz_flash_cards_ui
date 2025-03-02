// lib/features/vocabulary/data/vocabulary.dart

import 'package:flutter/material.dart';

sealed class StudyOption {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final String subtitle;

  const StudyOption({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.subtitle,
  });

  // Method to create a copy with potentially different route
  StudyOption copyWith({String? route}) {
    return _StudyOption(
      icon: icon,
      label: label,
      route: route ?? this.route,
      color: color,
      subtitle: subtitle,
    );
  }
}

// General implementation of StudyOption
final class _StudyOption extends StudyOption {
  const _StudyOption({
    required super.icon,
    required super.label,
    required super.route,
    required super.color,
    required super.subtitle,
  });
}

final class StudyOptions {
  static const flashcards = _FlashcardsOption();
  static const learn = _LearnOption();
  static const test = _TestOption();
  static const match = _MatchOption();
  static const blast = _BlastOption();

  static const List<StudyOption> all = [
    flashcards,
    learn,
    test,
    match,
    blast,
  ];
}

final class _FlashcardsOption extends StudyOption {
  const _FlashcardsOption()
      : super(
          icon: Icons.style_outlined,
          label: 'Thẻ ghi nhớ',
          route: '/study-flashcards', // Default route, will be updated
          color: Colors.blue,
          subtitle: 'Học với thẻ ghi nhớ',
        );
}

final class _LearnOption extends StudyOption {
  const _LearnOption()
      : super(
          icon: Icons.loop,
          label: 'Học',
          route: '/learn', // Default route, will be updated
          color: Colors.purple,
          subtitle: 'Học với trợ lý ảo',
        );
}

final class _TestOption extends StudyOption {
  const _TestOption()
      : super(
          icon: Icons.quiz_outlined,
          label: 'Kiểm tra',
          route: '/test', // Default route, will be updated
          color: Colors.green,
          subtitle: 'Kiểm tra kiến thức',
        );
}

final class _MatchOption extends StudyOption {
  const _MatchOption()
      : super(
          icon: Icons.compare_arrows,
          label: 'Ghép thẻ',
          route: '/match', // Default route, will be updated
          color: Colors.orange,
          subtitle: 'Trò chơi ghép cặp',
        );
}

final class _BlastOption extends StudyOption {
  const _BlastOption()
      : super(
          icon: Icons.rocket_launch,
          label: 'Blast',
          route: '/blast', // Default route, will be updated
          color: Colors.red,
          subtitle: 'Học nhanh với AI',
        );
}

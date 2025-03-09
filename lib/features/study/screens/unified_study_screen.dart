import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/study/widgets/study_progress_indicator.dart';
import 'package:qlz_flash_cards_ui/features/vocabulary/data/flashcard.dart';
import '../strategies/study_strategy.dart';
import '../models/study_session_state.dart';

abstract class BaseStudyScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final StudyStrategy strategy;

  const BaseStudyScreen(
      {super.key, required this.flashcards, required this.strategy});
}

class BaseStudyScreenState<T extends BaseStudyScreen> extends State<T>
    with SingleTickerProviderStateMixin {
  late StudySessionState sessionState;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    sessionState = StudySessionState(widget.flashcards);
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No Flashcards Available'),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    if (sessionState.isSessionComplete) {
      return buildCompletionScreen(context);
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (_, child) => Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              StudyProgressIndicator(
                currentIndex: sessionState.currentIndex + 1,
                total: sessionState.flashcards.length,
                correctAnswers: sessionState.correctAnswers,
              ),
              Expanded(
                child: widget.strategy.buildContent(
                  context,
                  sessionState.flashcards[sessionState.currentIndex],
                  sessionState,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCompletionScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Session Complete')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Session Complete!',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'You got ${sessionState.correctAnswers} out of ${sessionState.flashcards.length} correct',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: sessionState.successRate,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
                _getSuccessRateColor(sessionState.successRate)),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Module'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Study Again'),
                onPressed: _restartSession,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.blue;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }

  void _restartSession() {
    setState(() {
      sessionState = StudySessionState(widget.flashcards);
      _animationController.reset();
      _animationController.forward();
    });
  }
}

class UnifiedStudyScreen extends BaseStudyScreen {
  const UnifiedStudyScreen({
    super.key,
    required super.flashcards,
    required super.strategy,
  });

  @override
  State<UnifiedStudyScreen> createState() => _UnifiedStudyScreenState();
}

class _UnifiedStudyScreenState
    extends BaseStudyScreenState<UnifiedStudyScreen> {}

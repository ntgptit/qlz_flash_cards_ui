import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// Represents a term-definition pair for the matching game.
final class MatchingPair {
  final String term;
  final String definition;
  final String? id;

  const MatchingPair({
    required this.term,
    required this.definition,
    this.id,
  });
}

/// A widget for a vocabulary matching game where users match terms with definitions.
final class QlzMatchingGame extends StatefulWidget {
  final List<MatchingPair> pairs;
  final Function(Duration duration, int correctMatches, int totalPairs)?
      onGameComplete;
  final Color? backgroundColor, selectedColor, matchedColor, mismatchColor;
  final Duration animationDuration;
  final bool shuffleDefinitions, showTimer;
  final int? pairsToShow;

  const QlzMatchingGame({
    super.key,
    required this.pairs,
    this.onGameComplete,
    this.backgroundColor,
    this.selectedColor,
    this.matchedColor,
    this.mismatchColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.shuffleDefinitions = true,
    this.showTimer = true,
    this.pairsToShow,
  });

  @override
  State<QlzMatchingGame> createState() => _QlzMatchingGameState();
}

class _QlzMatchingGameState extends State<QlzMatchingGame> {
  late final List<MatchingPair> _gamePairs;
  late final List<int> _termIndices, _defIndices;
  final Set<int> _matchedTerms = {}, _matchedDefs = {};

  int? _selectedTerm, _selectedDef, _correctMatches = 0;
  DateTime? _startTime, _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.pairs.isEmpty) {
      throw ArgumentError('At least one matching pair is required.');
    }
    _initializeGame();
  }

  void _initializeGame() {
    _correctMatches = 0;
    _startTime = DateTime.now();
    _matchedTerms.clear();
    _matchedDefs.clear();

    final pairsLimit = widget.pairsToShow ?? widget.pairs.length;
    _gamePairs = List.from(widget.pairs.take(pairsLimit));

    _termIndices = List.generate(_gamePairs.length, (i) => i);
    _defIndices = List.generate(_gamePairs.length, (i) => i)..shuffle();
  }

  void _handleSelection(int termIndex, int defIndex) {
    if (_matchedTerms.contains(termIndex) || _matchedDefs.contains(defIndex)) {
      return;
    }

    setState(() {
      _selectedTerm = termIndex;
      _selectedDef = defIndex;

      if (_termIndices[termIndex] == _defIndices[defIndex]) {
        _matchedTerms.add(termIndex);
        _matchedDefs.add(defIndex);
        _correctMatches = _matchedTerms.length;

        if (_correctMatches == _gamePairs.length) {
          _endTime = DateTime.now();
          widget.onGameComplete?.call(_endTime!.difference(_startTime!),
              _correctMatches!, _gamePairs.length);
        }
      } else {
        Future.delayed(widget.animationDuration, () {
          if (mounted) setState(() => _selectedTerm = _selectedDef = null);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        widget.backgroundColor ?? (isDarkMode ? Colors.black : Colors.white);
    final selectedColor = widget.selectedColor ?? AppColors.primary;
    final matchedColor = widget.matchedColor ?? AppColors.success;
    final mismatchColor = widget.mismatchColor ?? AppColors.error;
    final elapsedTime = _endTime?.difference(_startTime!) ??
        DateTime.now().difference(_startTime!);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.showTimer)
            _buildTimer(elapsedTime, _correctMatches!, _gamePairs.length),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: _buildColumn(_termIndices, true, selectedColor,
                        matchedColor, mismatchColor)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildColumn(_defIndices, false, selectedColor,
                        matchedColor, mismatchColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(Duration elapsedTime, int correctMatches, int totalPairs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, size: 20),
              const SizedBox(width: 8),
              Text(_formatDuration(elapsedTime),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          Text('$correctMatches/$totalPairs matched',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildColumn(List<int> indices, bool isTermColumn, Color selectedColor,
      Color matchedColor, Color mismatchColor) {
    return Column(
      children: indices.map((index) {
        final pair = _gamePairs[index];
        final text = isTermColumn ? pair.term : pair.definition;
        final isSelected =
            isTermColumn ? _selectedTerm == index : _selectedDef == index;
        final isMatched = isTermColumn
            ? _matchedTerms.contains(index)
            : _matchedDefs.contains(index);

        return _buildGameCard(
            text, isSelected, isMatched, selectedColor, matchedColor, () {
          if (isTermColumn) {
            _selectedTerm = index;
          } else {
            _selectedDef = index;
          }
          if (_selectedTerm != null && _selectedDef != null) {
            _handleSelection(_selectedTerm!, _selectedDef!);
          }
        });
      }).toList(),
    );
  }

  Widget _buildGameCard(String text, bool isSelected, bool isMatched,
      Color selectedColor, Color matchedColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: isMatched
            ? matchedColor
            : (isSelected ? selectedColor : Colors.white),
        child: ListTile(
          title: Text(text, textAlign: TextAlign.center),
          onTap: isMatched ? null : onTap,
        ),
      ),
    );
  }
}

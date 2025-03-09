import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/features/flashcard/data/models/flashcard_model.dart';

class OptionList extends StatefulWidget {
  final List<Flashcard> flashcards;
  final Flashcard flashcard;
  final VoidCallback onCorrectAnswer;
  final VoidCallback onWrongAnswer;
  final VoidCallback onContinue;

  const OptionList({
    super.key,
    required this.flashcards,
    required this.flashcard,
    required this.onCorrectAnswer,
    required this.onWrongAnswer,
    required this.onContinue,
  });

  @override
  State<OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<OptionList> {
  int? _selectedIndex;
  bool _isAnswered = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = _generateOptions();
  }

  @override
  void didUpdateWidget(OptionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcard != widget.flashcard) {
      setState(() {
        _selectedIndex = null;
        _isAnswered = false;
        _options = _generateOptions();
      });
    }
  }

  List<String> _generateOptions() {
    final distractors = widget.flashcards
        .where((f) => f.term != widget.flashcard.term)
        .map((f) => f.term)
        .toList()
      ..shuffle();
    final options = distractors.take(3).toList()
      ..add(widget.flashcard.term)
      ..shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Choose the correct term',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(_options[index]),
                selected: _selectedIndex == index,
                onTap: _isAnswered ? null : () => _onOptionSelected(index),
              ),
            ),
          ),
          if (_isAnswered)
            ElevatedButton(
              onPressed: widget.onContinue,
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
    });
    if (_options[index] == widget.flashcard.term) {
      widget.onCorrectAnswer();
    } else {
      widget.onWrongAnswer();
    }
  }
}

import 'package:flutter/material.dart';

class WritingArea extends StatelessWidget {
  final TextEditingController answerController;
  final FocusNode focusNode;
  final bool isAnswerChecked;
  final bool isAnswerCorrect;
  final String? correctAnswer;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final VoidCallback onDontKnow;

  const WritingArea({
    super.key,
    required this.answerController,
    required this.focusNode,
    required this.isAnswerChecked,
    required this.isAnswerCorrect,
    this.correctAnswer,
    required this.onCheck,
    required this.onNext,
    required this.onDontKnow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isAnswerChecked) ...[
            Card(
              color: isAnswerCorrect ? Colors.green[100] : Colors.red[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(isAnswerCorrect ? 'Correct!' : 'Incorrect!'),
                    if (!isAnswerCorrect && correctAnswer != null)
                      Text('Correct answer: $correctAnswer'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: onNext, child: const Text('Next')),
          ] else ...[
            TextField(
              controller: answerController,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'Enter your answer'),
              onSubmitted: (_) => onCheck(),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: onDontKnow, child: const Text('Don’t Know')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                      onPressed: onCheck, child: const Text('Check')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

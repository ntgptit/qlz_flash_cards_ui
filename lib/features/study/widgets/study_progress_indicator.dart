import 'package:flutter/material.dart';

class StudyProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int correctAnswers;

  const StudyProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? currentIndex / total : 0.0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildCounter(currentIndex, true),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(width: 12),
              _buildCounter(total, false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text('$correctAnswers correct'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(int value, bool isCurrent) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: isCurrent ? Colors.blue : Colors.grey, width: 2),
      ),
      child: Center(child: Text('$value')),
    );
  }
}

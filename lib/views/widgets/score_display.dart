import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int total;
  final bool showPercentage;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.total,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total) * 100 : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$score/$total',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '(${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 16,
                color: percentage >= 70
                    ? Colors.green
                    : percentage >= 50
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
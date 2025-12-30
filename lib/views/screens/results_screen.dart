import 'package:flutter/material.dart';

import '../../constants/quiz_config.dart';
import '../../models/game_session.dart';

class ResultsScreen extends StatelessWidget {
  final GameSession gameSession;
  final VoidCallback onRetryWrongAnswers;
  final VoidCallback onNewQuiz;

  const ResultsScreen({
    super.key,
    required this.gameSession,
    required this.onRetryWrongAnswers,
    required this.onNewQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = gameSession.percentage;
    final feedback = '${gameSession.score} sur ${gameSession.questions.length} '
        'réponses correctes (${percentage.toStringAsFixed(1)}%)';

    return Scaffold(
      backgroundColor: QuizConfig.bgColor,
      appBar: AppBar(
        title: const Text('Résultats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'SCORE FINAL',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${gameSession.score}/${gameSession.questions.length}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        color: percentage >= 70
                            ? Colors.green
                            : percentage >= 50
                            ? Colors.orange
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedback,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (gameSession.wrongAnswers.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Réponses incorrectes: ${gameSession.wrongAnswers.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // if (gameSession.wrongAnswers.isNotEmpty)
            //   Column(
            //     children: [
            //       Text(
            //         QuizConfig.feedback,
            //         style: const TextStyle(
            //           fontSize: 14,
            //           color: Colors.grey,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //       const SizedBox(height: 20),
            //       ElevatedButton(
            //         onPressed: onRetryWrongAnswers,
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.orange,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 32,
            //             vertical: 16,
            //           ),
            //         ),
            //         child: Text(QuizConfig.trySecondRound),
            //       ),
            //       const SizedBox(height: 20),
            //     ],
            //   ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onNewQuiz,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Nouveau Quiz'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuizConfig.buttonBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Accueil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
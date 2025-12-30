import 'package:flutter/material.dart';

import '../../constants/quiz_config.dart';
import '../../models/quiz_definition.dart';

class SelectQuizScreen extends StatefulWidget {
  final List<QuizDefinition> quizzes;
  final Function(List<String>) onQuizSelected;

  const SelectQuizScreen({
    super.key,
    required this.quizzes,
    required this.onQuizSelected,
  });

  @override
  State<SelectQuizScreen> createState() => _SelectQuizScreenState();
}

class _SelectQuizScreenState extends State<SelectQuizScreen> {
  final List<String> _selectedQuizzes = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        QuizConfig.selectQuiz,
        style: const TextStyle(fontSize: QuizConfig.textSize),
      ),
      backgroundColor: QuizConfig.bgColor,
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              width: 400,
              child: ListView.builder(
                itemCount: widget.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = widget.quizzes[index];
                  return CheckboxListTile(
                    title: Text(quiz.name),
                    subtitle: Text(quiz.category),
                    value: _selectedQuizzes.contains(quiz.name),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedQuizzes.add(quiz.name);
                        } else {
                          _selectedQuizzes.remove(quiz.name);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _selectedQuizzes.isEmpty
              ? null
              : () {
            widget.onQuizSelected(_selectedQuizzes);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: QuizConfig.buttonBg,
          ),
          child: Text(QuizConfig.startQuiz),
        ),
      ],
    );
  }
}
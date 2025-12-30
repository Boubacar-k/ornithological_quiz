import 'package:flutter/material.dart';

import '../../constants/quiz_config.dart';

class CategoryScreen extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        QuizConfig.chooseCategory,
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
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(categories[index]),
                      onTap: () => onCategorySelected(categories[index]),
                    ),
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
      ],
    );
  }
}
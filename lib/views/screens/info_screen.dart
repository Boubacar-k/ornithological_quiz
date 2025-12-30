import 'package:flutter/material.dart';

import '../../constants/quiz_config.dart';
import '../../models/bird_item.dart';

class InfoScreen extends StatelessWidget {
  final BirdItem bird;
  final bool showBname;
  final bool showLatin;

  const InfoScreen({
    super.key,
    required this.bird,
    required this.showBname,
    required this.showLatin,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: QuizConfig.bgColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Informations'),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: QuizConfig.imageHeight / 2 * 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBname && bird.bname.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    bird.bname,
                    style: const TextStyle(
                      fontSize: QuizConfig.textSize + 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (bird.fname.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    bird.fname,
                    style: const TextStyle(
                      fontSize: QuizConfig.textSize + 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (showLatin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    bird.scientificName,
                    style: const TextStyle(
                      fontSize: QuizConfig.textSize,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              if (bird.desc.isNotEmpty)
                Text(
                  bird.desc,
                  style: const TextStyle(fontSize: QuizConfig.textSize),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
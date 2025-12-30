import 'package:flutter/material.dart';

import '../../constants/quiz_config.dart';
import '../../data/bird_data.dart';

class BirdInfoScreen extends StatelessWidget {
  final BirdData bird;
  final bool showBname;
  final bool showLatin;

  const BirdInfoScreen({
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
          Expanded(
            child: Text(
              bird.fname.isNotEmpty ? bird.fname : bird.scientificName,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bird.bname.isNotEmpty && showBname)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    bird.bname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),

              if (bird.fname.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    bird.fname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (showLatin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    bird.scientificName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),

              if (bird.desc.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bird.desc,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),

              if (bird.displayImages.isNotEmpty && bird.displayImages.length > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Autres images disponibles:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bird.displayImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                bird.displayImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
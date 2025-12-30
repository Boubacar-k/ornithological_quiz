import 'package:flutter/material.dart';

import '../../data/bird_data.dart';

class BirdInfoCard extends StatelessWidget {
  final BirdData bird;
  final bool showBname;
  final bool showLatin;

  const BirdInfoCard({
    super.key,
    required this.bird,
    this.showBname = true,
    this.showLatin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bird.bname.isNotEmpty && showBname)
              Text(
                bird.bname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

            if (bird.fname.isNotEmpty)
              Text(
                bird.fname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

            if (showLatin)
              Text(
                bird.scientificName,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
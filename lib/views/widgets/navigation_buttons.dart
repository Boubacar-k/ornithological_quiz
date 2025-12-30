import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int currentIndex;
  final int totalImages;

  const NavigationButtons({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bouton précédent
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Opacity(
            opacity: currentIndex > 0 ? 1.0 : 0.5,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: currentIndex > 0 ? onPrevious : null,
              ),
            ),
          ),
        ),

        // Indicateur de position
        if (totalImages > 1)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1}/$totalImages',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox(width: 40),

        // Bouton suivant
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Opacity(
            opacity: currentIndex < totalImages - 1 ? 1.0 : 0.5,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: currentIndex < totalImages - 1 ? onNext : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
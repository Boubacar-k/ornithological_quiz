import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class QuizImage extends StatelessWidget {
  final String imagePath;
  final double height;

  const QuizImage({
    super.key,
    required this.imagePath,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        height: height,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      );
    } else if (File(imagePath).existsSync()) {
      imageWidget = Image.file(
        File(imagePath),
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      // Essayer comme asset
      imageWidget = Image.asset(
        imagePath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Image non disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );
  }
}
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageResizer {
  static Future<File> resizeImage({
    required File originalFile,
    required double targetHeight,
    required String outputPath,
  }) async {
    try {
      // Lire l'image originale
      final bytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Calculer les nouvelles dimensions
      final originalHeight = originalImage.height.toDouble();
      final originalWidth = originalImage.width.toDouble();
      final newWidth = (targetHeight * originalWidth / originalHeight).toInt();

      // Redimensionner
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: targetHeight.toInt(),
        interpolation: img.Interpolation.cubic,
      );

      // Sauvegarder
      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);

      // Garder le même format
      final extension = path.extension(outputPath).toLowerCase();
      List<int> outputBytes;

      if (extension == '.png') {
        outputBytes = img.encodePng(resizedImage);
      } else {
        outputBytes = img.encodeJpg(resizedImage, quality: 85);
      }

      await outputFile.writeAsBytes(outputBytes);

      return outputFile;
    } catch (e) {
      throw Exception('Erreur lors du redimensionnement: $e');
    }
  }

  static Future<bool> needsResizing({
    required File originalFile,
    required File resizedFile,
    required double targetHeight,
  }) async {
    if (!await resizedFile.exists()) {
      return true;
    }

    final originalModified = await originalFile.lastModified();
    final resizedModified = await resizedFile.lastModified();

    if (originalModified.isAfter(resizedModified)) {
      return true;
    }

    // Vérifier la hauteur
    try {
      final bytes = await resizedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null && image.height != targetHeight.toInt()) {
        return true;
      }
    } catch (e) {
      return true;
    }

    return false;
  }
}
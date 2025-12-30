import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'txt_parser.dart';

class BirdFileManager {
  static const List<String> imageExtensions = ['.jpg', '.jpeg', '.png'];
  static const String txtExtension = '.txt';
  static const String resizedFolder = 'resized';

  // Lire un dossier d'oiseaux
  static Future<Map<String, Map<String, dynamic>>> readBirdDirectory(
      String directoryPath, {
        required double targetHeight,
        required String resizeMode,
        bool useResized = true,
      }) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception("Le dossier n'existe pas: $directoryPath");
    }

    final Map<String, Map<String, dynamic>> birds = {};
    final resizedDir = Directory(path.join(directoryPath, resizedFolder));

    // Créer le dossier resized si nécessaire
    if (!await resizedDir.exists() && useResized && resizeMode != 'none') {
      await resizedDir.create(recursive: true);
    }

    // Regrouper les fichiers par clé
    final entries = await directory.list().toList();
    final Map<String, List<FileSystemEntity>> groupedFiles = {};

    for (final entity in entries) {
      if (entity is File) {
        final fileName = path.basename(entity.path);
        final keyMatch = RegExp(r'^([\w-]+)').firstMatch(fileName);
        if (keyMatch == null) continue;

        final key = keyMatch.group(1)!;
        if (!groupedFiles.containsKey(key)) {
          groupedFiles[key] = [];
        }
        groupedFiles[key]!.add(entity);
      }
    }

    // Traiter chaque groupe
    for (final entry in groupedFiles.entries) {
      final key = entry.key;
      final entities = entry.value;

      BirdInfo? birdInfo;
      final List<String> originalImages = [];
      final List<String> resizedImages = [];

      for (final entity in entities) {
        final file = entity as File;
        final fileName = path.basename(file.path).toLowerCase();

        if (fileName.endsWith(txtExtension)) {
          final content = await file.readAsString();
          birdInfo = BirdInfo.fromTxtContent(content);
        } else if (imageExtensions.any((ext) => fileName.endsWith(ext))) {
          originalImages.add(file.path);

          if (useResized && resizeMode != 'none') {
            final resizedPath = await _getOrCreateResizedImage(
              file.path,
              resizedDir.path,
              targetHeight,
              resizeMode,
            );
            if (resizedPath != null) {
              resizedImages.add(resizedPath);
            }
          }
        }
      }

      if (birdInfo != null) {
        birds[key] = {
          'key': key,
          'bname': birdInfo.bname,
          'fname': birdInfo.fname,
          'desc': birdInfo.desc,
          'originalImages': originalImages,
          'resizedImages': useResized && resizedImages.isNotEmpty
              ? resizedImages
              : originalImages,
          'scientificName': key.replaceAll('-', ' '),
        };
      }
    }

    return birds;
  }

  static Future<String?> _getOrCreateResizedImage(
      String originalPath,
      String resizedDirPath,
      double targetHeight,
      String resizeMode,
      ) async {
    final originalFile = File(originalPath);
    final fileName = path.basename(originalPath);
    final resizedPath = path.join(resizedDirPath, fileName);
    final resizedFile = File(resizedPath);

    bool shouldResize = false;

    if (resizeMode == 'force') {
      shouldResize = true;
    } else if (resizeMode == 'new') {
      if (!await resizedFile.exists()) {
        shouldResize = true;
      } else {
        final originalModified = await originalFile.lastModified();
        final resizedModified = await resizedFile.lastModified();
        if (originalModified.isAfter(resizedModified)) {
          shouldResize = true;
        }
      }
    }

    if (shouldResize) {
      try {
        final bytes = await originalFile.readAsBytes();
        final originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          final originalHeight = originalImage.height.toDouble();
          final originalWidth = originalImage.width.toDouble();
          final newWidth = (targetHeight * originalWidth / originalHeight).toInt();

          final resizedImage = img.copyResize(
            originalImage,
            width: newWidth,
            height: targetHeight.toInt(),
          );

          final resizedBytes = img.encodeJpg(resizedImage);
          await resizedFile.writeAsBytes(resizedBytes);
        }
      } catch (e) {
        print("Erreur redimensionnement: $e");
        return originalPath;
      }
    }

    return resizedFile.existsSync() ? resizedPath : originalPath;
  }

  // Lire un fichier de quiz
  static Future<Map<String, dynamic>> readQuizFile(String filePath) async {
    final file = File(filePath);
    final lines = await file.readAsLines();

    if (lines.isEmpty) {
      throw Exception("Fichier de quiz vide");
    }

    final firstLine = lines[0].trim();
    final parts = firstLine.split(':');

    String category;
    String name;

    if (parts.length > 1) {
      category = parts[0].trim();
      name = parts.sublist(1).join(':').trim();
    } else {
      category = 'NOCAT';
      name = firstLine;
    }

    final List<String> directories = [];
    for (int i = 1; i < lines.length; i++) {
      final dir = lines[i].trim();
      if (dir.isNotEmpty) {
        directories.add(dir);
      }
    }

    return {
      'filePath': filePath,
      'category': category,
      'name': name,
      'directories': directories,
    };
  }
}
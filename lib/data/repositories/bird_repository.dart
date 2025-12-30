import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/quiz_definition.dart';
import '../../utils/bird_file_manager.dart';
import '../bird_data.dart';

class BirdRepository {
  static final BirdRepository _instance = BirdRepository._internal();
  factory BirdRepository() => _instance;
  BirdRepository._internal();

  final Map<String, List<BirdData>> _birdCache = {};
  final Map<String, QuizDefinition> _quizCache = {};
  List<QuizDefinition> _quizzes = [];

  Future<List<QuizDefinition>> loadQuizzes() async {
    if (_quizzes.isNotEmpty) return _quizzes;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final quizAssets = manifest
          .listAssets()
          .where((p) => p.startsWith('assets/quizzes/'))
          .where((p) => !p.endsWith('/')) // Exclure les dossiers
          .where((p) => p.split('/').length == 3) // Seulement les fichiers directs (assets/quizzes/filename)
          .toList();

      print("🎯 Quiz assets trouvés: ${quizAssets.length}");

      for (final assetPath in quizAssets) {
        try {
          final content = await rootBundle.loadString(assetPath);
          final lines = content.split('\n');

          if (lines.isEmpty) continue;

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

          final directories = <String>[];
          for (int i = 1; i < lines.length; i++) {
            final dir = lines[i].trim();
            if (dir.isNotEmpty) {
              directories.add(dir);
            }
          }

          final quiz = QuizDefinition(
            filePath: assetPath,
            category: category,
            name: name,
            directories: directories,
          );

          _quizCache[quiz.name] = quiz;
          _quizzes.add(quiz);
        } catch (e) {
          print("Erreur chargement quiz $assetPath: $e");
        }
      }

      // Si pas de quiz chargés, créer un par défaut
      if (_quizzes.isEmpty) {
        final defaultQuiz = QuizDefinition(
          filePath: 'assets/quizzes/default',
          category: 'NOCAT',
          name: 'Oiseaux du Mali',
          directories: ['birds'], // SANS 'assets/' car on l'ajoutera dans loadBirdsFromDirectory
        );
        _quizzes.add(defaultQuiz);
        _quizCache[defaultQuiz.name] = defaultQuiz;
      }
    } catch (e) {
      print("Erreur générale chargement quizzes: $e");
    }

    return _quizzes;
  }

  Future<List<BirdData>> loadBirdsFromDirectory(
      String directory, {
        double targetHeight = 700,
        String resizeMode = 'new',
      }) async {
    if (_birdCache.containsKey(directory)) {
      print("📦 Cache hit pour $directory");
      return _birdCache[directory]!;
    }

    try {
      final tempDir = await getTemporaryDirectory();

      // Nettoyer le nom du dossier (enlever 'assets/' si présent)
      final cleanDir = directory.replaceFirst('assets/', '');
      final tempBirdDir = Directory('${tempDir.path}/$cleanDir');

      print("📁 Vérification du cache local: ${tempBirdDir.path}");

      // Vérifier si les fichiers existent déjà dans le cache local
      bool needsCopy = false;
      if (!await tempBirdDir.exists()) {
        needsCopy = true;
        await tempBirdDir.create(recursive: true);
      } else {
        final files = await tempBirdDir.list().toList();
        if (files.isEmpty) {
          needsCopy = true;
        } else {
          print("✅ Fichiers déjà en cache (${files.length} fichiers)");
        }
      }

      // Copier seulement si nécessaire
      if (needsCopy) {
        print("📥 Copie des assets...");
        await _copyAssetsToTemp('assets/$cleanDir', tempBirdDir.path);
      }

      // Vérifier que des fichiers ont été copiés
      final files = await tempBirdDir.list().toList();
      print("📄 Fichiers disponibles: ${files.length}");

      if (files.isEmpty) {
        throw Exception("Aucun fichier trouvé dans assets/$cleanDir");
      }

      // Charger depuis le dossier temporaire (SANS redimensionnement pour être plus rapide)
      print("🔄 Chargement des oiseaux...");
      final birdsMap = await BirdFileManager.readBirdDirectory(
        tempBirdDir.path,
        targetHeight: targetHeight,
        resizeMode: 'none', // Désactiver le redimensionnement pendant le chargement
        useResized: false,
      );

      final birds = birdsMap.values
          .map((data) => BirdData.fromJson(data))
          .where((bird) => bird.displayImages.isNotEmpty)
          .toList();

      print("🐦 Oiseaux chargés: ${birds.length}");

      _birdCache[directory] = birds;
      return birds;
    } catch (e, stackTrace) {
      print("❌ Erreur chargement oiseaux $directory: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  Future<void> _copyAssetsToTemp(String assetDir, String tempPath) async {
    try {
      print("🔍 Recherche assets dans: $assetDir");

      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest
          .listAssets()
          .where((path) => path.startsWith(assetDir))
          .where((path) => !path.endsWith('/')) // Ignorer les dossiers
          .toList();

      print("📋 Assets à copier: ${assets.length}");

      if (assets.isEmpty) {
        print("⚠️ Aucun asset trouvé dans $assetDir");
        return;
      }

      // Copier en parallèle pour plus de rapidité
      final futures = <Future>[];

      for (final asset in assets) {
        futures.add(_copySingleAsset(asset, tempPath));
      }

      // Attendre que toutes les copies soient terminées
      await Future.wait(futures);

      print("✅ Copie terminée");
    } catch (e, stackTrace) {
      print("❌ Erreur manifest: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> _copySingleAsset(String asset, String tempPath) async {
    try {
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();

      // Extraire juste le nom du fichier
      final fileName = asset.split('/').last;
      final file = File('$tempPath/$fileName');

      // Ne copier que si le fichier n'existe pas ou est différent
      if (!await file.exists()) {
        await file.writeAsBytes(bytes);
        print("✅ Copié: $fileName (${bytes.length} bytes)");
      }
    } catch (e) {
      print("❌ Erreur copie $asset: $e");
    }
  }

  Future<List<BirdData>> getAllBirdsForQuiz(QuizDefinition quiz) async {
    final allBirds = <BirdData>[];

    for (final directory in quiz.directories) {
      final birds = await loadBirdsFromDirectory(directory);
      allBirds.addAll(birds);
    }

    return allBirds;
  }

  Future<List<BirdData>> getRandomBirdsForQuiz(
      QuizDefinition quiz, {
        int count = 20,
      }) async {
    final allBirds = await getAllBirdsForQuiz(quiz);

    if (allBirds.length < 3) {
      throw Exception("Pas assez d'oiseaux (${allBirds.length}). Minimum 3 requis.");
    }

    allBirds.shuffle();
    return allBirds.take(count).toList();
  }

  QuizDefinition? getQuizByName(String name) {
    return _quizCache[name];
  }

  List<String> getCategories() {
    return _quizzes.map((q) => q.category).toSet().toList();
  }

  List<QuizDefinition> getQuizzesByCategory(String category) {
    return _quizzes.where((q) => q.category == category).toList();
  }

  void clearCache() {
    _birdCache.clear();
    _quizCache.clear();
    _quizzes.clear();
  }
}
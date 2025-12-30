import 'package:flutter/material.dart';
import 'package:quiz/views/screens/select_quiz_screen.dart';
import 'package:quiz/views/widgets/loading.dart';
import '../../constants/quiz_config.dart';
import '../../data/repositories/bird_repository.dart';
import '../../models/quiz_definition.dart';
import 'category_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  final BirdRepository birdRepository;
  final bool showLatin;
  final bool showBname;
  final String resizeMode;
  final double imageHeight;
  final Function(bool, bool, String, double) onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.birdRepository,
    required this.showLatin,
    required this.showBname,
    required this.resizeMode,
    required this.imageHeight,
    required this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<QuizDefinition> _quizzes;
  bool _isLoading = true;
  String? _randomImagePath;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _quizzes = await widget.birdRepository.loadQuizzes();
    setState(() {
      _isLoading = false;
    });
  }

  void _startQuiz() {
    final categories = widget.birdRepository.getCategories();

    if (categories.length == 1 && _quizzes.length == 1) {
      _startSpecificQuiz(_quizzes.first);
    } else {
      _showCategorySelection();
    }
  }

  void _showCategorySelection() {
    final categories = widget.birdRepository.getCategories();

    showDialog(
      context: context,
      builder: (context) => CategoryScreen(
        categories: categories,
        onCategorySelected: (category) {
          Navigator.of(context).pop();
          _showQuizSelection(category);
        },
      ),
    );
  }

  void _showQuizSelection(String category) {
    final quizzes = widget.birdRepository.getQuizzesByCategory(category);

    if (quizzes.length == 1) {
      _startSpecificQuiz(quizzes.first);
    } else {
      showDialog(
        context: context,
        builder: (context) => SelectQuizScreen(
          quizzes: quizzes,
          onQuizSelected: (quizNames) {
            Navigator.of(context).pop();
            if (quizNames.isNotEmpty) {
              final quiz = widget.birdRepository.getQuizByName(quizNames.first);
              if (quiz != null) {
                _startSpecificQuiz(quiz);
              }
            }
          },
        ),
      );
    }
  }

  void _startSpecificQuiz(QuizDefinition quiz) async {
    try {
      final birds = await LoadingDialog.show(
        context,
        message: 'Chargement des oiseaux...\nVeuillez patienter',
        task: () => widget.birdRepository.getRandomBirdsForQuiz(
          quiz,
          count: 20,
        ),
      );

      if (!mounted) return;

      if (birds == null || birds.length < 3) {
        _showError('Pas assez d\'oiseaux (${birds?.length ?? 0}) pour ce quiz.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            quiz: quiz,
            birds: birds,
            showLatin: widget.showLatin,
            showBname: widget.showBname,
            imageHeight: widget.imageHeight,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        bool showLatin = widget.showLatin;
        bool showBname = widget.showBname;
        String resizeMode = widget.resizeMode;
        double imageHeight = widget.imageHeight;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Paramètres'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Afficher nom bambara'),
                      value: showBname,
                      onChanged: (value) => setState(() => showBname = value),
                    ),
                    SwitchListTile(
                      title: const Text('Afficher nom scientifique'),
                      value: showLatin,
                      onChanged: (value) => setState(() => showLatin = value),
                    ),
                    // const Divider(),
                    // const Text('Redimensionnement images:'),
                    // DropdownButtonFormField<String>(
                    //   value: resizeMode,
                    //   items: const [
                    //     DropdownMenuItem(value: 'none', child: Text('Aucun')),
                    //     DropdownMenuItem(value: 'new', child: Text('Seulement nouvelles')),
                    //     DropdownMenuItem(value: 'force', child: Text('Toujours')),
                    //   ],
                    //   onChanged: (value) => setState(() => resizeMode = value!),
                    // ),
                    // const SizedBox(height: 16),
                    // Text('Hauteur images: ${imageHeight.toInt()}px'),
                    // Slider(
                    //   value: imageHeight,
                    //   min: 300,
                    //   max: 1000,
                    //   divisions: 14,
                    //   onChanged: (value) => setState(() => imageHeight = value),
                    // ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSettingsChanged(showLatin, showBname, resizeMode, imageHeight);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: QuizConfig.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Chargement des quiz...',
                style: TextStyle(fontSize: QuizConfig.textSize),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: QuizConfig.bgColor,
      appBar: AppBar(
        title: const Text('Quiz des Oiseaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flag,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quiz Ornithologique',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Testez vos connaissances\nsur les oiseaux',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow,color: Colors.blue,),
                        const SizedBox(width: 10),
                        Text(
                          _quizzes.length == 1
                              ? QuizConfig.startQuiz
                              : QuizConfig.chooseQuiz,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_quizzes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const Text(
                          'Quiz disponibles:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._quizzes.map((quiz) {
                          return Card(
                            child: ListTile(
                              title: Text(quiz.name),
                              subtitle: Text(quiz.category),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () => _startSpecificQuiz(quiz),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
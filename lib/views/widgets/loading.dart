import 'package:flutter/material.dart';

// Widget de chargement simple
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? progress; // Optionnel: pour un indicateur de progression

  const LoadingWidget({
    Key? key,
    this.message,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (progress != null)
            CircularProgressIndicator(value: progress,color: Colors.blue,)
          else
            const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 24),
          if (message != null)
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// Dialog de chargement pour afficher pendant le chargement des oiseaux
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  static Future<T?> show<T>(
      BuildContext context, {
        required String message,
        required Future<T> Function() task,
      }) async {
    // Afficher le dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );

    try {
      // Exécuter la tâche
      final result = await task();

      // Fermer le dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      // Fermer le dialog en cas d'erreur
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de chargement avec animation d'oiseau (plus fun!)
class BirdLoadingWidget extends StatefulWidget {
  final String? message;
  final Stream<String>? progressStream; // Pour afficher la progression

  const BirdLoadingWidget({
    Key? key,
    this.message,
    this.progressStream,
  }) : super(key: key);

  // Méthode statique pour afficher un dialog de chargement
  static Future<T?> show<T>(
      BuildContext context, {
        required String message,
        required Future<T> Function() task,
      }) async {
    // Afficher le dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BirdLoadingWidget(message: message),
        ),
      ),
    );

    try {
      // Exécuter la tâche
      final result = await task();

      // Fermer le dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      // Fermer le dialog en cas d'erreur
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  @override
  State<BirdLoadingWidget> createState() => _BirdLoadingWidgetState();
}

class _BirdLoadingWidgetState extends State<BirdLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (0.5 - (_controller.value - 0.5).abs())),
                child: child,
              );
            },
            child: const Icon(
              Icons.flutter_dash,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 16),
          if (widget.message != null)
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// Exemple d'utilisation avec FutureBuilder
class QuizLoadingExample extends StatelessWidget {
  final Future<List<dynamic>> loadQuizzesFuture;

  const QuizLoadingExample({
    Key? key,
    required this.loadQuizzesFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: loadQuizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BirdLoadingWidget(
            message: 'Chargement des quiz...',
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Aucun quiz disponible'),
          );
        }

        // Afficher vos quiz ici
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Quiz ${index + 1}'),
            );
          },
        );
      },
    );
  }
}

// Pour un écran complet avec loading
class QuizListScreen extends StatefulWidget {
  const QuizListScreen({Key? key}) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late Future<List<dynamic>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    // Remplacez par votre appel réel
    _quizzesFuture = _loadQuizzes();
  }

  Future<List<dynamic>> _loadQuizzes() async {
    // Simuler un chargement
    await Future.delayed(const Duration(seconds: 2));
    return ['Quiz 1', 'Quiz 2', 'Quiz 3'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const BirdLoadingWidget(
              message: 'Chargement des quiz en cours...',
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _quizzesFuture = _loadQuizzes();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun quiz disponible',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          // Afficher la liste des quiz
          final quizzes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.quiz),
                  ),
                  title: Text('${quizzes[index]}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigation vers le quiz
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
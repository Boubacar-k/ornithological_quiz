import '../data/bird_data.dart';

class GameSession {
  final List<BirdData> questions;
  final List<BirdData> allBirds;

  int currentQuestionIndex = 0;
  int score = 0;
  List<int> userAnswers = [];
  List<bool> isCorrect = [];
  List<BirdData> wrongAnswers = [];
  DateTime? startTime;
  DateTime? endTime;

  // Stocker les options actuelles pour éviter le re-shuffle
  List<BirdData>? _currentOptions;

  GameSession({
    required this.questions,
    required this.allBirds,
  }) {
    userAnswers = List.filled(questions.length, -1);
    isCorrect = List.filled(questions.length, false);
    startTime = DateTime.now();
  }

  BirdData get currentQuestion => questions[currentQuestionIndex];

  bool get hasMoreQuestions => currentQuestionIndex < questions.length;

  // Générer ET stocker les options pour la question actuelle
  List<BirdData> getAnswerOptions() {
    // Si on a déjà généré les options pour cette question, les retourner
    if (_currentOptions != null) {
      return _currentOptions!;
    }

    final currentBird = currentQuestion;
    final otherBirds = List<BirdData>.from(allBirds)
      ..removeWhere((bird) => bird.fname == currentBird.fname)
      ..shuffle()
      ..take(2);

    final options = [currentBird, ...otherBirds.take(2)];
    options.shuffle();

    // Stocker les options générées
    _currentOptions = options;

    return options;
  }

  void answerQuestion(int answerIndex) {
    if (currentQuestionIndex >= questions.length) return;
    if (_currentOptions == null) return; // Sécurité

    userAnswers[currentQuestionIndex] = answerIndex;

    // Utiliser les options stockées au lieu de les régénérer
    final selectedBird = _currentOptions![answerIndex];
    final isAnswerCorrect = selectedBird.fname == currentQuestion.fname;

    print('Question: ${currentQuestion.fname}');
    print('Réponse: ${selectedBird.fname}');
    print('Correct: $isAnswerCorrect');

    isCorrect[currentQuestionIndex] = isAnswerCorrect;

    if (isAnswerCorrect) {
      score++;
    } else {
      if (!wrongAnswers.contains(currentQuestion)) {
        wrongAnswers.add(currentQuestion);
      }
    }
  }

  void nextQuestion() {
    currentQuestionIndex++;
    // Réinitialiser les options pour la prochaine question
    _currentOptions = null;
  }

  void endSession() {
    endTime = DateTime.now();
  }

  double get percentage =>
      questions.isEmpty ? 0 : (score / questions.length) * 100;

  Duration get duration {
    if (startTime == null || endTime == null) {
      return Duration.zero;
    }
    return endTime!.difference(startTime!);
  }
}
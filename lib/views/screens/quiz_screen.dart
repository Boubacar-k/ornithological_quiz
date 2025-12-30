import 'package:flutter/material.dart';
import '../../constants/quiz_config.dart';
import '../../data/bird_data.dart';
import '../../models/game_session.dart';
import '../../models/quiz_definition.dart';
import '../widgets/quiz_image.dart';
import '../widgets/answer_button.dart';
import '../widgets/navigation_buttons.dart';
import 'bird_info_screen.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizDefinition quiz;
  final List<BirdData> birds;
  final bool showLatin;
  final bool showBname;
  final double imageHeight;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.birds,
    required this.showLatin,
    required this.showBname,
    required this.imageHeight,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late GameSession _gameSession;
  late List<BirdData> _currentOptions;
  int? _selectedAnswer;
  int _currentImageIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _gameSession = GameSession(
      questions: widget.birds,
      allBirds: widget.birds,
    );
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    if (!_gameSession.hasMoreQuestions) {
      _gameSession.endSession();
      _showResults();
      return;
    }

    setState(() {
      _currentOptions = _gameSession.getAnswerOptions();
      _selectedAnswer = null;
      _showAnswer = false;
      _currentImageIndex = 0;
    });
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    setState(() {
      // _selectedAnswer = index;
      _showAnswer = true;
    });

    _gameSession.answerQuestion(index);

    // Attendre avant de passer à la suite
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _gameSession.nextQuestion();
        _loadNextQuestion();
      }
    });
  }

  void _changeImage(int direction) {
    final currentBird = _gameSession.currentQuestion;
    if (!currentBird.hasMultipleImages) return;

    setState(() {
      _currentImageIndex = (_currentImageIndex + direction) %
          currentBird.displayImages.length;
      if (_currentImageIndex < 0) {
        _currentImageIndex = currentBird.displayImages.length - 1;
      }
    });
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => BirdInfoScreen(
        bird: _gameSession.currentQuestion,
        showBname: widget.showBname,
        showLatin: widget.showLatin,
      ),
    );
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          gameSession: _gameSession,
          onRetryWrongAnswers: _retryWrongAnswers,
          onNewQuiz: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
    );
  }

  void _retryWrongAnswers() {
    if (_gameSession.wrongAnswers.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quiz: widget.quiz,
          birds: _gameSession.wrongAnswers,
          showLatin: widget.showLatin,
          showBname: widget.showBname,
          imageHeight: widget.imageHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameSession.hasMoreQuestions && _gameSession.questions.isNotEmpty) {
      return Scaffold(
        backgroundColor: QuizConfig.bgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentBird = _gameSession.currentQuestion;
    final hasMultipleImages = currentBird.hasMultipleImages;

    return Scaffold(
      backgroundColor: QuizConfig.bgColor,
      appBar: AppBar(
        title: Text(
          '${_gameSession.currentQuestionIndex + 1}/${_gameSession.questions.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Score: ${_gameSession.score}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomScrollView(
            slivers: [
              // Barre de progression
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_gameSession.currentQuestionIndex + 1) /
                          _gameSession.questions.length,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Image
              SliverToBoxAdapter(
                child: SizedBox(
                  height: widget.imageHeight,
                  child: Stack(
                    children: [
                      QuizImage(
                        imagePath: currentBird.displayImages[_currentImageIndex],
                        height: widget.imageHeight,
                      ),
                      if (hasMultipleImages)
                        Positioned.fill(
                          child: NavigationButtons(
                            onPrevious: () => _changeImage(-1),
                            onNext: () => _changeImage(1),
                            currentIndex: _currentImageIndex,
                            totalImages: currentBird.displayImages.length,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Question
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Quel est le nom de cet oiseau ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Options avec SliverList
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final bird = _currentOptions[index];
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = bird.fname == currentBird.fname;

                    Color backgroundColor = QuizConfig.buttonBg;
                    if (_showAnswer) {
                      if (isCorrect) {
                        print("correct");
                        backgroundColor = QuizConfig.correctBg;
                      } else if (isSelected && !isCorrect) {
                        print("incorrect");
                        backgroundColor = QuizConfig.wrongBg;
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: 10,
                        left: 5,
                        right: 5,
                        top: index == 0 ? 0 : 0,
                      ),
                      child: AnswerButton(
                        text: bird.getDisplayName(
                          showBname: widget.showBname,
                          showLatin: widget.showLatin,
                        ),
                        backgroundColor: backgroundColor,
                        isDisabled: _selectedAnswer != null,
                        onPressed: () => _selectAnswer(index),
                      ),
                    );
                  },
                  childCount: _currentOptions.length,
                ),
              ),

              // Boutons d'action
              // SliverToBoxAdapter(
              //   child: Container(
              //     margin: const EdgeInsets.only(top: 20, bottom: 30),
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     decoration: BoxDecoration(
              //       color: QuizConfig.bgColor,
              //       border: Border(
              //         top: BorderSide(color: Colors.grey[300]!),
              //         bottom: BorderSide(color: Colors.grey[300]!),
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //         if (_showAnswer)
              //           ElevatedButton(
              //             onPressed: _showInfo,
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: QuizConfig.buttonBg,
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 20,
              //                 vertical: 12,
              //               ),
              //             ),
              //             child: const Row(
              //               children: [
              //                 Icon(Icons.info_outline),
              //                 SizedBox(width: 8),
              //                 Text('Info'),
              //               ],
              //             ),
              //           ),
              //
              //         if (_showAnswer)
              //           ElevatedButton(
              //             onPressed: _loadNextQuestion,
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: Colors.blue,
              //               foregroundColor: Colors.white,
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 24,
              //                 vertical: 12,
              //               ),
              //             ),
              //             child: Text(
              //               _gameSession.hasMoreQuestions
              //                   ? QuizConfig.nextQuestion
              //                   : QuizConfig.startQuiz,
              //               style: const TextStyle(fontWeight: FontWeight.bold),
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/views/screens/home_screen.dart';

import 'constants/quiz_config.dart';
import 'data/repositories/bird_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BirdRepository _birdRepository = BirdRepository();
  bool _isLoading = true;
  bool _showLatin = false;
  bool _showBname = true;
  String _resizeMode = 'new';
  double _imageHeight = QuizConfig.imageHeight;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _birdRepository.loadQuizzes();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One of Three Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: QuizConfig.bgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: QuizConfig.buttonBg,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: QuizConfig.textSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: QuizConfig.buttonBg,
            foregroundColor: Colors.black,
            textStyle: TextStyle(fontSize: QuizConfig.textSize),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: TextStyle(fontSize: QuizConfig.textSize),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: QuizConfig.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          color: QuizConfig.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: QuizConfig.buttonBg,
          selectedColor: Colors.blue,
          labelStyle: const TextStyle(color: Colors.black),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: _isLoading
          ? Scaffold(
        backgroundColor: QuizConfig.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Chargement des quiz...',
                style: TextStyle(
                  fontSize: QuizConfig.textSize,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )
          : HomeScreen(
        birdRepository: _birdRepository,
        showLatin: _showLatin,
        showBname: _showBname,
        resizeMode: _resizeMode,
        imageHeight: _imageHeight,
        onSettingsChanged: (showLatin, showBname, resizeMode, imageHeight) {
          setState(() {
            _showLatin = showLatin;
            _showBname = showBname;
            _resizeMode = resizeMode;
            _imageHeight = imageHeight;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';

class QuizConfig {
  // Dimensions
  static double imageHeight = 400;
  static const double textSize = 18;
  static const double spacing = 30;

  // Couleurs
  static const Color bgColor = Color(0xFFFFFAFA); // snow
  static const Color buttonBg = Color(0xFFFFF5EE); // seashell
  static const Color correctBg = Colors.green;
  static const Color wrongBg = Colors.red;

  // Textes en français
  static const String chooseQuiz = 'choisir un quiz';
  static const String chooseCategory = 'choisissez une category';
  static const String closeHere = 'fermer ici pour continuer';
  static const String continueText = 'continuer';
  static const String feedback =
      "\nVous pouvez aussi répéter uniquement\nles incorrectes réponses ci-dessous.";
  static const String nextQuestion = 'question suivante';
  static const String noCategory = 'pas de catégorie choisit';
  static const String noQuiz = 'pas de quiz choisit';
  static const String startQuiz = 'lancer le quiz';
  static const String selectQuiz = 'choisissez un ou plusieurs sujets';
  static const String trySecondRound = 'répéter les réponses incorrectes';
  static const String info = 'info';
  static const String close = 'fermer';
}
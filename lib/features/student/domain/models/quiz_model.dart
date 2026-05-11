class QuizQuestion {
  final String questionText;
  final String imageAssetPath;
  final List<String> options;
  final int correctOptionIndex;
  final String hint;
  final String funFact;

  const QuizQuestion({
    required this.questionText,
    required this.imageAssetPath,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    required this.funFact,
  });
}

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

  Map<String, dynamic> toJson() => {
        'questionText': questionText,
        'imageAssetPath': imageAssetPath,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'hint': hint,
        'funFact': funFact,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        questionText: json['questionText'] as String,
        imageAssetPath: json['imageAssetPath'] as String,
        options: List<String>.from(json['options']),
        correctOptionIndex: json['correctOptionIndex'] as int,
        hint: json['hint'] as String,
        funFact: json['funFact'] as String,
      );
}

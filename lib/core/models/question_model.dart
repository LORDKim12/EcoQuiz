/// Modelo de pregunta de quiz. Puro Dart, serializable a JSON/BD.
class QuestionModel {
  final String id;
  final int levelId;
  final String questionText;
  final String imageUrl; // URL remota o asset path local
  final List<String> options;
  final int correctIndex;
  final String hint;
  final String funFact;

  const QuestionModel({
    required this.id,
    required this.levelId,
    required this.questionText,
    required this.imageUrl,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.funFact,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'level_id': levelId,
        'question_text': questionText,
        'image_url': imageUrl,
        'options': options,
        'correct_index': correctIndex,
        'hint': hint,
        'fun_fact': funFact,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] ?? '',
        levelId: json['level_id'] ?? 0,
        questionText: json['question_text'] ?? '',
        imageUrl: json['image_url'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correct_index'] ?? 0,
        hint: json['hint'] ?? '',
        funFact: json['fun_fact'] ?? '',
      );
}

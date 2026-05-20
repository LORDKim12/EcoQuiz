/// Modelo de intento de quiz. Registra cada respuesta del alumno.
/// Útil para analytics del maestro y para la BD.
class QuizAttemptModel {
  final String id;
  final String studentId;
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final int timeSeconds; // Tiempo que tardó en responder
  final DateTime createdAt;

  const QuizAttemptModel({
    required this.id,
    required this.studentId,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'question_id': questionId,
        'selected_index': selectedIndex,
        'is_correct': isCorrect,
        'time_seconds': timeSeconds,
        'created_at': createdAt.toIso8601String(),
      };

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      QuizAttemptModel(
        id: json['id'] ?? '',
        studentId: json['student_id'] ?? '',
        questionId: json['question_id'] ?? '',
        selectedIndex: json['selected_index'] ?? 0,
        isCorrect: json['is_correct'] ?? false,
        timeSeconds: json['time_seconds'] ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}

import 'models/identity.dart';

class Answer {
  final String text;
  final Map<IdentityId, double> scores;

  Answer({required this.text, required this.scores});
}

class Question {
  final String id;
  final String category;
  final String text;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.category,
    required this.text,
    required this.answers,
  });
}

import 'package:alter_ego/alter_ego_screen.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/question.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _questionIndex = 0;
  final List<Answer> _answers = [];
  final AppSettingsService _settings = AppSettingsService();
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final recent = await _settings.recentQuestionIds();
    final selected = OfflineContentRepository.selectDailyQuestions(
      day: DateTime.now(),
      excludedIds: recent,
      count: 8,
    );
    setState(() {
      _questions = selected;
    });
  }

  Future<void> _answerQuestion(Answer answer) async {
    _answers.add(answer);
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
    } else {
      await _settings.rememberQuestionIds(_questions.map((q) => q.id).toList());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AlterEgoScreen(answers: _answers)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentQuestion = _questions[_questionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Check-in (${_questionIndex + 1}/${_questions.length})')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentQuestion.category.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                currentQuestion.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...currentQuestion.answers.map((answer) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(answer),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(answer.text, textAlign: TextAlign.center),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

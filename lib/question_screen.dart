import 'package:alter_ego/alter_ego_screen.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/question.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    HapticFeedback.mediumImpact();
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
      appBar: AppBar(
        title: Text('Check-in (${_questionIndex + 1}/${_questions.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                currentQuestion.category.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.bold),
              ).animate(key: ValueKey('cat_$_questionIndex')).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 16),
              Text(
                currentQuestion.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
              ).animate(key: ValueKey('q_$_questionIndex')).fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 40),
              ...currentQuestion.answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildAnswerCard(answer, index),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCard(Answer answer, int index) {
    return GestureDetector(
      onTap: () => _answerQuestion(answer),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          answer.text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
    )
        .animate(key: ValueKey('ans_${_questionIndex}_$index'))
        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }
}

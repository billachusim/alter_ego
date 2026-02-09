import 'package:alter_ego/alter_ego_screen.dart';
import 'package:alter_ego/question.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _questionIndex = 0;
  final List<Answer> _answers = [];

  static final _questions = [
    Question(
      text: 'When you\'re angry, what usually happens?',
      answers: [
        Answer(text: 'I withdraw and shut down', scores: {'The Shadow': 0.1, 'The Strategist': 0.05}),
        Answer(text: 'I get confrontational', scores: {'The Rebel': 0.1}),
        Answer(text: 'I try to understand the other side', scores: {'The Caretaker': 0.1}),
      ],
    ),
    Question(
      text: 'A sudden free weekend appears. You...',
      answers: [
        Answer(text: 'Finally tackle that project you\'ve been planning', scores: {'The Strategist': 0.1}),
        Answer(text: 'Book a spontaneous trip', scores: {'The Rebel': 0.1, 'The Shadow': -0.05}),
        Answer(text: 'Check in on friends and family', scores: {'The Caretaker': 0.1}),
      ],
    ),
    Question(
      text: 'You want stability, but you also want chaos — which wins today?',
      answers: [
        Answer(text: 'Stability', scores: {'The Strategist': 0.1, 'The Caretaker': 0.05}),
        Answer(text: 'Chaos', scores: {'The Rebel': 0.1}),
        Answer(text: 'A little of both', scores: {'The Strategist': 0.05, 'The Rebel': 0.05}),
      ],
    ),
  ];

  void _answerQuestion(Answer answer) {
    _answers.add(answer);
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AlterEgoScreen(answers: _answers)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in (${_questionIndex + 1}/${_questions.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchOutCurve: Curves.easeIn,
          switchInCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Padding(
            key: ValueKey<int>(_questionIndex),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentQuestion.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ...currentQuestion.answers.map((answer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(answer),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(answer.text, textAlign: TextAlign.center),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  final List<int> _answers = [];

  final _questions = [
    Question(
      text: 'When you\'re angry, what usually happens?',
      answers: ['I withdraw and shut down', 'I get confrontational', 'I try to understand the other side'],
    ),
    Question(
      text: 'Which feels more true?',
      answers: ['I want stability', 'I want chaos'],
    ),
    Question(
      text: 'You want stability, but you also want chaos — which wins?',
      answers: ['Stability', 'Chaos', 'It depends'],
    ),
  ];

  void _answerQuestion(int answerIndex) {
    _answers.add(answerIndex);
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
    } else {
      // End of questions, navigate to the results screen
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentQuestion.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ...currentQuestion.answers.asMap().entries.map((entry) {
              int idx = entry.key;
              String answer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(idx),
                  child: Text(answer),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

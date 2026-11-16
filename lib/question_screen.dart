import 'package:alter_ego/alter_ego_screen.dart';
import 'package:alter_ego/question.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart'
    show OfflineContentRepository;
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/widgets/mystic_background.dart';
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
      count: 6,
    );
    setState(() {
      _questions = selected;
    });
  }

  String? _pop;
  Color _popColor = Colors.white;
  int _popKey = 0;
  bool _busy = false;

  static const _colors = {
    IdentityId.strategist: Colors.blue,
    IdentityId.rebel: Colors.red,
    IdentityId.caretaker: Colors.green,
    IdentityId.achiever: Colors.orange,
    IdentityId.romantic: Colors.pink,
    IdentityId.protector: Colors.teal,
    IdentityId.analyst: Colors.indigo,
    IdentityId.escapist: Colors.blueGrey,
    IdentityId.shadow: Colors.purple,
  };

  Future<void> _answerQuestion(Answer answer) async {
    if (_busy) return;
    _busy = true;
    HapticFeedback.mediumImpact();
    _answers.add(answer);
    // Show which voice this answer fed.
    final top = answer.scores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final profile = OfflineContentRepository.profilesById[top]!;
    setState(() {
      _pop = '${profile.icon}  +${profile.shortName}';
      _popColor = _colors[top]!;
      _popKey++;
    });
    await Future.delayed(const Duration(milliseconds: 650));
    _busy = false;
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
    } else {
      await _settings.rememberQuestionIds(_questions.map((q) => q.id).toList());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AlterEgoScreen(answers: _answers),
        ),
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
      backgroundColor: const Color(0xFF0B0D12),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _progressDots(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MysticBackground(
              aura: _popColor == Colors.white
                  ? const Color(0xff6C5CE7)
                  : _popColor,
            ),
          ),
          if (_pop != null)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child:
                    Text(
                          _pop!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _popColor,
                            shadows: [Shadow(color: _popColor, blurRadius: 18)],
                          ),
                        )
                        .animate(key: ValueKey('pop_$_popKey'))
                        .fadeIn(duration: 150.ms)
                        .scale(
                          begin: const Offset(.5, .5),
                          curve: Curves.easeOutBack,
                          duration: 350.ms,
                        )
                        .moveY(begin: 20, end: -30, duration: 900.ms)
                        .fadeOut(delay: 500.ms, duration: 400.ms),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                          (currentQuestion.category == 'mystic'
                              ? '✧ MYSTIC ✧'
                              : currentQuestion.category.toUpperCase()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            letterSpacing: 4,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate(key: ValueKey('cat_$_questionIndex'))
                        .fadeIn()
                        .slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    Text(
                          currentQuestion.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        )
                        .animate(key: ValueKey('q_$_questionIndex'))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_questions.length, (i) {
        final done = i < _questionIndex;
        final current = i == _questionIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: current ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: done
                ? const Color(0xff8E7CFF)
                : (current ? Colors.white : Colors.white24),
          ),
        );
      }),
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

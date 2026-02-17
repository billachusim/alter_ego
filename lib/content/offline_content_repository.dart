import 'dart:math';

import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/question.dart';

class CouncilReply {
  final IdentityId identity;
  final String situationType;
  final String intensity;
  final String text;

  const CouncilReply({
    required this.identity,
    required this.situationType,
    required this.intensity,
    required this.text,
  });
}

class OfflineContentRepository {
  OfflineContentRepository._();

  static final profiles = <IdentityProfile>[
    const IdentityProfile(id: IdentityId.strategist, label: 'The Strategist', shortName: 'Strategist', icon: '🜂', description: 'Plans with precision and thinks five moves ahead.', shadowPattern: 'Over-plans until action gets delayed.', growthCue: 'Pick one move and execute before optimizing.'),
    const IdentityProfile(id: IdentityId.rebel, label: 'The Rebel', shortName: 'Rebel', icon: '🜁', description: 'Protects freedom and resists pressure fast.', shadowPattern: 'Mistakes resistance for self-expression.', growthCue: 'Choose a rule to break and one to honor.'),
    const IdentityProfile(id: IdentityId.caretaker, label: 'The Caretaker', shortName: 'Caretaker', icon: '🜄', description: 'Feels others deeply and carries emotional weight.', shadowPattern: 'Gives until resentment builds.', growthCue: 'Offer support without abandoning your own needs.'),
    const IdentityProfile(id: IdentityId.achiever, label: 'The Achiever', shortName: 'Achiever', icon: '⬢', description: 'Tracks progress and turns pressure into output.', shadowPattern: 'Self-worth becomes tied to performance.', growthCue: 'Measure effort quality, not only outcomes.'),
    const IdentityProfile(id: IdentityId.romantic, label: 'The Romantic', shortName: 'Romantic', icon: '✦', description: 'Craves depth, meaning, and emotional truth.', shadowPattern: 'Idealizes then crashes into disappointment.', growthCue: 'Seek consistency over intensity.'),
    const IdentityProfile(id: IdentityId.protector, label: 'The Protector', shortName: 'Protector', icon: '🛡', description: 'Defends boundaries and people with fierce loyalty.', shadowPattern: 'Threat-detection stays on even when safe.', growthCue: 'Pause and verify threat before reacting.'),
    const IdentityProfile(id: IdentityId.analyst, label: 'The Analyst', shortName: 'Analyst', icon: '◬', description: 'Finds truth through evidence and pattern clarity.', shadowPattern: 'Confuses emotional distance with objectivity.', growthCue: 'Include feelings as data, not noise.'),
    const IdentityProfile(id: IdentityId.escapist, label: 'The Escapist', shortName: 'Escapist', icon: '☾', description: 'Looks for relief when reality feels heavy.', shadowPattern: 'Numbs discomfort and postpones growth.', growthCue: 'Take one tiny step before seeking comfort.'),
    const IdentityProfile(id: IdentityId.shadow, label: 'The Shadow', shortName: 'Shadow', icon: '🜃', description: 'Holds suppressed anger, hunger, and unspoken truth.', shadowPattern: 'Operates indirectly through cynicism or avoidance.', growthCue: 'Name the raw truth directly and safely.'),
  ];

  static final Map<IdentityId, IdentityProfile> profilesById = {
    for (final p in profiles) p.id: p,
  };

  static List<Question> getQuestionBank() {
    final categories = {
      'conflict': [
        'Someone dismisses your opinion in public',
        'A friend crosses a boundary again',
        'Your plan gets derailed last minute',
        'You are misunderstood in a tense conversation',
      ],
      'work': [
        'A high-stakes deadline lands suddenly',
        'You receive ambiguous feedback from your manager',
        'You can either ship now or improve quality',
        'Your teammate is underperforming on shared work',
      ],
      'relationships': [
        'A person you care about goes emotionally distant',
        'You sense mixed signals from someone important',
        'You need to ask for reassurance directly',
        'You must choose between peace and honesty tonight',
      ],
      'stress': [
        'Your mind feels loud and overloaded',
        'You wake up tired with no emotional buffer',
        'Everything feels urgent at once',
        'You feel pressure to be perfect',
      ],
      'identity': [
        'You wonder who is actually in control lately',
        'You notice an old pattern returning',
        'You feel split between comfort and growth',
        'You want to reinvent yourself but fear regret',
      ],
    };

    final answerTemplates = [
      (
        'I pause, map the pattern, then choose deliberately.',
        {
          IdentityId.strategist: 0.11,
          IdentityId.analyst: 0.07,
        }
      ),
      (
        'I push back fast. I would rather be real than compliant.',
        {
          IdentityId.rebel: 0.12,
          IdentityId.protector: 0.06,
        }
      ),
      (
        'I check who might be affected and try to hold everyone gently.',
        {
          IdentityId.caretaker: 0.12,
          IdentityId.romantic: 0.05,
        }
      ),
      (
        'I convert pressure into action and chase measurable progress.',
        {
          IdentityId.achiever: 0.12,
          IdentityId.strategist: 0.05,
        }
      ),
      (
        'I seek depth, emotional truth, and the conversation beneath the conversation.',
        {
          IdentityId.romantic: 0.11,
          IdentityId.shadow: 0.05,
        }
      ),
      (
        'I protect my boundaries first, then decide what access is earned.',
        {
          IdentityId.protector: 0.12,
          IdentityId.shadow: 0.04,
        }
      ),
      (
        'I gather data and detach until the facts are clean.',
        {
          IdentityId.analyst: 0.12,
          IdentityId.strategist: 0.04,
        }
      ),
      (
        'I avoid the weight for now and distract until I can breathe again.',
        {
          IdentityId.escapist: 0.13,
          IdentityId.shadow: 0.03,
        }
      ),
      (
        'I go quiet and track the truth nobody is saying out loud.',
        {
          IdentityId.shadow: 0.12,
          IdentityId.analyst: 0.04,
        }
      ),
    ];

    final questions = <Question>[];
    var i = 0;
    categories.forEach((category, prompts) {
      for (final prompt in prompts) {
        for (var variant = 0; variant < 18; variant++) {
          final answers = answerTemplates
              .map((a) => Answer(text: a.$1, scores: a.$2))
              .toList(growable: false);
          questions.add(
            Question(
              id: 'q_${category}_$i',
              category: category,
              text: '$prompt — what feels most like you right now?',
              answers: answers,
            ),
          );
          i++;
        }
      }
    });
    return questions;
  }

  static List<Question> selectDailyQuestions({
    required DateTime day,
    required Set<String> excludedIds,
    int count = 8,
  }) {
    final bank = getQuestionBank().where((q) => !excludedIds.contains(q.id)).toList();
    if (bank.isEmpty) return [];
    bank.shuffle(Random(day.year + day.month + day.day));

    final byCategory = <String, List<Question>>{};
    for (final q in bank) {
      byCategory.putIfAbsent(q.category, () => []).add(q);
    }

    final selected = <Question>[];
    while (selected.length < count && byCategory.values.any((list) => list.isNotEmpty)) {
      for (final entry in byCategory.entries) {
        if (selected.length >= count) break;
        if (entry.value.isNotEmpty) {
          selected.add(entry.value.removeAt(0));
        }
      }
    }
    return selected;
  }

  static List<CouncilReply> buildCouncilReplies() {
    const situations = ['decision', 'conflict', 'love', 'career', 'fear', 'boundaries'];
    const intensity = ['low', 'medium', 'high'];
    final replies = <CouncilReply>[];
    for (final profile in profiles) {
      for (final s in situations) {
        for (final level in intensity) {
          for (var i = 0; i < 5; i++) {
            replies.add(
              CouncilReply(
                identity: profile.id,
                situationType: s,
                intensity: level,
                text: _line(profile.shortName, s, level, i),
              ),
            );
          }
        }
      }
    }
    return replies;
  }

  static String pickReply({
    required IdentityId identity,
    required String situationType,
    required String intensity,
    int seed = 0,
  }) {
    final pool = buildCouncilReplies().where((r) => r.identity == identity && r.situationType == situationType && r.intensity == intensity).toList();
    if (pool.isEmpty) return 'Stay honest with yourself. Small clear moves beat dramatic swings.';
    return pool[seed % pool.length].text;
  }

  static List<String> notificationPrompts() {
    return [
      'Your Rebel showed up today.',
      'I\'m noticing a pattern…',
      'Your Strategist and Rebel disagreed today.',
      'You\'re becoming more decisive.',
      'There\'s a side of you you\'re avoiding.',
      'Tonight your dominant voice changed.',
      'Your Shadow has a message you keep postponing.',
      'Your boundaries were clearer than yesterday.',
      'You chose calm over impulse today.',
      'Identity reset window is open.',
    ];
  }

  static String _line(String ego, String s, String level, int i) {
    return switch ('$ego|$s|$level|$i') {
      _ => '$ego says: in $s mode ($level), choose the move that protects your future self, not just your current mood.'
    };
  }
}
